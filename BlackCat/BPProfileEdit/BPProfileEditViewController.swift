//
//  BPProfileEditViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import SnapKit
import ReactorKit

final class BPProfileEditViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = BPProfileEditReactor
    
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        closeBarButtonItem.rx.tap
            .map { Reactor.Action.didTapCloseItem }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        photoBarButtonItem.rx.tap
            .map { Reactor.Action.didTapPhotoItem }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func render(reactor: Reactor) {
        reactor.state.map { $0.isDismiss }
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe { owner, isDissmiss in
                owner.dismiss(animated: isDissmiss)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.isOpenPhotoLibrary }
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe { owenr, _ in
                
            }.disposed(by: disposeBag)
    }
    
    // MARK: - initilaize
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    lazy var closeBarButtonItem: UIBarButtonItem = {
        $0.image = UIImage(systemName: "xmark")
        $0.style = .plain
        $0.target = self
        $0.tintColor = .black
        return $0
    }(UIBarButtonItem())
    
    lazy var photoBarButtonItem: UIBarButtonItem = {
        $0.image = UIImage(systemName: "photo")
        $0.style = .plain
        $0.target = self
        $0.tintColor = .black
        return $0
    }(UIBarButtonItem())
    
    lazy var BPEditTextView: UITextView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        return $0
    }(UITextView())
}

extension BPProfileEditViewController {
    func setUI() {
        self.navigationItem.leftBarButtonItems = [closeBarButtonItem]
        self.toolbarItems = [photoBarButtonItem]
        
        view.addSubview(BPEditTextView)
        BPEditTextView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(100)
        }
    }
}
