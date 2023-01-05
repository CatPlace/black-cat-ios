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
    
    init(type: MyPageMenuType) {
        titleDriver = .just(type.menuTitle())
    }
}

class MyPageMenuCell: MyPageBaseCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Initializer
    override func initialize() {
        configureCell()
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
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        let l = UILabel()
        l.textColor = .init(hex: "#666666FF")
        return l
    }()
    
    func setUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}

