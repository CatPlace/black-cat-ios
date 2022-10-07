//
//  HomeCompositionalViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/06.
//

import UIKit

import SnapKit

class HomeCompositionalViewController: UIViewController {

    var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    let categories: [String] = [
        "전체보기", "레터링", "미니 타투", "감성 타투", "이레즈미", "블랙&그레이", "라인워크", "헤나",
        "커버업", "뉴스쿨", "올드스쿨", "잉크 스플래쉬", "치카노", "컬러", "캐릭터"
    ]

    enum Section {
        case category
        case section1
        case section2
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCategoryCell.identifier, for: indexPath) as? HomeCategoryCell else { return UICollectionViewCell() }
                cell.categoryTitleLabel.text = itemIdentifier

                return cell

            case 1:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSection1Cell.identifier, for: indexPath) as?
                        HomeSection1Cell else { return UICollectionViewCell() }
                cell.priceLabel.text = itemIdentifier

                return cell

            default:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HomeSection2Cell.identifer,
                    for: indexPath
                ) as? HomeSection2Cell else { return UICollectionViewCell() }

                return cell
            }
        })

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let homeHeaderView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: HomeHeaderView.identifer,
                for: indexPath) as? HomeHeaderView else { return  UICollectionReusableView() }
            switch indexPath.section {
            case 1:
                homeHeaderView.titleLabel.text = "항목 1"
            case 2:
                homeHeaderView.titleLabel.text = "항목 2"
            default:
                return homeHeaderView
            }

            return homeHeaderView
        }

        var snapShot = NSDiffableDataSourceSnapshot<Section, String>()
        snapShot.appendSections([.category, .section1, .section2])
        snapShot.appendItems(categories, toSection: .category)
        snapShot.appendItems(["안녕", "바보", "짱구는", "못말려", "아니야", "말릴 수 ", "있어"], toSection: .section1)
        snapShot.appendItems(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18"])
        dataSource.apply(snapShot)

        setUI()
    }

    // MARK: - UIComponents

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: compositionalLayout
        )

        collectionView.register(
            HomeCategoryCell.self,
            forCellWithReuseIdentifier: HomeCategoryCell.identifier
        )
        collectionView.register(
            HomeSection1Cell.self,
            forCellWithReuseIdentifier: HomeSection1Cell.identifier
        )
        collectionView.register(
            HomeSection2Cell.self,
            forCellWithReuseIdentifier: HomeSection2Cell.identifer
        )
        collectionView.register(
            HomeHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeHeaderView.identifer
        )

        collectionView.showsVerticalScrollIndicator = false

        return collectionView
    }()

    let compositionalLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (section: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch section {
            case 0:
                let itemInset: CGFloat = 12
                let sectionLeadingInset: CGFloat = 14
                let sectionTrailinginset: CGFloat = 14
                let itemWidth: CGFloat = (UIScreen.main.bounds.width - (itemInset * 4) - (sectionLeadingInset + sectionTrailinginset)) / 5

                // Item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(itemWidth),
                    heightDimension: .absolute(itemWidth)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // Group
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(itemWidth)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(itemInset)

                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = itemInset
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 14, bottom: 30, trailing: 14)

                return section
            case 1:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(140),
                    heightDimension: .absolute(210)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//                group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 20
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 30)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(43))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]

                return section

            default:
                let itemWidth: CGFloat = (UIScreen.main.bounds.width - 3) / 3

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(itemWidth),
                    heightDimension: .absolute(itemWidth)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(itemWidth)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(1)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 1
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0.5, bottom: 0, trailing: 0.5)

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(43)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]

                return section
            }
        }

        return layout
    }()
}

extension HomeCompositionalViewController {
    private func setUI() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
