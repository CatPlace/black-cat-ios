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

class LoginViewModel {
    var socialLoginTypes: [BlackCatSocialLoginSDK.SocialLoginType] = [.kakao, .apple]
    
    // MARK: - Input
    var didTapSocialLoginButton = PublishRelay<Int>()
    
    // MARK: - Output
    
    
    init() {
            
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
    }
    
    // MARK: - Functions
    func setVStackView() {
        viewModel.socialLoginTypes.enumerated().forEach {
            let loginImageView = UIImageView(image: UIImage(named: $1.buttonImageName()))
            loginImageView.tag = $0
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
    }
    
    // MARK: - UIComponents
    var VStackView: UIStackView = {
        let v = UIStackView()
        v.distribution = .fillProportionally
        v.axis = .vertical
        return v
    }()
    
}

extension LoginViewController {
    func setUI() {
        [VStackView].forEach { view.addSubview($0) }
        
        VStackView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
