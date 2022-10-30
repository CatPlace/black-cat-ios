//
//  BPContentHeaderView.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import UIKit
import ReactorKit
import PinLayout
import FlexLayout

class BPContentSectionHeaderView: BPBaseCollectionReusableView, View {
    typealias Reactor = BPContentSectionHeaderReactor
    
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        profileButton.rx.tap.map { Reactor.Action.didTapProfile }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        productButton.rx.tap.map { Reactor.Action.didTapProduct }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reviewButton.rx.tap.map { Reactor.Action.didTapReview }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        infoButton.rx.tap.map { Reactor.Action.didTapInfo }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    private func render(reactor: Reactor) {
        reactor.state.map { $0.selectedButton }
            .bind(with: self) { owner, type in
                owner.updateButtonUI(type: type)
                owner.notifyCollectionView(type: type)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func updateButtonUI(type: BPContentHeaderButtonType) {
        let buttonTitle = type.rawValue
        
        // MARK: - 같은거 찾기
        if buttonTitle == profileButton.title(for: .normal) { profileButton.isSelected = true }
        if buttonTitle == productButton.title(for: .normal) { productButton.isSelected = true }
        if buttonTitle == reviewButton.title(for: .normal) { reviewButton.isSelected = true }
        if buttonTitle == infoButton.title(for: .normal) { infoButton.isSelected = true }
        
        // MARK: - 다른거 찾기
        if buttonTitle != profileButton.title(for: .normal) { profileButton.isSelected = false }
        if buttonTitle != productButton.title(for: .normal) { productButton.isSelected = false }
        if buttonTitle != reviewButton.title(for: .normal) { reviewButton.isSelected = false }
        if buttonTitle != infoButton.title(for: .normal) { infoButton.isSelected = false }
    }
    
    private func notifyCollectionView(type: BPContentHeaderButtonType) {
        let buttonTitle = type.rawValue
        
        // MARK: - 이벤트 발생시키기
        if buttonTitle == profileButton.title(for: .normal) {
            BPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                delegate.notifyContentCell(indexPath: nil, forType: .profile)
            }
        }
            
        if buttonTitle == productButton.title(for: .normal) {
            BPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                delegate.notifyContentCell(indexPath: nil, forType: .product)
            }
        }
        
        if buttonTitle == reviewButton.title(for: .normal) {
            BPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                delegate.notifyContentCell(indexPath: nil, forType: .review)
            }
        }
        
        if buttonTitle == infoButton.title(for: .normal) {
            BPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                delegate.notifyContentCell(indexPath: nil, forType: .info)
            }
        }
    }
    
    // MARK: - Initalize
    override func initalize() {
        super.initalize()
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.row)
            .justifyContent(.spaceEvenly)
            .alignItems(.center)
            .define { flex in
                flex.addItem(profileButton).grow(1)
                flex.addItem(productButton).grow(1)
                flex.addItem(reviewButton).grow(1)
                flex.addItem(infoButton).grow(1)
            }
        
        // MARK: - 멀티캐스트 딜리게이트 추가
        BPDispatchSystem.dispatch.multicastDelegate.addDelegate(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rootFlexContainer.pin.all()
        self.rootFlexContainer.flex.layout()
    }
    
    // MARK: - UIComponents
    let rootFlexContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
    
    enum BPContentHeaderButtonType: String {
        case profile = "프로필"
        case product = "작품 보기"
        case review = "후기"
        case info = "견적 안내"
        
        func toString() -> String {
            switch self {
            case .profile: return rawValue
            case .product: return rawValue
            case .review: return rawValue
            case .info: return rawValue
            }
        }
    }
    
    private lazy var profileButton: UIButton = {
        $0.setTitle(BPContentHeaderButtonType.profile.toString(), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(.gray, for: .normal)
        return $0
    }(UIButton())
    
    private lazy var productButton: UIButton = {
        $0.setTitle(BPContentHeaderButtonType.product.toString(), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(.gray, for: .normal)
        return $0
    }(UIButton())
    
    private lazy var reviewButton: UIButton = {
        $0.setTitle(BPContentHeaderButtonType.review.toString(), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(.gray, for: .normal)
        return $0
    }(UIButton())
    
    private lazy var infoButton: UIButton = {
        $0.setTitle(BPContentHeaderButtonType.info.toString(), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(.gray, for: .normal)
        return $0
    }(UIButton())
    
}

extension BPContentSectionHeaderView: BPMulticastDelegate {
    func notifyContentHeader(indexPath: IndexPath, forType: type) { 
        print("🐬")
        var forType = forType
        // MARK: - 싱크 맞추기
        switch indexPath.row {
        case 0: forType = .profile
        case 1: forType = .product
        case 2: forType = .review
        case 3: forType = .info
        default: forType = .profile
        }
        
        updateButtonUI(type: forType)
    }
}
