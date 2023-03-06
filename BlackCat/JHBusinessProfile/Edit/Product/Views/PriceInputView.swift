//
//  PriceInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/03/07.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class PriceInputView: UIView {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: PriceInputViewModel
    
    // MARK: - Binding
    func bind(to viewModel: PriceInputViewModel) {
        disposeBag.insert {
            
            textField.rx.text.orEmpty
                .skip(1)
                .bind(to: viewModel.inputStringRelay)
            
            viewModel.titleDriver
                .drive(titleLabel.rx.text)
            
            viewModel.contentDriver
                .drive(textField.rx.text)
            
            viewModel.placeholderDriver
                .drive(textField.rx.placeholder)
            
            viewModel.placeholderNSAttributedString
                .drive(textField.rx.attributedPlaceholder)
        }
    }
    
    // MARK: - Initializer
    init(viewModel: PriceInputViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        textField.backgroundColor = .white
        textField.keyboardType = .numberPad
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
    lazy var textField: UITextField = {
        $0.setLeftPaddingPoints(10)
        $0.delegate = self
        $0.font = .appleSDGoithcFont(size: 16, style: .regular)
        return $0
    }(UITextField())
    let priceUnitLabel: UILabel = {
        $0.text = "원"
        $0.font = .appleSDGoithcFont(size: 16, style: .semiBold)
        return $0
    }(UILabel())
}

extension PriceInputView {
    func setUI() {
        [titleLabel, textField, priceUnitLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.equalTo(28)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(31).priority(.required)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(36)
            $0.bottom.equalToSuperview()
        }
        
        priceUnitLabel.snp.makeConstraints {
            $0.centerY.equalTo(textField)
            $0.trailing.equalTo(textField).inset(11)
        }
    }
}


extension PriceInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        return text.count < 10 || range.length == 1
    }
}
