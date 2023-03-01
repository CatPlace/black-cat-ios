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
    let userPoliteLabelTextDriver: Driver<String>
    let setupManageViewDriver: Driver<Void>
    let profileEditIsHiddenDriver: Driver<Bool>
    let showImageViewBorderDriver: Driver<Void>
    let isEmptyProfileImage: Driver<Bool>
    
    init(user: Model.User) {
        let userObservable: Observable<Model.User> = .just(user)
        
        profileImageUrlStringDriver = userObservable
            .compactMap { $0.imageUrl }
            .asDriver(onErrorJustReturn: "")
        
        isEmptyProfileImage = userObservable
            .map { $0.imageUrl == nil }
            .asDriver(onErrorJustReturn: false)
        
        userTypeStringDriver = userObservable
            .map { $0.userType.profileString() }
            .asDriver(onErrorJustReturn: "유저 타입 오류")
        
        userNameDriver = userObservable
            .map { $0.userType != .guest ? $0.name ?? "미입력" : "로그인" }
            .asDriver(onErrorJustReturn: "")
        
        userPoliteLabelTextDriver = userObservable
            .map { $0.userType != .guest ? "님" : "후 이용할 수 있습니다" }
            .asDriver(onErrorJustReturn: "")
        
        setupManageViewDriver = userObservable
            .filter { $0.userType == .business }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        showImageViewBorderDriver = userObservable
            .filter { $0.userType == .business }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        profileEditIsHiddenDriver = userObservable
            .map { $0.userType == .guest }
            .asDriver(onErrorJustReturn: true)
    }
}

class MyPageProfileCell: MyPageBaseCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: MyPageProfileCellViewModel, with superViewModel: MyPageViewModel?) {
        guard let superViewModel else { return }
        
        profileEditButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: superViewModel.profileEditButtonTapped)
            .disposed(by: disposeBag)
        
        manageLabel.rx.tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: superViewModel.manageButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.profileImageUrlStringDriver
            .compactMap { URL(string: $0) }
            .drive(with: self) { owner, url in
                Nuke.loadImage(with: url, into: owner.userImageView)
            }.disposed(by: disposeBag)
        
        viewModel.userNameDriver
            .drive(userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userTypeStringDriver
            .drive(userTypeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userPoliteLabelTextDriver
            .drive(userPoliteLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.setupManageViewDriver
            .drive(with: self) { owner, _ in
                owner.setupHLine()
                owner.setupManageView()
            }.disposed(by: disposeBag)
        
        viewModel.profileEditIsHiddenDriver
            .drive(profileEditButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.showImageViewBorderDriver
            .drive(with: self) { owner, _ in
                owner.showImageViewBorder()
            }.disposed(by: disposeBag)
        
        viewModel.isEmptyProfileImage
            .drive(with: self) { owner, _ in
                owner.userImageView.image = UIImage(named: "guest")
            }.disposed(by: disposeBag)
        
    }
    
    // MARK: - Function
    func showImageViewBorder() {
        contentView.layoutIfNeeded()
        let color: UIColor = .init(hex: "#7210A0FF") ?? .black
        
        userImageView.addBorderGradient(startColor: color, endColor: .white, lineWidth: 5, startPoint: .topLeft, endPoint: .bottomRight)
    }
    
    // MARK: - Initializer
    override func initialize() {
        setUI()
        configureCell()
    }
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    override func layoutSubviews() {
        contentView.frame.size = frame.size
    }
    // MARK: - UIComponents
    let profileView = UIView()
    let manageView = UIView()
    let HLine: UIView = {
        $0.backgroundColor = .init(hex: "#C4C4C4FF")
        return $0
    }(UIView())
    let manageLabel: UILabel = {
        $0.text = "내 타투이스트 페이지 관리"
        $0.textColor = .init(hex: "#7210A0FF")
        $0.font = .appleSDGoithcFont(size: 16, style: .bold)
        return $0
    }(UILabel())
    let chevronRightImageView: UIImageView = {
        $0.image = UIImage(named: "chevronRightPurple")
        $0.tintColor = .init(hex: "#7210A0FF")
        return $0
    }(UIImageView())
    let userTypeLabel: UILabel = {
        $0.textColor = .init(hex: "#7210A0FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .medium)
        return $0
    }(UILabel())
    let userImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "guest")
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = 30 * UIScreen.main.bounds.width / 375
        v.clipsToBounds = true
        return v
    }()
    let userNameLabel: UILabel = {
        let l = UILabel()
        l.font = .appleSDGoithcFont(size: 20, style: .bold)
        return l
    }()
    let userPoliteLabel: UILabel = {
        let l = UILabel()
        l.font = .appleSDGoithcFont(size: 14, style: .regular)
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
        contentView.addSubview(profileView)
        
        profileView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.width * 82 / 375)
        }
        
        [userImageView, userTypeLabel, userNameLabel, userPoliteLabel, profileEditButton].forEach { profileView.addSubview($0) }
        
        userImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60 * UIScreen.main.bounds.width / 375)
        }

        userTypeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-11)
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
        }

        userNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(11)
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
        }

        userPoliteLabel.snp.makeConstraints {
            $0.bottom.equalTo(userNameLabel).offset(-2)
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(5)
        }
        
        profileEditButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }
    
    func setupHLine() {
        contentView.addSubview(HLine)
        
        HLine.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(1)
        }
    }

    func setupManageView() {
        contentView.frame.size = frame.size
        contentView.addSubview(manageView)
        
        manageView.snp.makeConstraints {
            $0.top.equalTo(HLine.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        [manageLabel, chevronRightImageView].forEach { manageView.addSubview($0) }
        
        manageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
        
        chevronRightImageView.snp.makeConstraints {
            $0.leading.equalTo(manageLabel.snp.trailing).offset(10)
            $0.width.equalTo(7)
            $0.height.equalTo(14)
            $0.centerY.equalTo(manageLabel).offset(-1)
        }
        
    }
}
