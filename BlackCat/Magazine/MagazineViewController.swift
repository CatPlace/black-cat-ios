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

class MagazineViewController: UIViewController {
    enum MagazineSectionType: Int {
        case recentMagazine
        case lastMagazine
    }

    enum Reusable {
        static let recentMagazineCell = ReusableCell<RecentMagazineCell>()
        static let recentMagazineFooterView = ReusableView<RecentMagazineFooterView>()
        static let lastMagazineHeaderView = ReusableView<LastMagazineHeaderView>()
        static let lastMagazinecell = ReusableCell<LastMagazineCell>()
    }
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let viewModel = MagazineViewModel()

    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MagazineSection> (
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .topSection(let viewModel):
                let cell = collectionView.dequeue(Reusable.recentMagazineCell, for: indexPath)
                cell.viewModel = viewModel
                return cell
            case .lastStorySection(let viewModel):
                let cell = collectionView.dequeue(Reusable.lastMagazinecell, for: indexPath)
                cell.viewModel = viewModel
                return cell
            }
        },
        configureSupplementaryView: { [weak self] _, collectionView, kind, indexPath -> UICollectionReusableView in
            
            guard let sectionType = MagazineSectionType(rawValue: indexPath.section), let self else { return UICollectionReusableView() }
            
            switch sectionType {
            case .recentMagazine:
                let footerView = collectionView.dequeue(Reusable.recentMagazineFooterView, kind: .footer, for: indexPath)
                guard let v = self.footerView else {
                    self.footerView = footerView
                    // 임시로 최근 매거진 4개로 해두었습니다.
                    self.footerView?.viewModel = .init(currentPage: 0,
                                                       numberOfPages: 4)
                    return self.footerView!
                }
                return v
            case .lastMagazine:
                return collectionView.dequeue(Reusable.lastMagazineHeaderView, kind: .header, for: indexPath)
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
            }.bind(to: viewModel.magazineCollectionViewScrollOffsetY)
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
    lazy var magazineCollectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        [magazineCollectionView, headerMarginView].forEach { view.addSubview($0) }
        
        magazineCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        headerMarginView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(26)
        }
    }
}

