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
import PinLayout
import FlexLayout

enum JHBPContentHeaderButtonType: Int, CaseIterable {
    case profile, product, info
    
    func asString() -> String {
        switch self {
        case .profile: return "소개"
        case .product: return "작품 보기"
        case .info: return "견적 안내"
        }
    }
    
    func editButtonText() -> String {
        switch self {
        case .profile: return "게시글 수정"
        case .product: return "타투 업로드"
        case .info: return "견적 수정"
        }
    }
    
    func editVC() -> UIViewController {
        switch self {
        case .profile: return ProfileEditViewController()
        case .product: return ProductEditViewController()
        case .info: return PriceInfoEditViewController()
        }
    }
    
}

final class JHBPContentSectionHeaderViewModel {
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
                JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                    delegate.notifyContentCell(indexPath: nil, forType: type)
                }
                JHBPDispatchSystem.dispatch.multicastDelegate.invokeDelegates { delegate in
                    delegate.notifyContentHeader(indexPath: IndexPath(row: type.rawValue, section: 1), forType: type)
                }
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
    
    // MARK: - Initalize
    override func initalize() {
        super.initalize()
        backgroundColor = .white
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
