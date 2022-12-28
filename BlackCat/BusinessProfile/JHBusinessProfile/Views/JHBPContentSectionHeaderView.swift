//
//  JHBPContentSectionHeaderView.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
class JHBPBaseCollectionReusableView: UICollectionReusableView {
    var disposeBag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initalize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initalize() { /* overrider point */ }
}

final class JHBPContentSectionHeaderViewModel {
    typealias JHBPContentHeaderButtonType = JHBPContentSectionHeaderView.JHBPContentHeaderButtonType
    
    var selectedButton: BehaviorRelay<JHBPContentHeaderButtonType>
    
    init(selectedButton: JHBPContentHeaderButtonType = .profile) {
        self.selectedButton = .init(value: selectedButton)
    }
}

class JHBPContentSectionHeaderView: JHBPBaseCollectionReusableView{
    
    func bind(viewModel: JHBPContentSectionHeaderViewModel) {
        headerButtons.enumerated().forEach { index, button in
            button.rx.tap
                .compactMap { JHBPContentHeaderButtonType(rawValue: index) }
                .bind(to: viewModel.selectedButton)
                .disposed(by: disposeBag)
            
        }
        
        
        viewModel.selectedButton
            .bind(with: self) { owner, type in
                owner.updateButtonUI(type: type)
                owner.notifyCollectionView(type: type)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateButtonUI(type: JHBPContentHeaderButtonType) {
        
        headerButtons.enumerated().forEach { index, button in
            let isSelected = index == type.rawValue
            button.isSelected = isSelected
            button.subviews.last?.isHidden = !isSelected
            button.titleLabel?.font = .appleSDGoithcFont(size: 16,
                                                         style: isSelected ? .bold : .medium)
        }
    }
    
    private func notifyCollectionView(type: JHBPContentHeaderButtonType) {
        JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
            delegate.notifyContentCell(indexPath: nil, forType: type)
        }
    }
    
    // MARK: - Initalize
    override func initalize() {
        super.initalize()
        
        let HStackView = UIStackView()
        HStackView.axis = .horizontal
        HStackView.distribution = .fillEqually
        
        addSubview(HStackView)
        
        HStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        headerButtons.forEach { HStackView.addArrangedSubview($0) }
        
        // MARK: - 멀티캐스트 딜리게이트 추가
        JHBPDispatchSystem.dispatch.multicastDelegate.addDelegate(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rootFlexContainer.pin.all()
        self.rootFlexContainer.flex.layout()
    }
    
    // MARK: - UIComponents
    let rootFlexContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
    
    enum JHBPContentHeaderButtonType: Int, CaseIterable {
        case profile, product
        
        func asString() -> String {
            switch self {
            case .profile: return "프로필"
            case .product: return "작품 보기"
            }
        }
    }
    private lazy var headerButtons: [UIButton] = {
        $0.map { type in
            let b = UIButton()
            b.setTitle(type.asString(), for: .normal)
            b.titleLabel?.font = .appleSDGoithcFont(size: 16, style: .medium)
            b.setTitleColor(.black, for: .selected)
            b.setTitleColor(.gray, for: .normal)
            let selectedView = UIView()
            selectedView.backgroundColor = .black
            b.addSubview(selectedView)
            selectedView.snp.makeConstraints {
                $0.bottom.leading.trailing.equalToSuperview()
                $0.height.equalTo(3)
            }
            return b
        }
    }(JHBPContentHeaderButtonType.allCases)
}

extension JHBPContentSectionHeaderView: JHBPMulticastDelegate {
    func notifyContentHeader(indexPath: IndexPath, forType: type) {
        
        // MARK: - 싱크 맞추기
        updateButtonUI(type: JHBPContentHeaderButtonType(rawValue: indexPath.row) ?? .profile)
    }
}
