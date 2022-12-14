//
//  ProfileViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/20.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import RxGesture
import BlackCatSDK

class ProfileViewModel {
    let nameInputViewModel: ProfileTextInputViewModel
    let emailInputViewModel: ProfileTextInputViewModel
    let phoneNumberInputViewModel: ProfileTextInputViewModel
    let genderInputViewModel: GenderInputViewModel
    let areaInputViewModel: AreaInputViewModel
    
    
    let viewWillApearRelay = PublishRelay<Void>()
    let completeButtonTapped = PublishRelay<Void>()
    let completeAlertDriver: Driver<Void>
    
    init(nameInputViewModel: ProfileTextInputViewModel,
         emailInputViewModel: ProfileTextInputViewModel,
         phoneNumberInputViewModel: ProfileTextInputViewModel,
         genderInputViewModel: GenderInputViewModel,
         areaInputViewModel: AreaInputViewModel) {
        self.nameInputViewModel = nameInputViewModel
        self.emailInputViewModel = emailInputViewModel
        self.phoneNumberInputViewModel = phoneNumberInputViewModel
        self.genderInputViewModel = genderInputViewModel
        self.areaInputViewModel = areaInputViewModel
        
        // TODO: 데이터 -> 캐시데이터 -> 완료버튼 누르면 서버 후 알러트
        let combinedInputs = Observable.combineLatest(
            nameInputViewModel.inputStringRelay,
            emailInputViewModel.inputStringRelay,
            phoneNumberInputViewModel.inputStringRelay,
            genderInputViewModel.genderCellInfosRelay,
            areaInputViewModel.areaCellInfosRelay
        )
        
        // TODO: - 서버통신
        completeAlertDriver = completeButtonTapped
            .withLatestFrom(combinedInputs)
            .do { name, email, phone, gender, area in
                    print(name, email, phone)
                    print(gender.filter { $0.isSelected })
                    print(area.filter { $0.isSelected })
            }.map { _ in () }
            .asDriver(onErrorJustReturn: ())
            
    }
    
    func initUserCache() {
        CatSDKUser.initUserCache()
    }
}

class ProfileViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: ProfileViewModel) {
        disposeBag.insert {
            rx.viewWillAppear
                .map { _ in () }
                .do { _ in viewModel.initUserCache() }
                .bind(to: viewModel.viewWillApearRelay)
            
            completeButtonLabel.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .bind(to: viewModel.completeButtonTapped)
            
            viewModel.completeAlertDriver
                .drive {
                    // TODO
                    print("알러트 !")
                }
        }
    }
    
    // MARK: - Initializer
    init(viewModel: ProfileViewModel) {
        nameInputView = ProfileTextInputView(viewModel: viewModel.nameInputViewModel)
        emailInputView = ProfileTextInputView(viewModel: viewModel.emailInputViewModel)
        phoneNumberInputView = ProfileTextInputView(viewModel: viewModel.phoneNumberInputViewModel)
        genderInputView = GenderInputView(viewModel: viewModel.genderInputViewModel)
        areaInputView = AreaInputView(viewModel: viewModel.areaInputViewModel)
        
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .init(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(contentView.frame)
    }
    
    // MARK: - UIComponents
    let scrollView = UIScrollView()
    let contentView = UIView()
    lazy var profileImageView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = UIColor(hex: "#D9D9D9FF")
        v.layer.cornerRadius = view.frame.width * 4 / 25
        return v
    }()
    let nameInputView: ProfileTextInputView
    let emailInputView: ProfileTextInputView
    let phoneNumberInputView: ProfileTextInputView
    var HLineView: UIView = {
        $0.backgroundColor = UIColor(hex: "#666666FF")
        return $0
    }(UIView())
    let genderInputView: GenderInputView
    let areaInputView: AreaInputView
    let completeButtonLabel: UILabel = {
        $0.text = "완료"
        $0.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        $0.textColor = .white
        return $0
    }(UILabel())
}

extension ProfileViewController {
    func setUI() {
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        [profileImageView, nameInputView, emailInputView, phoneNumberInputView, HLineView, genderInputView, areaInputView].forEach { contentView.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(view.frame.width * 8 / 25)
            $0.top.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        
        nameInputView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        emailInputView.snp.makeConstraints {
            $0.top.equalTo(nameInputView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(nameInputView)
        }
        
        phoneNumberInputView.snp.makeConstraints {
            $0.top.equalTo(emailInputView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(nameInputView)
        }
        
        HLineView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(nameInputView)
            $0.height.equalTo(1)
        }
        
        genderInputView.snp.makeConstraints {
            $0.top.equalTo(HLineView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        areaInputView.snp.makeConstraints {
            $0.top.equalTo(genderInputView.snp.bottom).offset(34)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(view.frame.width * 90 / 375).priority(.low)
        }
        
        view.addSubview(completeButtonLabel)
        
        completeButtonLabel.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.frame.width * 90 / 375)
        }
    }
}
