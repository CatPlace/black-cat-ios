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

class ProfileTextInputViewModel {
    // MARK: - Input
    let inputStringRelay = PublishRelay<String>()
    
    // MARK: - Output
    let titleDriver: Driver<String>
    let placeholderDriver: Driver<String>
    let textCountLimitDriver: Driver<String>
    
    init(title: String, placeholder: String = "텍스트를 입력해주세요", textCountLimit: Int = 18) {
        titleDriver = .just(title)
        placeholderDriver = .just(placeholder)
        textCountLimitDriver = .just("0/\(textCountLimit)")
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
                .drive(profileTextField.rx.text)
        }
    }
    
    // MARK: - Initializer
    init(viewModel: ProfileTextInputViewModel) {
        super.init(frame: .zero)
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
        let l = UILabel()
        return l
    }()
    let profileTextField = UITextField()
    let textCountLimitLabel: UILabel = {
        let l = UILabel()
        return l
    }()
}

extension ProfileTextInputView {
    func setUI() {
        [titleLabel, profileTextField, textCountLimitLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        profileTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }
    }
}
