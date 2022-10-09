//
//  MagazineViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/05.
//

import UIKit

import RxSwift
import RxDataSources

extension MagazineSection: SectionModelType {
    typealias Item = MagazineItem
    
    init(original: MagazineSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}

class MagazineViewController: UIViewController {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = MagazineViewModel()
    var magazineCollectionViewInset = PublishSubject<CGFloat>()
    let famousSectionHeight = UIScreen.main.bounds.width * (500 / 375.0) * 1.05
    // 섹션마다 다른셀을 주기 위해 rxDataSource사용
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MagazineSection> { dataSource, collectionView, indexPath, item in
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
    }
    
    // MARK: - Binding
    func bind() {
        viewModel.magazineDriver
            .drive(magazineCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
//        
//        viewModel.fetchedMagazineItems
//            .bind(to: magazineCollectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        
//        magazineCollectionViewInset.distinctUntilChanged()
//            .withUnretained(self)
//            .observe(on: MainScheduler.instance)
//            .subscribe { owner, inset in
//                owner.magazineCollectionView.contentInset = .init(top: inset, left: 0, bottom: 0, right: 0)
//                owner.headerMarginView.isHidden = inset == 0
//            }.disposed(by: disposeBag)
        
        magazineCollectionView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] contentOffset in
                guard let self else { return }
                
                // 96(디자이너 요청 픽셀) - 70(두번째 섹션 헤더 크기)
//                let inset: CGFloat = 96 - 70
                
                // 기본 tableView section header로 스크롤시 header 고정은 시켰지만 좀더 아래에 고정시키고 싶어서 사용
//                if contentOffset.y > self.famousSectionHeight  - inset {
//                    self.magazineTableViewTopInset.onNext(inset)
//                } else {
//                    self.magazineTableViewTopInset.onNext(0)
//                }
                
                // 페이지 네이션
                if contentOffset.y > self.magazineCollectionView.contentSize.height - self.view.frame.height * 1.5 {
                    self.viewModel.updateMagazineTrigger.accept(1)
                }
                
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
        let layout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            switch section {
            case 0:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(500 / 375.0)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(500 / 375.0)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                return section
            case 1:
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
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(70)
                )
                //                 let header = NSCollectionLayoutBoundarySupplementaryItem(
                //                     layoutSize: headerSize,
                //                     elementKind: UICollectionView.elementKindSectionHeader,
                //                     alignment: .top
                //                 )
                //                 header.contentInsets = .init(top: 0, leading: 9.5, bottom: 0, trailing: 0)
                //
                //                 section.boundarySupplementaryItems = [header]
                return section
            default:
                return nil
            }
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(RecentMagzazineCell.self, forCellWithReuseIdentifier: RecentMagzazineCell.self.description())
        cv.register(LastMagazineCell.self, forCellWithReuseIdentifier: LastMagazineCell.self.description())
        return cv
    }()
    
}

extension MagazineViewController {
    
    func setUI() {
        [magazineCollectionView, headerMarginView].forEach {
            view.addSubview($0)
        }
        
        magazineCollectionView.contentInsetAdjustmentBehavior = .never
        //        magazineCollectionView.separatorStyle = .none
        
        magazineCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        //        headerMarginView.backgroundColor = .systemBackground
        //
        //        headerMarginView.snp.makeConstraints {
        //            $0.top.leading.trailing.equalToSuperview()
        //            $0.height.equalTo(26)
        //        }
        
        //        [magazineFamousCollectionView, magazineFamouspageControl].forEach {
        //            contentView.addSubview($0)
        //        }
        //        magazineFamouspageControl.tintColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1)
        //        magazineFamouspageControl.currentPageTintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        //        magazineFamouspageControl.progress = 0.5
        //        magazineFamouspageControl.set(progress: 0, animated: false)
        //        magazineFamouspageControl.radius = 3
        //        magazineFamouspageControl.elementWidth = 30
        //        magazineFamouspageControl.snp.makeConstraints {
        //            $0.centerX.equalToSuperview()
        //            $0.bottom.equalToSuperview()
        //            $0.height.equalTo(UIScreen.main.bounds.width * (500 / 375.0) * 0.05)
        //        }
        //
        //        magazineFamousCollectionView.snp.makeConstraints {
        //            $0.leading.trailing.top.equalToSuperview()
        //            $0.bottom.equalTo(magazineFamouspageControl.snp.top)
        //        }
        
    }
}
//
//extension MagazineViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section != 1 { return UIView() }
//        let headerView = UIView()
//        headerView.backgroundColor = .systemBackground
//
//        let titleLabel = UILabel()
//        headerView.addSubview(titleLabel)
//
//        titleLabel.text = "지난 이야기"
//        titleLabel.font = .boldSystemFont(ofSize: 20)
//
//        titleLabel.snp.makeConstraints {
//            $0.bottom.equalToSuperview().inset(10)
//            $0.leading.equalToSuperview().inset(20)
//        }
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        section == 1
//        ? 70
//        : .leastNonzeroMagnitude
//    }
//
//}
