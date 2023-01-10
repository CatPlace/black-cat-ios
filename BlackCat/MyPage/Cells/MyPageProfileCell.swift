//
//  MyPageProfileCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Nuke
import BlackCatSDK

class MyPageProfileCellViewModel {
    
    // MARK: - Output
    let profileImageUrlStringDriver: Driver<String>
    let userNameDriver: Driver<String>
    let userTypeStringDriver: Driver<String>
    
    init(user: Model.User) {
        let userObservable: Observable<Model.User> = .just(user)
        
        let loggedInUser = userObservable
            .filter { _ in CatSDKUser.userType() != .guest }
        
        profileImageUrlStringDriver = loggedInUser
            .map { $0.imageUrl ?? "TEST" }
            .asDriver(onErrorJustReturn: "")
        
        userNameDriver = loggedInUser
            .map { $0.name ?? "TEST" }
            .asDriver(onErrorJustReturn: "")
        
        userTypeStringDriver = userObservable.map { $0.userType.profileString() }
            .asDriver(onErrorJustReturn: "유저 타입 오류")
    }
}

class MyPageProfileCell: MyPageBaseCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: MyPageProfileCellViewModel, with superViewModel: MyPageViewModel) {
        
        profileEditButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: superViewModel.profileEditButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.profileImageUrlStringDriver
            .compactMap { URL(string: $0) }
            .drive(with: self) { owner, urlString in
                Nuke.loadImage(with: urlString, into: owner.userImageView)
            }.disposed(by: disposeBag)
        
        viewModel.userNameDriver
            .drive(userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userTypeStringDriver
            .drive(userTypeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Function
    // MARK: - Initializer
    override func initialize() {
        setUI()
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    // MARK: - UIComponents
    let VStackView: UIStackView = {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.spacing = 20
        return $0
    }(UIStackView())
    let profileView: UIView = {
        $0.layer.applyShadow(alpha: 0.25, y: 1, blur: UIScreen.main.bounds.width * 40 / 375.0)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .white
        return $0
    }(UIView())
    let manageView: UIView = {
        return $0
    }(UIView())
    let userTypeLabel: UILabel = {
        $0.textColor = .init(hex: "#7210A0FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UILabel())
    let userImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 30 * UIScreen.main.bounds.width / 375
        return v
    }()
    let userNameLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 20)
        return l
    }()
    let userPoliteLabel: UILabel = {
        let l = UILabel()
        l.text = "님"
        l.font = .systemFont(ofSize: 14)
        return l
    }()
    let profileEditButton: UIButton = {
        let b = UIButton()
        b.setTitle("프로필 편집 ", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 12)
        b.setTitleColor(.init(hex: "#666666FF"), for: .normal)
        b.setImage(UIImage(named: "editProfile"), for: .normal)
        b.semanticContentAttribute = .forceRightToLeft
        return b
    }()
    let subscribeManageButton = ProfileManageButton(title: "구독 관리")
    let businessProfileManageButton = ProfileManageButton(title: "비지니스 프로필 관리")
}

extension MyPageProfileCell {
    func setUI() {
        contentView.addSubview(VStackView)
        [profileView, manageView].forEach { VStackView.addArrangedSubview($0) }
        
        VStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        [userImageView, userTypeLabel, userNameLabel, userPoliteLabel, profileEditButton].forEach { profileView.addSubview($0) }
        
        userImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(15)
            $0.width.height.equalTo(60 * UIScreen.main.bounds.width / 375)
        }
        
        userTypeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-12)
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(12)
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
        }
        
        userPoliteLabel.snp.makeConstraints {
            $0.bottom.equalTo(userNameLabel)
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(5)
        }
        
        profileEditButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
        }
        
        manageView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        [subscribeManageButton, businessProfileManageButton].forEach { manageView.addSubview($0) }
        
        subscribeManageButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(9).priority(.high)
            $0.width.equalToSuperview().multipliedBy(0.3).priority(.high)
        }
        businessProfileManageButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(subscribeManageButton.snp.trailing).offset(35)
            $0.trailing.equalToSuperview().inset(15)
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
