//
//  MyPageMenuCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/23.
//

import UIKit

import RxSwift
import RxCocoa
import RxRelay

class MyPageMenuCellViewModel {
    
    let titleDriver: Driver<String>
    let backgroundColorDriver: Driver<UIColor?>
    let textColorDriver: Driver<UIColor?>
    let chevronRightIsHiddenDriver: Driver<Bool>
    init(type: MyPageMenuType) {
        titleDriver = .just(type.menuTitle())
        let isAdditionalMenu = (type == .login || type == .upgrade)
        textColorDriver = .just(isAdditionalMenu ? .white : .init(hex: "#666666FF"))
        backgroundColorDriver = .just(isAdditionalMenu ? .init(hex: "#7210A0FF") : .white)
        chevronRightIsHiddenDriver = .just(isAdditionalMenu)
    }
}

class MyPageMenuCell: MyPageBaseCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Initializer
    override func initialize() {
        configureCell(y: 4)
        setUI()
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    // MARK: - Binding
    func bind(viewModel: MyPageMenuCellViewModel) {
        viewModel.titleDriver
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.textColorDriver
            .drive(titleLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        viewModel.backgroundColorDriver
            .drive(contentView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        return $0
    }(UILabel())
    let chevronRightImageView: UIImageView = {
        $0.image = .init(named: "chevronRightWhite")
        return $0
    }(UIImageView())
    
    func setUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        addSubview(chevronRightImageView)
        
        chevronRightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(18)
            $0.centerY.equalToSuperview()
        }
    }
}

