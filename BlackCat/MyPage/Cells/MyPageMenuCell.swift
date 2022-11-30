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

// 문의하기랑 신고 및 피드백 ... ?
enum MyPageMenuType: String {
    case notice = "공지사항"
    case inquiry = "문의하기"
    case termOfService = "서비스 이용약관"
    case PersonalInfoAgreement = "개인정보 수집 및 이용"
    case feedback = "신고 및 피드백"
    case logout = "로그아웃"
    case withdrawal = "회원 탈퇴"
    
    func nextVC() -> UIViewController {
        switch self {
        default:
            return HomeViewController()
        }
    }
}

class MyPageMenuCellViewModel {
    
    let titleDriver: Driver<String>
    
    init(type: MyPageMenuType) {
        titleDriver = .just(type.rawValue)
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

