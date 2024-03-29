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

// TODO: - 2023.01.20
// 1. Category -> Genre 네이밍 변경
// 2. CategoryCell, ViewModel 글로벌하게

class HomeViewController: UIViewController {

    let disposeBag = DisposeBag()
    enum Reusable {
        static let genreCell = ReusableCell<HomeGenreCell>()
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
            case .genreCell(let genreCellViewModel):
                let cell = collectionView.dequeue(Reusable.genreCell, for: indexPath)

                cell.bind(to: genreCellViewModel)
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
        
        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        collectionView.rx.nextFetchPage
            .bind(to: viewModel.nextFetchPage)
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .bind(to: viewModel.didTapCollectionViewItem)
            .disposed(by: disposeBag)

        // MARK: - State

        viewModel.homeItems
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refreshTrigger)
            .disposed(by: disposeBag)
            
        viewModel.refreshEndDriver
            .drive { _ in
                self.refreshControl.endRefreshing()
            }.disposed(by: disposeBag)
        
        viewModel.pushToGenreViewController
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
        
        viewModel.pushToTattooDetailViewController
            .drive(with: self) { owner, tattooId in
                let vc = TattooDetailViewController(viewModel: .init(tattooId: tattooId))
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
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
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackgroundColor(color: .clear)
    }
    
    // MARK: - UIComponents
    let refreshControl = UIRefreshControl()
    let topView: UIView = {
        $0.backgroundColor = .white
        $0.layer.applyShadow(color: .black, alpha: 0.15, x: 0, y: 2, blur: 40)
        return $0
    }(UIView())
    let leftTitleBarButtonItem: UIBarButtonItem = {
        let label = UILabel()
        label.text = "Black Cat"
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 32)
        return UIBarButtonItem(customView: label)
    }()
    
    lazy var collectionView: UICollectionView = {
        let  cv = UICollectionView(frame: .zero,
                                   collectionViewLayout: compositionalLayout)

        cv.backgroundColor = .init(hex: "#F4F4F4FF")
        cv.register(Reusable.genreCell)
        cv.register(Reusable.recommendCell)
        cv.register(Reusable.emptyCell)
        cv.register(Reusable.tattooAlbumCell)
        cv.register(Reusable.headerView, kind: .header)

        cv.showsVerticalScrollIndicator = false
        refreshControl.endRefreshing()
        cv.refreshControl = refreshControl
        return  cv
    }()

    lazy var compositionalLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            guard let sectionType = HomeCompositionalLayoutSection(rawValue: section) else { return nil }
            return sectionType.createLayout()
        }

        layout.register(HomeGenreSectionBackgroundReusableView.self,
                        forDecorationViewOfKind: HomeGenreSectionBackgroundReusableView.identifier)

        return layout
    }()
}

extension HomeViewController {
    private func setNavigationBar() {
        let label = UILabel()
        label.text = "Black Cat"
        label.font = .didotFont(size: 32, style: .bold)
        label.textColor = .init(hex: "#333333FF")
        appendNavigationLeftCustomView(label)
    }

    private func setUI() {
        view.addSubview(collectionView)
        [collectionView, topView].forEach { view.addSubview($0) }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        topView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
    }
}
