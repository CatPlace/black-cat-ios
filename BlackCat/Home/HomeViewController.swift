//
//  HomeViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/06.
//

import UIKit

import BlackCatSDK
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

class HomeViewController: UIViewController {

    enum Reusable {
        static let categoryCell = ReusableCell<HomeCategoryCell>()
        static let recommendCell = ReusableCell<HomeRecommendCell>()
        static let emptyCell = ReusableCell<HomeEmptyCell>()
        static let allTattoosCell = ReusableCell<HomeAllTattoosCell>()
        static let headerView = ReusableView<HomeHeaderView>()
    }

    // MARK: - Properties

    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .categoryCellItem(let categoryCellViewModel):
                let cell = collectionView.dequeue(Reusable.categoryCell, for: indexPath)

                cell.bind(to: categoryCellViewModel)
                return cell

            case .recommendCellItem(let recommendCellViewModel):
                let cell = collectionView.dequeue(Reusable.recommendCell, for: indexPath)

                cell.bind(to: recommendCellViewModel)
                return cell

            case .empty(let empty):
                let cell = collectionView.dequeue(Reusable.emptyCell, for: indexPath)
                return cell

            case .allTattoosCellItem(let allTattoosCellViewModel):
                let cell = collectionView.dequeue(Reusable.allTattoosCell, for: indexPath)

                cell.bind(to: allTattoosCellViewModel)
                return cell
            }
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            guard kind == UICollectionView.elementKindSectionHeader,
                  indexPath.section == 1 || indexPath.section == 3
            else {
                return UICollectionReusableView()
            }

            let headerView = collectionView.dequeue(Reusable.headerView, kind: .header, for: indexPath)
            let headerTitle = dataSource.sectionModels[indexPath.section].header

            headerView.titleLabel.text = headerTitle
            return headerView
        })

    // MARK: - Binding

    private func bind() {

        // MARK: - Action

        rx.viewDidLoad
            .bind(to: viewModel.viewDidLoad)
            .disposed(by: disposeBag)

        searchBarButtonItem.rx.tap
            .bind(to: viewModel.didTapSearchBarButtonItem)
            .disposed(by: disposeBag)

        heartBarButtonItem.rx.tap
            .bind(to: viewModel.didTapHeartBarButtonItem)
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .bind(to: viewModel.didTapCollectionViewItem)
            .disposed(by: disposeBag)

        // MARK: - State

        viewModel.homeItems
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - Initializing

    init() {
        super.init(nibName: nil, bundle: nil)

        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setUI()
    }

    // MARK: - UIComponents

    let leftTitleBarButtonItem: UIBarButtonItem = {
        let label = UILabel()
        label.text = "Black Cat"
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 32)
        return UIBarButtonItem(customView: label)
    }()

    let searchBarButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "magnifyingglass")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
    }()

    let heartBarButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "heart")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: compositionalLayout
        )

        collectionView.register(Reusable.categoryCell)
        collectionView.register(Reusable.recommendCell)
        collectionView.register(Reusable.emptyCell)
        collectionView.register(Reusable.allTattoosCell)
        collectionView.register(Reusable.headerView, kind: .header)

        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    lazy var compositionalLayout: UICollectionViewLayout = {
        enum SectionType: Int {
            case category
            case recommend
            case empty
            case allTattoos
        }

        let layout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            guard let sectionType = SectionType(rawValue: section) else { return nil }
            switch sectionType {
            case .category:
                let itemSpacing: CGFloat = 12
                let sectionLeadingInset: CGFloat = 14
                let sectionTrailinginset: CGFloat = 14
                let itemWidth = (UIScreen.main.bounds.width - (itemSpacing * 4) - (sectionLeadingInset + sectionTrailinginset)) / 5

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

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = itemSpacing
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 14, bottom: 30, trailing: 14)

                let sectionBackgroundView = NSCollectionLayoutDecorationItem.background(
                    elementKind: HomeCategorySectionBackgroundReusableView.identifier
                )
                section.decorationItems = [sectionBackgroundView]

                return section
            case .recommend:
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
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20)

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

            case .empty:
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

            case .allTattoos:
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
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.contentInsets = .init(top: 0, leading: 9.5, bottom: 0, trailing: 0)

                section.boundarySupplementaryItems = [header]

                return section
            }
        }

        layout.register(
            HomeCategorySectionBackgroundReusableView.self,
            forDecorationViewOfKind: HomeCategorySectionBackgroundReusableView.identifier
        )

        return layout
    }()
}

extension HomeViewController {
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = leftTitleBarButtonItem
        navigationItem.rightBarButtonItems = [
            heartBarButtonItem,
            searchBarButtonItem
        ]
    }

    private func setUI() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

