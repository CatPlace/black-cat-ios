//
//  MagazineViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import UIKit

import RxSwift
import RxDataSources
import RxRelay
import BlackCatSDK


enum MagazineSectionType: Int {
    case recentMagazine = 0
    case lastMagazine = 1
}

enum Reusable {
    static let recentMagazineCell = ReusableCell<RecentMagazineCell>()
    static let recentMagazineFooterView = ReusableView<RecentMagazineFooterView>()
    static let lastMagazineHeaderView = ReusableView<LastMagazineHeaderView>()
    static let lastMagazinecell = ReusableCell<LastMagazineCell>()
}

class MagazineViewController: UIViewController {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = MagazineViewModel()
    
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MagazineSection> (
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .topSection(let viewModel):
                let cell = collectionView.dequeue(Reusable.recentMagazineCell,
                                                  for: indexPath)
                cell.viewModel = viewModel
                
                return cell
            case .lastStorySection(let viewModel):
                let cell = collectionView.dequeue( Reusable.lastMagazinecell,
                                                   for: indexPath)
                
                cell.viewModel = viewModel
                
                return cell
            }
        },
        configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            
            let sectionType = MagazineSectionType(rawValue: indexPath.section)
            
            switch (sectionType, kind) {
            case (.recentMagazine, UICollectionView.elementKindSectionFooter):
                let footerView = collectionView.dequeue(Reusable.recentMagazineFooterView,
                                                        kind: .footer,
                                                        for: indexPath)
                guard let self else { return UICollectionReusableView() }
                guard let v = self.footerView else {
                    self.footerView = footerView
                    // 임시로 최근 매거진 4개로 해두었습니다.
                    self.footerView?.viewModel = .init(currentPage: 0,
                                                       numberOfPages: 4)
                    return self.footerView!
                }
                return v
            case (.lastMagazine, UICollectionView.elementKindSectionHeader):
                let headerView = collectionView.dequeue(
                    Reusable.lastMagazineHeaderView,
                    kind: .header,
                    for: indexPath
                )
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        })
    
    // MARK: - Binding
    func bind() {
        viewModel.magazineDriver
            .drive(magazineCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        magazineCollectionView.rx.contentOffset
            .observe(on:MainScheduler.asyncInstance)
            .withUnretained(self)
            .map { owner, contentOffset in
                (contentOffset.y, owner.view.frame.width * 500 / 375.0)
            }
            .bind(to: viewModel.magazineCollectionViewScrollOffsetY)
            .disposed(by: disposeBag)
        
        viewModel.magazineCollectionViewTopInsetDriver
            .drive { [weak self] inset in
                self?.magazineCollectionView.contentInset = .init(top: inset, left: 0, bottom: 0, right: 0)
                self?.headerMarginView.isHidden = inset == 0
            }.disposed(by: disposeBag)
        
        viewModel.magazineCollectionViewScrollOffsetYDriver
            .filter { $0 > self.magazineCollectionView.contentSize.height - self.view.frame.height * 1.5 }
            .map { _ in 1 }
            .drive(viewModel.updateMagazineTrigger)
            .disposed(by: disposeBag)
        
        viewModel.recentSectionPageControlValuesDriver
            .drive { [weak self] numberOfPages, currentPage in
                self?.footerView?.viewModel = .init(currentPage: currentPage,
                                                    numberOfPages: numberOfPages)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = navigationAppearance
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "heart"),
                            style: .plain,
                            target: self,
                            action: nil),
            UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                            style: .plain,
                            target: self,
                            action: nil)
        ]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - UIComponents
    let headerMarginView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.isHidden = true
        return v
    }()
    lazy var magazineCollectionView: UICollectionView = { [unowned self] in
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        cv.register(Reusable.recentMagazineCell)
        cv.register(Reusable.recentMagazineFooterView, kind: .footer)
        cv.register(Reusable.lastMagazineHeaderView, kind: .header)
        cv.register(Reusable.lastMagazinecell)
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()
    var footerView: RecentMagazineFooterView?
}

extension MagazineViewController {
    
    func setUI() {
        [magazineCollectionView, headerMarginView].forEach {
            view.addSubview($0)
        }
        
        magazineCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        headerMarginView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(26)
        }
    }
}

extension MagazineViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            
            let sectionType = MagazineSectionType(rawValue: section)
            
            switch sectionType {
            case .recentMagazine:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(500 / 375.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(500 / 375.0)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(26)
                    ),
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                section.boundarySupplementaryItems = [footer]
                section.visibleItemsInvalidationHandler = { [weak self] (_, offset, _) -> Void in
                    guard let self else { return }
                    self.viewModel.recentMagazineSectionScrollOffsetX.accept((offset.x, self.view.frame.width))
                }
                return section
            case .lastMagazine:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth((248 / 187.0) * 0.5)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth((248 / 187.0) * 0.5)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitem: item,
                                                               count: 2)
                group.interItemSpacing = .fixed(1)
                
                let section = NSCollectionLayoutSection(group: group)
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(70)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.pinToVisibleBounds = true
                
                section.boundarySupplementaryItems = [header]
                
                return section
            default:
                return nil
            }
        }
    }
}
