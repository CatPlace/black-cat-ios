//
//  JHBPContentCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SnapKit
import BlackCatSDK

final class JHBPContentCellViewModel {
    typealias Introduce = String
    typealias ProductImageUrlString = String
    typealias PriceInfo = String
    
    var deleteTattoIndexListRelay = BehaviorRelay<[Int]>(value: [])
    
    var contentModel: BehaviorRelay<BPContentModel> // 🐻‍❄️ NOTE: - 이거 enum으로 개선가능
    var editMode: BehaviorRelay<EditMode>
    var productSelectIndexPath = PublishRelay<IndexPath>()
    
    var profiles: Driver<[Introduce]>
    var products: Driver<[BPProductCellViewModel]>
    var priceInfos: Driver<[PriceInfo]>
    
    var notifyToViewController: Driver<IndexPath>
    var editModeDriver: Driver<EditMode>
    
    typealias UpdatedDeleteTattoIndexList = [Int]
    typealias ShouldCountDownIndexPathList = [Int]
    typealias ShouldToggleIndexPath = IndexPath
    
    var countDownDriver: Driver<(UpdatedDeleteTattoIndexList, ShouldCountDownIndexPathList, ShouldToggleIndexPath)>
    var setCountDriver: Driver<(UpdatedDeleteTattoIndexList, ShouldToggleIndexPath)>
    
    init(contentModel: BPContentModel, profile: Introduce, products: [Model.TattooThumbnail], priceInfo: PriceInfo, editMode: BehaviorRelay<EditMode> = .init(value: .normal)) {
        self.editMode = editMode
        self.contentModel = .init(value: contentModel)
        
        self.profiles = self.contentModel
            .filter { $0.order == 0 }
            .map { _ in [profile] }
            .asDriver(onErrorJustReturn: [])
        
        self.products = self.contentModel
            .filter { $0.order == 1 }
            .map { _ in products.map { .init(editMode: editMode, product: $0) } }
            .asDriver(onErrorJustReturn: [])
        
        self.priceInfos = self.contentModel
            .filter { $0.order == 2 }
            .map { _ in [priceInfo] }
            .asDriver(onErrorJustReturn: [])
        
        notifyToViewController = productSelectIndexPath
            .withLatestFrom(editMode) { ($0, $1) }
            .filter { $0.1 == .normal }
            .map { $0.0 }
            .asDriver(onErrorJustReturn: .init(row: 0, section: 0))
        
        let didTapProductInEditMode = productSelectIndexPath
            .withLatestFrom(editMode) { ($0, $1) }
            .filter { $0.1 == .edit }
            .map { $0.0 }
        
        let tattooIndex = didTapProductInEditMode
            .withLatestFrom(deleteTattoIndexListRelay) { ($0, $1) }
            .map { (findedTattooIndex: $0.1.firstIndex(of: $0.0.row), tattooIndexPath: $0.0, deleteTattooIndexList: $0.1) }
            .share()
        
        
        setCountDriver = tattooIndex
            .filter { $0.findedTattooIndex == nil }
            .map { _, tattooIndexPath, deleteTattooIndexList in
                var temp = deleteTattooIndexList
                temp.append(tattooIndexPath.row)
                return (temp, tattooIndexPath)
            }.asDriver(onErrorJustReturn: ([], .init(row: 0, section: 0)))
        
        countDownDriver = tattooIndex
            .filter { $0.findedTattooIndex != nil }
            .map { index, tattooIndexPath, deleteTattooIndexList in
                guard let index else { return ([], [], []) } // 위에 필터링 했기 때문에 강제 언래핑 해도 상관 업습니다.
                var temp = deleteTattooIndexList
                temp.remove(at: index)
                return (temp, temp.enumerated().filter { i, value in i >= index }.map { $1 }, tattooIndexPath )
            }.asDriver(onErrorJustReturn: ([], [], []))
        
        editModeDriver = editMode
            .filter { _ in contentModel.order == 1 }
            .asDriver(onErrorJustReturn: .normal)
    }
}

final class JHBPContentCell: BPBaseCollectionViewCell {
    var viewModel: JHBPContentCellViewModel?
    
    enum Reusable {
        static let profileCell = ReusableCell<BPProfileCell>()
        static let productCell = ReusableCell<BPProductCell>()
        static let priceInfoCell = ReusableCell<JHBPPriceInfoCell>()
    }
    
    enum JHBPContentType: Int, CaseIterable {
        case profile, product, priceInfo
    }
    
