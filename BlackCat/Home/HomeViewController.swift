//
//  HomeViewController.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/06.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

class HomeViewController: UIViewController {

    // MARK: - Properties

    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
        switch item {
        case .HomeCategoryCellItem(let category):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeCategoryCell.identifier,
                for: indexPath
            ) as! HomeCategoryCell

            cell.bind(to: HomeCategoryCellViewModel(category: category))

            return cell

        case .Section1(let section1):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeSection1Cell.identifier,
                for: indexPath
            ) as! HomeSection1Cell

            cell.bind(to: HomeSection1CellViewModel(section1: section1))

            return cell

        case .Empty(let empty):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeEmptyCell.identifier,
                for: indexPath
            ) as! HomeEmptyCell

            return cell

        case .Section2(let section2):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeSection2Cell.identifer,
                for: indexPath
            ) as! HomeSection2Cell

            cell.bind(to: HomeSection2CellViewModel(section2: section2))

            return cell
        }
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        guard kind == UICollectionView.elementKindSectionHeader,
              indexPath.section == 1 || indexPath.section == 3
        else {
            return UICollectionReusableView()
        }

        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HomeHeaderView.identifer,
            for: indexPath
        ) as! HomeHeaderView
        let headerTitle = dataSource.sectionModels[indexPath.section].header

        headerView.titleLabel.text = headerTitle

        return headerView
    })

    // MARK: - Binding

    private func bind() {
        searchBarButtonItem.rx.tap
            .bind(to: viewModel.didTapSearchBarButtonItem)
            .disposed(by: disposeBag)

        heartBarButtonItem.rx.tap
            .bind(to: viewModel.didTapHeartBarButtonItem)
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .bind(to: viewModel.didTapCollectionViewItem)
            .disposed(by: disposeBag)

        viewModel.homeItems
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - Initializing

    init() {
        super.init(nibName: nil, bundle: nil)

//        rx.viewDidLoad
//            .bind(to: viewModel.viewDidLoad)
//            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setUI()
        bind()
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
        let layout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            switch section {
            case 0:
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
