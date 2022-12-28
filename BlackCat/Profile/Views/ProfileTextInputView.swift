//
//  ProfileTextInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/28.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import BlackCatSDK

enum ProfileTextInputTitle: String {
    case 이름, 이메일, 전화번호
    
    func info() -> String? {
        let user = CatSDKUser.user()
        switch self {
        case .이름:
            return user.name
        case .이메일:
            return user.email
        case .전화번호:
            return user.phoneNumber
        }
    }
}

class ProfileTextInputViewModel {
    // MARK: - Input
    let inputStringRelay: BehaviorRelay<String>
    let viewWillAppearRelay = PublishRelay<Void>()
    
    // MARK: - Output
    let titleDriver: Driver<String>
    let placeholderDriver: Driver<String>
    let textCountLimitDriver: Driver<String>
    
    init(title: String, placeholder: String = "텍스트를 입력해주세요", textCountLimit: Int = 18) {
        inputStringRelay =  .init(value: ProfileTextInputTitle(rawValue: title)?.info() ?? "")
        titleDriver = .just(title)
        placeholderDriver = .just(placeholder)
        textCountLimitDriver = inputStringRelay
            .map { "(\($0.count)/\(textCountLimit))" }
            .asDriver(onErrorJustReturn: "")
        
    }
}

class ProfileTextInputView: UIView {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: ProfileTextInputViewModel) {
        disposeBag.insert {
            
            profileTextField.rx.text.orEmpty
                .bind(to: viewModel.inputStringRelay)
            
            viewModel.titleDriver
                .drive(titleLabel.rx.text)
            
            viewModel.placeholderDriver
                .drive(profileTextField.rx.placeholder)
            
            viewModel.textCountLimitDriver
                .drive(textCountLimitLabel.rx.text)
        }
    }
    
    // MARK: - Initializer
    init(viewModel: ProfileTextInputViewModel) {
        super.init(frame: .zero)
        profileTextField.delegate = self
        setUI()
        bind(to: viewModel)
    }
    
    override func layoutSubviews() {
        layoutIfNeeded()
        print(frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.textColor = .init(hex: "#666666FF")
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        return $0
    }(UILabel())
    let profileTextField: UITextField = {
        $0.setLeftPaddingPoints(10)
        $0.textColor = .init(hex: "#999999FF")
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        return $0
    }(UITextField())
    let textCountLimitLabel: UILabel = {
        let l = UILabel()
        $0.textColor = .init(hex: "#999999FF")
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        return $0
    }(UILabel())
}

extension ProfileTextInputView {
    func setUI() {
        [titleLabel, profileTextField].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        profileTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }
        
        profileTextField.addSubview(textCountLimitLabel)
        
        textCountLimitLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
    }
}

extension ProfileTextInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        return text.count < 19 || range.length == 1
    }
}
