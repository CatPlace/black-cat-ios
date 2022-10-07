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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCategoryCell.identifier, for: indexPath) as? HomeCategoryCell else { return UICollectionViewCell() }

            cell.categoryTitleLabel.text = itemIdentifier


            return cell
        })

        var snapShot = NSDiffableDataSourceSnapshot<Section, String>()
        snapShot.appendSections([.category])
        snapShot.appendItems(categories, toSection: .category)
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

        return collectionView
    }()

    let compositionalLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            switch section {
            case 0:
                let itemInset: CGFloat = 12
                let sectionLeadingInset = 14
                let sectionTrailinginset = 14
                let itemWidth = (UIScreen.main.bounds.width - (itemInset * 4) - (sectionLeadingInset + sectionTrailinginset)) / 5

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
                group.interItemSpacing = .fixed(itemInset)

                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = itemInset
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 14, bottom: 30, trailing: 14)

                return section
            case 1:
                let itemFractionalWidthFraction = 1.0 / 5.0 // horizontal 5개의 셀
                let groupFractionalHeightFraction = 1.0 / 4.0 // vertical 4개의 셀
                let itemInset: CGFloat = 2.5

                // Item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(itemFractionalWidthFraction),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: itemInset, leading: itemInset, bottom: itemInset, trailing: itemInset)

                // Group
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(groupFractionalHeightFraction)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: itemInset, leading: itemInset, bottom: itemInset, trailing: itemInset)

                return section
            default:
                let itemFractionalWidthFraction = 1.0 / 5.0 // horizontal 5개의 셀
                let groupFractionalHeightFraction = 1.0 / 4.0 // vertical 4개의 셀
                let itemInset: CGFloat = 2.5

                // Item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(itemFractionalWidthFraction),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: itemInset, leading: itemInset, bottom: itemInset, trailing: itemInset)

                // Group
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(groupFractionalHeightFraction)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: itemInset, leading: itemInset, bottom: itemInset, trailing: itemInset)

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
