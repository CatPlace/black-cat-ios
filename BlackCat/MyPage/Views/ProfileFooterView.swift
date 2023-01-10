//
//  ProfileFooterView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/10.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

struct ProfileFooterViewModel {

    init() {
    }
}

class ProfileFooterView: UICollectionReusableView {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: ProfileFooterViewModel) {
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let subscribeManageButton = ProfileManageButton(title: "구독 관리")
    let businessProfileManageButton = ProfileManageButton(title: "비지니스 프로필 관리")
}

extension ProfileFooterView {
    func setUI() {
        [subscribeManageButton, businessProfileManageButton].forEach {addSubview($0) }
        subscribeManageButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
            $0.leading.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width * 0.3)
        }
        businessProfileManageButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
            $0.leading.equalTo(subscribeManageButton.snp.trailing)
            $0.trailing.equalToSuperview()
        }
    }
}

class ProfileManageButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .init(hex: "#7210A0FF")
        setTitle(title, for: .normal)
        titleLabel?.font = .pretendardFont(size: 16, style: .regular)
        layer.cornerRadius = 15
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
