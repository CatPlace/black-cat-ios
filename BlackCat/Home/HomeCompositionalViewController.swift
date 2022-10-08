//
//  HomeCompositionalViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/06.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

extension HomeSection: SectionModelType {
    typealias Item = HomeItem

    init(original: HomeSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}

class HomeCompositionalViewController: UIViewController {

    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection> { dataSource, collectionView, indexPath, item in
        switch item {
        case .HomeCategoryCellItem(let category):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCategoryCell.identifier, for: indexPath) as! HomeCategoryCell
            cell.bind(to: HomeCategoryCellViewModel(category: category))

            return cell

        case .Section1(let section1):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSection1Cell.identifier, for: indexPath) as! HomeSection1Cell

            return cell

        case .Empty(let empty):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEmptyCell.identifier, for: indexPath) as! HomeEmptyCell

            return cell

        case .Section2(let section2):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSection2Cell.identifer, for: indexPath) as! HomeSection2Cell

            return cell
        }
    } configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        guard kind == UICollectionView.elementKindSectionHeader,
              indexPath.section == 1 || indexPath.section == 3 else { return UICollectionReusableView() }

        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HomeHeaderView.identifer, for: indexPath) as! HomeHeaderView
        let headerTitle = dataSource.sectionModels[indexPath.section].header

        headerView.titleLabel.text = headerTitle

        return headerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        bind()
    }

    func bind() {
        viewModel.homeItems
            .drive(homeCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - UIComponents

    lazy var homeCollectionView: UICollectionView = {
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
            HomeEmptyCell.self,
            forCellWithReuseIdentifier: HomeEmptyCell.identifier
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
                let itemSpacing: CGFloat = 12
                let sectionLeadingInset: CGFloat = 14
                let sectionTrailinginset: CGFloat = 14
                let itemWidth: CGFloat = (UIScreen.main.bounds.width - (itemSpacing * 4) - (sectionLeadingInset + sectionTrailinginset)) / 5

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(itemWidth)
                )

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)
                group.interItemSpacing = .fixed(itemSpacing)

                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = itemSpacing
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 14, bottom: 30, trailing: 14)

                let sectionBackgroundView = NSCollectionLayoutDecorationItem.background(elementKind: HomeCategorySectionBackgroundReusableView.identifier)
                section.decorationItems = [sectionBackgroundView]

                return section
            case 1:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(140),
                    heightDimension: .estimated(210)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 20
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(43)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0)

                section.boundarySupplementaryItems = [header]

                return section

            case 2:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(20)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)

                return section

            default:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1 / 3)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
                group.interItemSpacing = .fixed(1)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 1
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0.5, bottom: 0, trailing: 0.5)

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(43)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                header.contentInsets = .init(top: 0, leading: 9.5, bottom: 0, trailing: 0)

                section.boundarySupplementaryItems = [header]

                return section
            }
        }
        layout.register(HomeCategorySectionBackgroundReusableView.self, forDecorationViewOfKind: HomeCategorySectionBackgroundReusableView.identifier)

        return layout
    }()
}

extension HomeCompositionalViewController {
    private func setUI() {
        view.addSubview(homeCollectionView)

        homeCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
