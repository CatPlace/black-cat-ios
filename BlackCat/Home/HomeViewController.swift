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
        static let tattooAlbumCell = ReusableCell<HomeTattooAlbumCell>()
        static let headerView = ReusableView<HomeHeaderView>()
    }

    // MARK: - Properties

    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .categoryCell(let categoryCellViewModel):
                let cell = collectionView.dequeue(Reusable.categoryCell, for: indexPath)

                cell.bind(to: categoryCellViewModel)
                return cell
            case .recommendCell(let recommendCellViewModel):
                let cell = collectionView.dequeue(Reusable.recommendCell, for: indexPath)

                cell.bind(to: recommendCellViewModel)
                return cell
            case .emptyCell(let empty):
                let cell = collectionView.dequeue(Reusable.emptyCell, for: indexPath)
                return cell
            case .allTattoosCell(let tattooAlbumCellViewModel):
                let cell = collectionView.dequeue(Reusable.tattooAlbumCell, for: indexPath)

                cell.bind(to: tattooAlbumCellViewModel)
                return cell
            }
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            guard kind == UICollectionView.elementKindSectionHeader,
                  indexPath.section == 1 || indexPath.section == 3 else { return UICollectionReusableView() }

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
        setNavigationBar()
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        collectionView.register(Reusable.tattooAlbumCell)
        collectionView.register(Reusable.headerView, kind: .header)

        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    lazy var compositionalLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            guard let sectionType = HomeCompositionalLayoutSection(rawValue: section) else { return nil }
            return sectionType.createLayout()
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
        navigationItem.rightBarButtonItems = [heartBarButtonItem,
                                              searchBarButtonItem]
    }

    private func setUI() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

