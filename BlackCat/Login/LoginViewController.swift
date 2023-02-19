//
//  LoginViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/18.
//

import UIKit
import RxSwift

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
        
        viewModel.showHomeViewControllerDriver
            .drive(with: self) { owner, _ in
                owner.present(TabBarViewController(), animated: false)
            }.disposed(by: disposeBag)
        
        viewModel.loginFailureDriver
            .drive(with: self) { owner, _ in
                owner.present(OneButtonAlertViewController(viewModel: .init(content: "로그인에 실패했습니다.\n잠시후 다시 시도해주세요", buttonText: "확인")), animated: true)
            }.disposed(by: disposeBag)
        
        lookAroundLabel.rx.tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: viewModel.lookAroundTrigger)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Functions
    func setVStackView() {
        viewModel.socialLoginTypes.enumerated().forEach { index, type in
            let loginImageView = UIImageView(image: UIImage(named: type.buttonImageName()))
            loginImageView.tag = index
            loginImageView.contentMode = .scaleAspectFit
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
        l.textAlignment = .center
        l.numberOfLines = 0
        l.textColor = .white
        l.font = .heirOfLightFont(size: 48, style: .bold)
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
        l.attributedText = NSAttributedString(string: "둘러보기",
                                              attributes: [
                                                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
                                              ])
        l.textColor = .white
        l.font = .systemFont(ofSize: 14)
        return l
    }()
    let catEarImageView: UIImageView = {
        $0.image = UIImage(named: "catEar")
        return $0
    }(UIImageView())
    
}

extension LoginViewController {
    func setUI() {
        [appNameLabel, VStackView, lookAroundLabel, catEarImageView].forEach { view.addSubview($0) }
        
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
        
        catEarImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
