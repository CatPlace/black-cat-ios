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
    var contentModel: BehaviorRelay<BPContentModel> // 🐻‍❄️ NOTE: - 이거 enum으로 개선가능
    
    typealias Introduce = String
    typealias ProductImageUrlString = String
    typealias PriceInfo = String
    var profiles: Driver<[Introduce]>
    var products: Driver<[ProductImageUrlString]>
    var priceInfos: Driver<[PriceInfo]>
    
    init(contentModel: BPContentModel, profile: Introduce, products: [ProductImageUrlString], priceInfo: PriceInfo) {
        self.contentModel = .init(value: contentModel)

        self.profiles = self.contentModel
            .filter { $0.order == 0 }
            .map { _ in [profile] }
            .asDriver(onErrorJustReturn: [])
        
        self.products = self.contentModel
            .filter { $0.order == 1 }
            .map { _ in products }
            .asDriver(onErrorJustReturn: [])
        
        self.priceInfos = self.contentModel
            .filter { $0.order == 2 }
            .map { _ in [priceInfo] }
            .debug("💡💡💡")
            .asDriver(onErrorJustReturn: [])
    }
}

final class JHBPContentCell: BPBaseCollectionViewCell {
    enum Reusable {
        static let profileCell = ReusableCell<BPProfileCell>()
        static let productCell = ReusableCell<BPProductCell>()
        static let priceInfoCell = ReusableCell<JHBPPriceInfoCell>()
    }
    
    enum JHBPContentType: Int, CaseIterable {
        case profile, product, priceInfo
    }
    
    func bind(viewModel: JHBPContentCellViewModel) {
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
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        viewModel.priceInfos
            .debug("셀 그려")
            .drive(priceInfoCollectionView.rx.items(Reusable.priceInfoCell)) { [weak self] index, item, cell in
                print("item~.map { ($0.0, $0.1) }")
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .priceInfo)

                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
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
        cv.register(Reusable.profileCell)
        
        return cv
    }()
    
    lazy var productCollectionView: UICollectionView = {
        let layout = createLayout(forType: .product)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.register(Reusable.productCell)
        
        return cv
    }()
    
    lazy var priceInfoCollectionView: UICollectionView = {
        let layout = createLayout(forType: .priceInfo)
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        cv.register(Reusable.priceInfoCell)
        
        return cv
    }()
}

extension JHBPContentCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 🐻‍❄️ NOTE: - 막지말고, 차라리 당겨서 해당 셀을 refresh하는건 어떨까요?
        // NOTE: - delegateProxy를 사용하는 방법도 있겠습니다.
        
        scrollView.bounces = scrollView.contentOffset.y >= 0
        JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
            delegate.notifyViewController(offset: scrollView.contentOffset.y)
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
        return UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection in
            
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

