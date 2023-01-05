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
    var profiles: BehaviorRelay<[BPProfileModel]>
    var products: BehaviorRelay<[BPProductModel]>
    var provider: BPContentCellServiceProtocol = BPContentCellService()
    
    init(contentModel: BPContentModel) {
        self.contentModel = .init(value: contentModel)
        profiles = .init(value: provider.fetchProfiles())
        products = .init(value: provider.fetchProducts())
    }
}

final class JHBPContentCell: BPBaseCollectionViewCell {
    enum Reusable {
        static let profileCell = ReusableCell<BPProfileCell>()
        static let productCell = ReusableCell<BPProductCell>()
    }
    
    enum JHBPContentType: Int, CaseIterable {
        case profile, product
    }
    
    func bind(viewModel: JHBPContentCellViewModel) {
        [productCollectionView, profileCollectionView]
            .forEach { $0.rx.setDelegate(self).disposed(by: disposeBag) }
        
        viewModel.profiles
            .withLatestFrom(viewModel.contentModel) { ($0, $1) }
            .filter { $0.1.order == 0 }
            .map { $0.0 }
            .bind(to: profileCollectionView.rx.items(Reusable.profileCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                
                self.setCollectionViewHidden(forType: .profile)

                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
        
        viewModel.products
            .withLatestFrom(viewModel.contentModel) { ($0, $1) }
            .filter { $0.1.order == 1 }
            .map { $0.0 }
            .bind(to: productCollectionView.rx.items(Reusable.productCell)) { [weak self] index, item, cell in
                guard let self = self else { return }
                self.setCollectionViewHidden(forType: .product)
                
                cell.configureCell(with: item)
            }.disposed(by: self.disposeBag)
    }
    
    
    func setCollectionViewHidden(forType type: JHBPContentType) {
        [profileCollectionView,
         productCollectionView].enumerated().forEach { index, view in
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
    }
    
    func createLayout(forType type: JHBPContentType) -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection in
            
            // 🐻‍❄️ NOTE: - Int값으로 Section 반환하도록 나중에 리팩토링하기
            switch type {
            case .profile: return self.profileLayoutSection()
            case .product: return self.productLayoutSection()
            }
        }
    }
    
    private func profileLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(100)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .estimated(100)),
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
}

