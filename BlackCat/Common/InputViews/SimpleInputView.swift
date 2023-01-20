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

enum SimpleInputType: String {
    case profileName, profileEmail, profliePhoneNumber, tattooTitle
    
    func title() -> String {
        switch self {
        case .profileName:
            return "이름"
        case .profileEmail:
            return "이메일"
        case .profliePhoneNumber:
            return "전화번호"
        case .tattooTitle:
            return "제목"
        }
    }
    
    func content() -> String? {
        let user = CatSDKUser.user()
        switch self {
        case .profileName:
            return user.name
        case .profileEmail:
            return user.email
        case .profliePhoneNumber:
            return user.phoneNumber
        case .tattooTitle:
            return ""
        }
    }
}

class SimpleInputViewModel {
    // MARK: - Input
    let inputStringRelay: BehaviorRelay<String>
    let viewWillAppearRelay = PublishRelay<Void>()
    
    // MARK: - Output
    let titleDriver: Driver<String>
    let placeholderDriver: Driver<String>
    let textCountLimitDriver: Driver<String>
    
    // MARK: - Property
    let textCountLimit: Int
    
    init(type: SimpleInputType, content: String? = nil, placeholder: String = "텍스트를 입력해주세요", textCountLimit: Int = 18) {
        self.textCountLimit = textCountLimit
        inputStringRelay =  .init(value: content ?? type.content() ?? "")
        titleDriver = .just(type.title())
        placeholderDriver = .just(placeholder)
        textCountLimitDriver = inputStringRelay
            .map { "(\($0.count)/\(textCountLimit))" }
            .asDriver(onErrorJustReturn: "")
        
    }
}

class SimpleInputView: UIView {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: SimpleInputViewModel
    
    // MARK: - Binding
    func bind(to viewModel: SimpleInputViewModel) {
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
    init(viewModel: SimpleInputViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        profileTextField.delegate = self
        profileTextField.backgroundColor = .white
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    override func layoutSubviews() {
        layoutIfNeeded()
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.textColor = .init(hex: "#666666FF")
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        return $0
    }(UILabel())
    let profileTextField: UITextField = {
        $0.setLeftPaddingPoints(10)
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UITextField())
    let textCountLimitLabel: UILabel = {
        let l = UILabel()
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UILabel())
}

extension SimpleInputView {
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

extension SimpleInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        return text.count < viewModel.textCountLimit || range.length == 1
    }
}
