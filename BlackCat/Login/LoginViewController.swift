//
//  LoginViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/18.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import BlackCatSDK

class LoginViewModel {
    let socialLoginTypes: [BlackCatUserSDK.loginType] = [.kakao, .apple]
    
    // MARK: - Input
    var didTapSocialLoginButton = PublishRelay<Int>()
    
    // MARK: - Output
    var resultDriver: Driver<Void>
    
    init() {
        let types = socialLoginTypes
        
        resultDriver = didTapSocialLoginButton
            .map { types[$0] }
            .flatMap(BlackCatUserSDK.login)
            .map { result in
                switch result {
                case .success(let a):
                    print(a)
                case .failure(let b):
                    print(b)
                }
            }.map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }
}

class LoginViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: LoginViewModel
    
    // MARK: - Binding
    func bind(to viewModel: LoginViewModel) {
        VStackView.subviews.forEach { imageView in
            imageView.rx.tapGesture()
                .when(.recognized)
                .map { _ in imageView.tag }
                .bind(to: viewModel.didTapSocialLoginButton)
                .disposed(by: disposeBag)
        }
        
        viewModel.resultDriver
            .drive { _ in
                print("drive")
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Functions
    func setVStackView() {
        viewModel.socialLoginTypes.enumerated().forEach { index, type in
            let loginImageView = UIImageView(image: UIImage(named: type.buttonImageName()))
            loginImageView.tag = index
            VStackView.addArrangedSubview(loginImageView)
        }
    }
    
    // MARK: - Initializer
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setUI()
        setVStackView()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#333333FF")
    }
    
    // MARK: - UIComponents
    var appNameLabel: UILabel = {
        let l = UILabel()
        l.text = "Black\nCat"
        l.numberOfLines = 0
        l.textColor = .white
        return l
    }()
    var VStackView: UIStackView = {
        let v = UIStackView()
        v.distribution = .equalSpacing
        v.spacing = 15
        v.axis = .vertical
        return v
    }()
    var lookAroundLabel: UILabel = {
        let l = UILabel()
        l.attributedText = NSAttributedString(string: "둘러보기")
        l.textColor = .white
        return l
    }()
    
}

extension LoginViewController {
    func setUI() {
        [appNameLabel, VStackView, lookAroundLabel].forEach { view.addSubview($0) }
        
        appNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-80)
        }
        
        VStackView.snp.makeConstraints {
            $0.top.equalTo(appNameLabel.snp.bottom).offset(70)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(48/75.0)
        }
        
        lookAroundLabel.snp.makeConstraints {
            $0.top.equalTo(VStackView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
