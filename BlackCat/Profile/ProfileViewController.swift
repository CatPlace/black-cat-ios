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
        
        let combinedProfileInfo = Observable.combineLatest(genderInputViewModel.genderCellInfosRelay, areaInputViewModel.areaCellInfosRelay)
            .debug("모은 데이터 ~")
            .bind { a, b in
                print(a, b)
            }
            
    }
}

class ProfileViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: ProfileViewModel) {

    }
    // MARK: - Initializer
    init(viewModel: ProfileViewModel) {
        nameInputView = ProfileTextInputView(viewModel: viewModel.nameInputViewModel)
        emailInputView = ProfileTextInputView(viewModel: viewModel.emailInputViewModel)
        phoneNumberInputView = ProfileTextInputView(viewModel: viewModel.phoneNumberInputViewModel)
        genderInputView = GenderInputView(viewModel: viewModel.genderInputViewModel)
        areaInputView = AreaInputView(viewModel: viewModel.areaInputViewModel)
        
        super.init(nibName: nil, bundle: nil)
        
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
        v.backgroundColor = UIColor(hex: "D9D9D9FF")
        v.layer.cornerRadius = view.frame.width * 4 / 25
        return v
    }()
    let nameInputView: ProfileTextInputView
    let emailInputView: ProfileTextInputView
    let phoneNumberInputView: ProfileTextInputView
    var HLineView: UIView = {
        $0.backgroundColor = UIColor(hex: "666666FF")
        return $0
    }(UIView())
    let genderInputView: GenderInputView
    let areaInputView: AreaInputView
    
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
            $0.leading.trailing.equalToSuperview()
        }
        
        emailInputView.snp.makeConstraints {
            $0.top.equalTo(nameInputView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        phoneNumberInputView.snp.makeConstraints {
            $0.top.equalTo(emailInputView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        HLineView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberInputView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        genderInputView.snp.makeConstraints {
            $0.top.equalTo(HLineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        areaInputView.snp.makeConstraints {
            $0.top.equalTo(genderInputView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().priority(.low)
        }
    }
}
