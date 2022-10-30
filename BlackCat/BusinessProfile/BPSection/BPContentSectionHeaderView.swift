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
        button1.rx.tap.map { Reactor.Action.didTapButton1 }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        button2.rx.tap.map { Reactor.Action.didTapButton2 }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        button3.rx.tap.map { Reactor.Action.didTapButton3 }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        button4.rx.tap.map { Reactor.Action.didTapButton4 }
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
    
    // MARK: - Initalize
    override func initalize() {
        super.initalize()
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.row)
            .justifyContent(.spaceEvenly)
            .alignItems(.center)
            .define { flex in
                flex.addItem(button1).grow(1)
                flex.addItem(button2).grow(1)
                flex.addItem(button3).grow(1)
                flex.addItem(button4).grow(1)
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rootFlexContainer.pin.all()
        self.rootFlexContainer.flex.layout()
    }
    
    // MARK: - UIComponents
    // NOTE: - Reusable을 사용하고 있어서 view의 frame을 정하는 작업에서 구조가 나빠지는 것 같아서, 이렇게 작성.
    let rootFlexContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
    
    // android처럼 버튼 id를 구분할 방법이 없어서 이렇게 처림
    enum CafeHeaderButtonType: String {
        case button1 = "1번"
        case button2 = "2번"
        case button3 = "3번"
        case button4 = "4번"
        
        func toString() -> String {
            switch self {
            case .button1: return rawValue
            case .button2: return rawValue
            case .button3: return rawValue
            case .button4: return rawValue
            }
        }
    }
    
    private lazy var button1: UIButton = {
        $0.setTitle(CafeHeaderButtonType.button1.toString(), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(.gray, for: .normal)
        return $0
    }(UIButton())
    
    private lazy var button2: UIButton = {
        $0.setTitle(CafeHeaderButtonType.button2.toString(), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(.gray, for: .normal)
        return $0
    }(UIButton())
    
    private lazy var button3: UIButton = {
        $0.setTitle(CafeHeaderButtonType.button3.toString(), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(.gray, for: .normal)
        return $0
    }(UIButton())
    
    private lazy var button4: UIButton = {
        $0.setTitle(CafeHeaderButtonType.button4.toString(), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(.gray, for: .normal)
        return $0
    }(UIButton())
    
}
