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
    
    init(title: String) {
        titleDriver = .just(title)
    }
}

class MyPageMenuCell: BaseCollectionViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Initializer
    override func initialize() {
        setUI()
        configureCell()
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
    
    func configureCell() {
        layer.applyShadow(alpha: 0.15, y: 4, blur: UIScreen.main.bounds.width * 40 / 375.0)
        
        backgroundColor = .white
        layer.cornerRadius = 15
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
    }
    
    func setUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}

