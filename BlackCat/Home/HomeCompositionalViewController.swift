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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCategoryCell.identifier, for: indexPath) as? HomeCategoryCell else { return UICollectionViewCell() }
                cell.categoryTitleLabel.text = itemIdentifier

                return cell

            default:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSection1Cell.identifier, for: indexPath) as?
                        HomeSection1Cell else { return UICollectionViewCell() }
                cell.priceLabel.text = itemIdentifier

                return cell
            }
        })

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let homeHeaderView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: HomeHeaderView.identifer,
                for: indexPath) as? HomeHeaderView else { return  UICollectionReusableView() }
            homeHeaderView.titleLabel.text = "항목 1"

            return homeHeaderView
        }

        var snapShot = NSDiffableDataSourceSnapshot<Section, String>()
        snapShot.appendSections([.category, .section1])
        snapShot.appendItems(categories, toSection: .category)
        snapShot.appendItems(["안녕", "바보"], toSection: .section1)
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
            HomeHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeHeaderView.identifer
        )

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
            default:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(140),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(210)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(20)

                let section = NSCollectionLayoutSection(group: group)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(43))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]

                return section
            }
        }

        return layout
    }()

    private func categoryLayoutSection() -> NSCollectionLayoutSection {
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
    }

    private func section1LayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(140),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(210)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(20)

        let section = NSCollectionLayoutSection(group: group)

        return section
    }
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
