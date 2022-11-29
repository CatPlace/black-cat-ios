//
//  BPPriceInfoEditViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/15.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import ReactorKit

final class BPPriceInfoEditViewController: UIViewController, View {
    typealias Reactor = BPPriceInfoEditReactor
    var disposeBag: DisposeBag = DisposeBag()

    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        self.rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        closeButtonItem.rx.tap
            .map { Reactor.Action.didTapClose }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        confirmButtonItem.rx.tap
            .map { Reactor.Action.didTapConfirm }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .map { Reactor.Action.inputText($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

    }
    
    private func render(reactor: Reactor) {
        reactor.pulse(\.$text)
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isDismiss)
            .filter { $0 == true }
            .withUnretained(self)
            .bind { owner, _ in owner.dismiss(animated: true) }
            .disposed(by: disposeBag)
    }
    
    // MARK: Initialize
    init(reactor: Reactor = .init(initialState: .init(text: ""))) {
        // NOTE: - 야기를 주입받도록 바꾸기
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var closeButtonItem: UIBarButtonItem = {
        $0.image = UIImage(systemName: "xmark")
        $0.target = self
        $0.tintColor = .black
        return $0
    }(UIBarButtonItem())
    
    lazy var confirmButtonItem: UIBarButtonItem = {
        $0.title = "완료"
        $0.target = self
        $0.tintColor = .black
        return $0
    }(UIBarButtonItem())
    
    lazy var textView: UITextView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        return $0
    }(UITextView())
}

extension BPPriceInfoEditViewController {
    func setUI() {
        self.navigationItem.leftBarButtonItems = [closeButtonItem]
        self.navigationItem.rightBarButtonItems = [confirmButtonItem]
        
        view.addSubview(textView)
        textView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

