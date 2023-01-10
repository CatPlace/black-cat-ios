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
        
        userNameDriver = userObservable
            .debug(" asd")
            .map { $0.userType != .guest ? $0.name ?? "미입력" : "게스트" }
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
        configureCell()
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    // MARK: - UIComponents
    let userTypeLabel: UILabel = {
        $0.textColor = .init(hex: "#7210A0FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UILabel())
    let userImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 26 * UIScreen.main.bounds.width / 375
        v.backgroundColor = .gray
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
   
}

extension MyPageProfileCell {
    func setUI() {
        [userImageView, userTypeLabel, userNameLabel, userPoliteLabel, profileEditButton].forEach { contentView.addSubview($0) }
        userImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(15).priority(.high)
            $0.width.height.equalTo(52 * UIScreen.main.bounds.width / 375).priority(.high)
        }

        userTypeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-10)
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
        }

        userNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(10)
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
        }

        userPoliteLabel.snp.makeConstraints {
            $0.bottom.equalTo(userNameLabel)
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(5)
        }
        
        profileEditButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }
}