    func bind(viewModel: JHBPContentCellViewModel) {
        self.viewModel = viewModel
        [productCollectionView, profileCollectionView, priceInfoCollectionView]
            .forEach { $0.rx.setDelegate(self).disposed(by: disposeBag) }
        
        viewModel.profiles
            .drive(profileCollectionView.rx.items(Reusable.profileCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                
                self.setCollectionViewHidden(forType: .profile)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        viewModel.products
            .drive(productCollectionView.rx.items(Reusable.productCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .product)
                
                cell.bind(to: item)
            }.disposed(by: self.disposeBag)
        
        viewModel.priceInfos
            .drive(priceInfoCollectionView.rx.items(Reusable.priceInfoCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .priceInfo)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        productCollectionView.rx.itemSelected
            .withLatestFrom(viewModel.contentModel) { ($0, $1) }
            .filter { $0.1.order == 1 }
            .map { $0.0 }
            .bind(to: viewModel.productSelectIndexPath)
            .disposed(by: disposeBag)
        
        viewModel.notifyToViewController
            .drive { indexPath in
                JHBPDispatchSystem.dispatch.multicastDelegate
                    .invokeDelegates { delegate in
                        delegate.notifyViewController(selectedIndex: indexPath, forType: .product)
                    }
            }.disposed(by: disposeBag)
        
        viewModel.setCountDriver
            .drive(with: self) { owner, info in
                let shouldUpdateDeleteIndexList = info.0
                let indexPath = info.1
                guard let cell = owner.productCollectionView.cellForItem(at: indexPath) as? BPProductCell else { return }
                viewModel.deleteTattoIndexListRelay.accept(shouldUpdateDeleteIndexList)
                cell.viewModel?.isSelectEditViewRelay.accept(true)
                cell.viewModel?.editCountRelay.accept(shouldUpdateDeleteIndexList.count)
            }.disposed(by: disposeBag)
        
        viewModel.countDownDriver
            .drive(with: self) { owner, info in
                let shouldUpdateDeleteIndexList = info.0
                let countDownIndexList = info.1
                let cancelTattooIndexPath = info.2
                
                viewModel.deleteTattoIndexListRelay.accept(shouldUpdateDeleteIndexList)
                
                owner.updateTattooUI(countDownIndexList: countDownIndexList, cancelTattooIndexPath: cancelTattooIndexPath)
            }.disposed(by: disposeBag)
        
        viewModel.editModeDriver
            .drive(with: self) { owner, editMode in
                if editMode == .normal {
                    owner.initEditor()
                }
                JHBPDispatchSystem.dispatch.multicastDelegate
                    .invokeDelegates { delegate in
                        delegate.notifyViewController(editMode: editMode)
                    }
            }.disposed(by: disposeBag)
        
        viewModel.deleteTattoIndexListRelay
            .bind { indexList in
                JHBPDispatchSystem.dispatch.multicastDelegate
                    .invokeDelegates { delegate in
                        delegate.notifyViewController(currentDeleteProductIndexList: indexList)
                    }
            }.disposed(by: disposeBag)
    }
    
    func updateTattooUI(countDownIndexList: [Int], cancelTattooIndexPath: IndexPath ) {
        guard let cell = productCollectionView.cellForItem(at: cancelTattooIndexPath) as? BPProductCell else { return }
        
        countDownIndexList
            .map { IndexPath(row: $0, section: 0) }
            .compactMap { productCollectionView.cellForItem(at: $0) as? BPProductCell}
            .forEach {
                guard let preValue = $0.viewModel?.editCountRelay.value else { return }
                $0.viewModel?.editCountRelay.accept(preValue - 1)
            }
        cell.viewModel?.isSelectEditViewRelay.accept(false)
    }
    
    func initEditor() {
        viewModel?.deleteTattoIndexListRelay.value
            .compactMap {
                productCollectionView.cellForItem(at: .init(row: $0, section: 0)) as? BPProductCell
            }.forEach {
                $0.viewModel?.isSelectEditViewRelay.accept(false)
            }
        viewModel?.deleteTattoIndexListRelay.accept([])
    }
    
    func setCollectionViewHidden(forType type: JHBPContentType) {
        [profileCollectionView,
         productCollectionView,
         priceInfoCollectionView
        ].enumerated().forEach { index, view in
            view.isHidden = type.rawValue != index
        }
    }
    
    // MARK: - Initialize
    override func initialize() {
        self.setUI()
        JHBPDispatchSystem.dispatch.multicastDelegate.addDelegate(self)
    }
    
    // MARK: - LifeCycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    // MARK: - UIComponents
    lazy var profileCollectionView: UICollectionView = {
        let layout = createLayout(forType: .profile)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        cv.register(Reusable.profileCell)
        
        return cv
    }()
    
    lazy var productCollectionView: UICollectionView = {
        let layout = createLayout(forType: .product)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.register(Reusable.productCell)
        cv.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
        return cv
    }()
    
    lazy var priceInfoCollectionView: UICollectionView = {
        let layout = createLayout(forType: .priceInfo)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        cv.register(Reusable.priceInfoCell)
        
        return cv
    }()
}

extension JHBPContentCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 🐻‍❄️ NOTE: - 막지말고, 차라리 당겨서 해당 셀을 refresh하는건 어떨까요?
        // NOTE: - delegateProxy를 사용하는 방법도 있겠습니다.
        scrollView.bounces = scrollView.contentOffset.y > 0
        JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
            delegate.notifyViewController(offset: scrollView.contentOffset.y, didChangeSection: false)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
            delegate.notifyViewController(offset: scrollView.contentOffset.y, didChangeSection: false)
        }
    }
}

extension JHBPContentCell {
    func setUI() {
        // 🐻‍❄️ NOTE: - Pin + Flex로 추후에 넘어가기
        
        contentView.addSubview(profileCollectionView)
        profileCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(productCollectionView)
        productCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(priceInfoCollectionView)
        priceInfoCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func createLayout(forType type: JHBPContentType) -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] section, env -> NSCollectionLayoutSection? in
            guard let self else { return nil }
            // 🐻‍❄️ NOTE: - Int값으로 Section 반환하도록 나중에 리팩토링하기
            switch type {
            case .profile: return self.profileLayoutSection()
            case .product: return self.productLayoutSection()
            case .priceInfo: return self.priceInfoLayoutSection()
            }
        }
    }
    
    private func profileLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(600)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .estimated(600)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func productLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/3),
                                                            heightDimension: .fractionalWidth(1/3)))
        item.contentInsets = .init(top: 2, leading: 1, bottom: 2, trailing: 1)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalWidth(0.33)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func priceInfoLayoutSection() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(600)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .estimated(600)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}


extension JHBPContentCell: JHBPMulticastDelegate {
    func notifyCellCollectionView() -> EditMode? {
        guard let viewModel, viewModel.contentModel.value.order == 1 else { return nil }
        
        let nextEditMode = viewModel.editMode.value.toggle()
        viewModel.editMode.accept(nextEditMode)
        return nextEditMode
    }
}
