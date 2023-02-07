//
//  LoginAlertViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/06.
//

import UIKit
import RxSwift
import VisualEffectView

class LoginAlertViewController: UIViewController {
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
                owner.dismiss(animated: true) {
                    if viewModel.isLogin() {
                        if let vc = UIApplication.getMostTopViewController() as? MyPageViewController  {
                            vc.viewModel.viewWillAppear.accept(())
                        }
                    }
                }
            }.disposed(by: disposeBag)
        
        viewModel.loginFailureDriver
            .drive { _ in
                print("로그인 실패 alert")
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
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setUI()
        setVStackView()
        bind(to: viewModel)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UIComponents
    let blurEffectView: VisualEffectView = {
        let v = VisualEffectView()
        v.colorTintAlpha = 1
        v.backgroundColor = .black.withAlphaComponent(0.6)
        v.blurRadius = 5
        return v
    }()
    
    var decriptionLabel: UILabel = {
        let l = UILabel()
        l.text = "로그인 후\n사용할 수 있습니다"
        l.textAlignment = .center
        l.numberOfLines = 0
        l.textColor = .white
        l.font = .appleSDGoithcFont(size: 16, style: .bold)
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
        l.attributedText = NSAttributedString(string: "닫기 ?",
                                              attributes: [
                                                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
                                              ])
        l.textColor = .white
        l.font = .systemFont(ofSize: 14)
        return l
    }()
    
}

extension LoginAlertViewController {
    func setUI() {
        [blurEffectView, decriptionLabel, VStackView, lookAroundLabel].forEach { view.addSubview($0) }
        
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        decriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-80)
        }
        
        VStackView.snp.makeConstraints {
            $0.top.equalTo(decriptionLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(48/75.0)
        }
        
        lookAroundLabel.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
