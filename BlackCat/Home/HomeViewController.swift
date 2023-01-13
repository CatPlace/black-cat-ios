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

    let disposeBag = DisposeBag()
    enum Reusable {
        static let categoryCell = ReusableCell<HomeCategoryCell>()
        static let recommendCell = ReusableCell<CommonTattooInfoCell>()
        static let emptyCell = ReusableCell<HomeEmptyCell>()
        static let tattooAlbumCell = ReusableCell<HomeTattooAlbumCell>()
        static let headerView = ReusableView<HomeHeaderView>()
    }

    // MARK: - Properties

    let viewModel = HomeViewModel()
    private let dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>(
        configureCell: { _, collectionView, indexPath, item in
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
            guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
            let headerView = collectionView.dequeue(Reusable.headerView, kind: .header, for: indexPath)
            let headerType = dataSource.sectionModels[indexPath.section].header

            switch headerType {
            case .empty, .image(_): // 이미지 header가 없어서 디폴트로 반환합니다.
                return UICollectionReusableView()
            case .title(let title):
                headerView.titleLabel.text = title
            }

            return headerView
        })

    // MARK: - Binding

    private func bind() {
        
        // MARK: - Action

        rx.viewDidLoad
            .bind(to: viewModel.viewDidLoad)
            .disposed(by: disposeBag)
        
        viewModel.viewDidLoad
            .debug("유저")
            .bind {
            print(CatSDKUser.user())
        }.disposed(by: disposeBag)
        
        collectionView.rx.nextFetchPage
            .bind(to: viewModel.nextFetchPage)
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

        viewModel.pushToGenreViewController
            .debug()
            .drive(with: self) { owner, genre in
                let genreViewController = GenreViewController(viewModel: .init(genre: genre))
                genreViewController.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(genreViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.pushToBookmarkViewController
            .drive(with: self) { owner, _ in
                let bookmarkViewController = BookmarkViewController()
                owner.navigationController?.pushViewController(bookmarkViewController, animated: true)
            }
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
        let  cv = UICollectionView(frame: .zero,
                                   collectionViewLayout: compositionalLayout)

        cv.backgroundColor = .init(hex: "#F4F4F4FF")
        cv.register(Reusable.categoryCell)
        cv.register(Reusable.recommendCell)
        cv.register(Reusable.emptyCell)
        cv.register(Reusable.tattooAlbumCell)
        cv.register(Reusable.headerView, kind: .header)

        cv.showsVerticalScrollIndicator = false
        return  cv
    }()

    lazy var compositionalLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            guard let sectionType = HomeCompositionalLayoutSection(rawValue: section) else { return nil }
            return sectionType.createLayout()
        }

        layout.register(HomeCategorySectionBackgroundReusableView.self,
                        forDecorationViewOfKind: HomeCategorySectionBackgroundReusableView.identifier)

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


