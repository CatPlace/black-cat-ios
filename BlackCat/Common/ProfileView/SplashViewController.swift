//
//  SplashViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/03/01.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class SplashViewModel {
    
    let viewWillAppear = PublishRelay<Void>()
    let showLoginVC: Driver<Void>
    let showHomeVC: Driver<Void>
    
    init() {
        let isLogin = viewWillAppear
            .flatMap { CatSDKBookmark.bookmarkListInSpecificUser(postType: .tattoo)
                    .map { _ in true }
                    .catch { _ in
                        CatSDKUser.updateUser(user: .init(id: -1))
                        return .just(false)
                    }
            }.share()
            
        showLoginVC = isLogin
            .filter { !$0 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        showHomeVC = isLogin
            .filter { $0 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }
}

class SplashViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - Binding
    func bind(to viewModel: SplashViewModel) {
        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        viewModel.showHomeVC
            .drive(with: self) { owner, _ in
                owner.show(TabBarViewController())
            }.disposed(by: disposeBag)
        
        viewModel.showLoginVC
            .drive(with: self) { owner, _ in
                owner.show(LoginViewController(viewModel: .init()))
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Functions
    func show(_ sender: UIViewController) {
        sender.modalPresentationStyle = .fullScreen
        present(sender, animated: false)
    }
    
    // MARK: - Initializer
    init(viewModel: SplashViewModel = .init()) {
        super.init(nibName: nil, bundle: nil)
        bind(to: viewModel)
        setUI()
        view.backgroundColor = .init(hex: "#333333FF")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let logoImageView: UIImageView = {
        $0.image = .init(named: "launchImage")
        return $0
    }(UIImageView())
    
    let mentImageView: UIImageView = {
        $0.image = .init(named: "launchMent")
        return $0
    }(UIImageView())
    
    let catEarImageView: UIImageView = {
        $0.image = .init(named: "catEar")
        return $0
    }(UIImageView())
    
    func setUI() {
        [logoImageView, mentImageView, catEarImageView].forEach { view.addSubview($0) }
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(-21)
        }
        
        mentImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(20)
        }
        
        catEarImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
