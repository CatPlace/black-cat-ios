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
enum MyPageMenuType: Int {
    case notice
    case inquiry
    case termOfService
    case PersonalInfoAgreement
    case feedback
    case logout
    case withdrawal
    
    func nextVC() -> UIViewController {
        switch self {
        default:
            return HomeViewController()
        }
    }
    
    func menuTitle() -> String {
        switch self {
        case .notice:
            return "공지사항"
        case .inquiry:
            return "문의하기"
        case .termOfService:
            return "서비스 이용약관"
        case .PersonalInfoAgreement:
            return "개인정보 수집 및 이용"
        case .feedback:
            return "신고 및 피드백"
        case .logout:
            return "로그아웃"
        case .withdrawal:
            return "회원 탈퇴"
        }
    }
    
}

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

