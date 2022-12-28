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
    let showLoginViewDriver: Driver<Void>
    let showUserViewDriver: Driver<Void>
    let profileImageUrlStringDriver: Driver<String>
    let userNameDriver: Driver<String>
    
    init(user: Model.User) {
        let userObservable: Observable<Model.User> = .just(user)
        
        showLoginViewDriver = userObservable
            .filter { _ in user.jwt == "" }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        let loggedInUser = userObservable
            .filter { _ in user.jwt != "" }
        
        showUserViewDriver = loggedInUser
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        profileImageUrlStringDriver = loggedInUser
            .map { $0.imageUrl ?? "TEST" }
            .asDriver(onErrorJustReturn: "")
        
        userNameDriver = loggedInUser
            .map { $0.name ?? "TEST" }
            .asDriver(onErrorJustReturn: "")
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
        
        viewModel.showLoginViewDriver
            .drive(with: self) { owner, _ in
                owner.showLoginView()
            }.disposed(by: disposeBag)
        
        viewModel.showUserViewDriver
            .drive(with: self) { owner, _ in
                owner.showUserView()
            }.disposed(by: disposeBag)
        
        viewModel.profileImageUrlStringDriver
            .compactMap { URL(string: $0) }
            .drive(with: self) { owner, urlString in
                Nuke.loadImage(with: urlString, into: owner.userImageView)
            }.disposed(by: disposeBag)
        
        viewModel.userNameDriver
            .drive(userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Function
    func showLoginView() {
        userView.isHidden = true
        loginView.isHidden = false
    }
    
    func showUserView() {
        loginView.isHidden = true
        userView.isHidden = false
    }
    
    // MARK: - Initializer
    override func initialize() {
        configureCell()
        setUI()
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        layoutIfNeeded()
        userImageView.layer.cornerRadius = userImageView.frame.width / 2.0
    }
    
    // MARK: - UIComponents
    let loginView = UIView()
    let userView = UIView()
    let loginLabel: UILabel = {
        let l = UILabel()
        l.text = "로그인"
        l.font = .boldSystemFont(ofSize: 20)
        return l
    }()
    let userImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
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
    let horizontalLineView: UIView = {
        let v = UIView()
        v.backgroundColor = .init(hex: "#C4C4C4FF")
        return v
    }()
    let bookmarkClickView = UIView()
    let mySubscriptionView = UIView()
    let heartImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "heart.fill")
        return v
    }()
    let bookmarkLabel: UILabel = {
        let l = UILabel()
        l.text = "찜한 컨텐츠"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .init(hex: "#666666FF")
        return l
    }()
    let mySubscriptionLabel: UILabel = {
        let l = UILabel()
        l.text = "MY 구독"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .init(hex: "#666666FF")
        return l
    }()
    let verticalLineView: UIView = {
        let v = UIView()
        v.backgroundColor = .init(hex: "#C4C4C4FF")
        return v
    }()
    
    
}

extension MyPageProfileCell {
    func setUI() {
        [loginView, userView, horizontalLineView, bookmarkClickView, verticalLineView, mySubscriptionView].forEach { contentView.addSubview($0) }
        
        horizontalLineView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(frame.height * 82 / 132.0)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(1)
        }
        
        verticalLineView.snp.makeConstraints {
            $0.top.equalTo(horizontalLineView.snp.bottom).offset(15)
            $0.bottom.equalToSuperview().inset(15)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(1)
        }
        [loginView, userView].forEach {
            $0.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(horizontalLineView.snp.top)
            }
        }
        
        bookmarkClickView.snp.makeConstraints {
            $0.top.equalTo(horizontalLineView.snp.bottom)
            $0.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(verticalLineView.snp.leading)
        }
        
        mySubscriptionView.snp.makeConstraints {
            $0.top.equalTo(horizontalLineView.snp.bottom)
            $0.leading.equalTo(verticalLineView.snp.trailing)
            $0.trailing.bottom.equalToSuperview()
        }
        
        loginView.addSubview(loginLabel)
        
        loginLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        [userImageView, userNameLabel, userPoliteLabel, profileEditButton].forEach { userView.addSubview($0) }
        
        userImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(10)
            $0.width.equalTo(userImageView.snp.height)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-12)
            $0.leading.equalTo(userImageView.snp.trailing).offset(10)
        }
        
        userPoliteLabel.snp.makeConstraints {
            $0.bottom.equalTo(userNameLabel)
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(5)
        }
        
        profileEditButton.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(12)
            $0.leading.equalTo(userImageView.snp.trailing).offset(10)
        }
        
        [heartImageView, bookmarkLabel].forEach { bookmarkClickView.addSubview($0) }
        
        heartImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-26)
        }
        
        bookmarkLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(26)
        }
        
        mySubscriptionView.addSubview(mySubscriptionLabel)
        
        mySubscriptionLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
    }
}

