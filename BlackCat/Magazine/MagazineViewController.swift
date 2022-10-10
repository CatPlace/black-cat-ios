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
//import BlackCatSDK

class MagazineViewController: UIViewController {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = MagazineViewModel()
    let magazineCollectionViewInset = PublishRelay<CGFloat>()
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MagazineSection> (
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .topSection(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentMagzazineCell.self.description(), for: indexPath) as? RecentMagzazineCell
                else { return UICollectionViewCell() }
                
                cell.viewModel = viewModel
                
                return cell
            case .lastStorySection(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LastMagazineCell.self.description(), for: indexPath) as? LastMagazineCell else { return UICollectionViewCell() }
                
                cell.viewModel = viewModel
                
                return cell
            }
        },
        configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            switch (indexPath.section, kind) {
            case (0, UICollectionView.elementKindSectionFooter):
                guard let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RecentMagazineFooterView.self.description(),
                    for: indexPath
                ) as? RecentMagazineFooterView else { return UICollectionReusableView() }
                guard let self else { return UICollectionReusableView() }
                guard let v = self.footerView else {
                    self.footerView = footerView
                    // 임시로 최근 매거진 4개로 해두었습니다.
                    self.footerView?.viewModel = .init(currentPage: 0, numberOfPages: 4)
                    return self.footerView!
                }
                return v
                
            case (1, UICollectionView.elementKindSectionHeader):
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: LastMagazineHeaderView.self.description(),
                    for: indexPath
                ) as? LastMagazineHeaderView else { return UICollectionReusableView() }
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
        
        magazineCollectionViewInset.distinctUntilChanged()
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe { owner, inset in
                owner.magazineCollectionView.contentInset = .init(top: inset, left: 0, bottom: 0, right: 0)
                owner.headerMarginView.isHidden = inset == 0
            }.disposed(by: disposeBag)
        
        magazineCollectionView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] contentOffset in
                guard let self else { return }
                
                // 96(디자이너 요청 픽셀) - 70(두번째 섹션 헤더 크기)
                let inset: CGFloat = 96 - 70
                // 기본 tableView section header로 스크롤시 header 고정은 시켰지만 좀더 아래에 고정시키고 싶어서 사용
                if contentOffset.y > self.view.frame.width * 500 / 375.0 {
                    self.magazineCollectionViewInset.accept(inset)
                } else {
                    self.magazineCollectionViewInset.accept(0)
                }
                
                // 페이지 네이션
                if contentOffset.y > self.magazineCollectionView.contentSize.height - self.view.frame.height * 1.5 {
                    self.viewModel.updateMagazineTrigger.accept(1)
                }
                
            }.disposed(by: disposeBag)
        
        viewModel.recentSectionPageControlValuesDriver
            .drive { [weak self] numberOfPages, currentPage in
                self?.footerView?.viewModel = .init(currentPage: currentPage, numberOfPages: numberOfPages)
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
            UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: nil)
        ]
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - UIComponents
    let headerMarginView = UIView()
    let magazineCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.register(RecentMagzazineCell.self, forCellWithReuseIdentifier: RecentMagzazineCell.self.description())
        cv.register(RecentMagazineFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RecentMagazineFooterView.self.description())
        
        cv.register(LastMagazineHeaderView.self, forSupplementaryViewOfKind:  UICollectionView.elementKindSectionHeader, withReuseIdentifier: LastMagazineHeaderView.self.description())
        cv.register(LastMagazineCell.self, forCellWithReuseIdentifier: LastMagazineCell.self.description())
        return cv
    }()
    var footerView: RecentMagazineFooterView?
}

extension MagazineViewController {
    
    func setUI() {
        [magazineCollectionView, headerMarginView].forEach {
            view.addSubview($0)
        }
        
        magazineCollectionView.contentInsetAdjustmentBehavior = .never
        magazineCollectionView.collectionViewLayout = createLayout()
        
        magazineCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        headerMarginView.backgroundColor = .systemBackground
        
        headerMarginView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(26)
        }
    }
}

enum MagazineSectionType: Int {
    case recentMagazine = 0
    case lastMagazine = 1
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
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
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
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
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
