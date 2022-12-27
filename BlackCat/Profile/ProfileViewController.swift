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
import BlackCatSDK

class ProfileTextInputViewModel {
    // MARK: - Input
    let inputStringRelay = PublishRelay<String>()
    
    // MARK: - Output
    let titleDriver: Driver<String>
    let placeholderDriver: Driver<String>
    let textCountLimitDriver: Driver<String>
    
    init(title: String, placeholder: String = "텍스트를 입력해주세요", textCountLimit: Int = 18) {
        titleDriver = .just(title)
        placeholderDriver = .just(placeholder)
        textCountLimitDriver = .just("0/\(textCountLimit)")
    }
}

class ProfileTextInputView: UIView {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(to viewModel: ProfileTextInputViewModel) {
        disposeBag.insert {
            profileTextField.rx.text.orEmpty
                .bind(to: viewModel.inputStringRelay)
            
            viewModel.titleDriver
                .drive(titleLabel.rx.text)
            
            viewModel.placeholderDriver
                .drive(profileTextField.rx.placeholder)
            
            viewModel.textCountLimitDriver
                .drive(profileTextField.rx.text)
        }
    }
    
    // MARK: - Initializer
    init(viewModel: ProfileTextInputViewModel) {
        super.init(frame: .zero)
        setUI()
        bind(to: viewModel)
    }
    
    override func layoutSubviews() {
        layoutIfNeeded()
        print(frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        let l = UILabel()
        return l
    }()
    let profileTextField = UITextField()
    let textCountLimitLabel: UILabel = {
        let l = UILabel()
        return l
    }()
}

extension ProfileTextInputView {
    func setUI() {
        [titleLabel, profileTextField, textCountLimitLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        profileTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }
    }
}

class GenderCellInfo {
    var name: String
    var isSelected: Bool
    
    init(name: String, isSelected: Bool) {
        self.name = name
        self.isSelected = isSelected
    }
}

class GenderInputViewModel {
    let genders: [Model.Gender]
    let genderCellInfosRelay = BehaviorRelay<[GenderCellInfo]>(
        value: Model.Gender.allCases
            .map {.init(
                name: $0.asString(),
                isSelected: $0 == CatSDKUser.userCache().gender )
            }
    )
    let selectedGenderIndexRelay = PublishRelay<IndexPath>()
    
    let cellViewModelsDriver: Driver<[FilterCellViewModel]>
    let shouldUpdateGenderCells: Driver<Model.Gender>
    
    
    init(genders: [Model.Gender] = Model.Gender.allCases) {
        self.genders = genders
        
        CatSDKUser.initUserCache()
        
        self.cellViewModelsDriver = genderCellInfosRelay.map {
            $0.map { .init(typeString: $0.name, isSubscribe: $0.isSelected)}
        }.asDriver(onErrorJustReturn: [])
        
        shouldUpdateGenderCells = selectedGenderIndexRelay
            .map { $0.row }
            .withLatestFrom(genderCellInfosRelay) { ($0, $1) }
            .map { selectedRow, genderCellInfos in
                return updateGender(with: selectedRow)
            }.asDriver(onErrorJustReturn: .남자)
        
        
        func updateGender(with row: Int? = nil) -> Model.Gender {
            var user = CatSDKUser.userCache()
            if let row {
                user.gender = Model.Gender(rawValue: row)
                CatSDKUser.updateUserCache(user: user)
            }
            return user.gender ?? .남자
        }
    }
    
    func updateCelles(selectedGender: Model.Gender) {
        genderCellInfosRelay.accept(genders.map { .init(name: $0.asString(), isSelected: $0 == selectedGender)})
    }
}

class GenderInputView: UIView {
    enum Reusable {
        static let genderCell = ReusableCell<FilterCell>()
    }
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: GenderInputViewModel
    
    // MARK: - Binding
    func bind(to viewModel: GenderInputViewModel) {
        disposeBag.insert {
            viewModel.cellViewModelsDriver
                .drive(collectionView.rx.items) { cv, row, data in
                    let cell = cv.dequeue(Reusable.genderCell.self, for: IndexPath(row: row, section: 0))
                    cell.viewModel = data
                    return cell
                }
            
            collectionView.rx.itemSelected
                .debug("아이템 선택")
                .bind(to: viewModel.selectedGenderIndexRelay)
            
            viewModel.shouldUpdateGenderCells
                .drive { viewModel.updateCelles(selectedGender: $0)}
            
        }
    }
    
    // MARK: - Initializer
    init(viewModel: GenderInputViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        backgroundColor = .orange
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let titleLabel: UILabel = {
        $0.text = "성별"
        return $0
    }(UILabel())
    var layout: UICollectionViewFlowLayout = {
        let width: CGFloat = UIScreen.main.bounds.width * 100/375
        let height: CGFloat = width * 0.4
        $0.itemSize = .init(width: width, height: height)
        return $0
    }(UICollectionViewFlowLayout())
    lazy var collectionView: UICollectionView = {
        $0.isScrollEnabled = false
        $0.register(Reusable.genderCell.self)
        $0.backgroundColor = .red
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    func setUI() {
        [titleLabel, collectionView].forEach { addSubview($0) }
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
        }
        collectionView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing)
            $0.height.equalTo(UIScreen.main.bounds.width * 100/375 * 0.4).priority(.high)
            $0.trailing.top.bottom.equalToSuperview()
        }
    }
}

class AreaInputViewModel {
    
}

class AreaInputView: UIView{
    
    // MARK: - Properties
    // MARK: - Binding
    // MARK: - Initializer
    init(viewModel: AreaInputViewModel) {
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    // MARK: - UIComponents
    func setUI() {
        
    }
}

class ProfileViewModel {
    let nameInputViewModel: ProfileTextInputViewModel
    let emailInputViewModel: ProfileTextInputViewModel
    let phoneNumberInputViewModel: ProfileTextInputViewModel
    let genderInputViewModel: GenderInputViewModel
    let areaInputViewModel: AreaInputViewModel
    
    init(nameInputViewModel: ProfileTextInputViewModel, emailInputViewModel: ProfileTextInputViewModel, phoneNumberInputViewModel: ProfileTextInputViewModel, genderInputViewModel: GenderInputViewModel, areaInputViewModel: AreaInputViewModel) {
        self.nameInputViewModel = nameInputViewModel
        self.emailInputViewModel = emailInputViewModel
        self.phoneNumberInputViewModel = phoneNumberInputViewModel
        self.genderInputViewModel = genderInputViewModel
        self.areaInputViewModel = areaInputViewModel
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
            $0.bottom.equalToSuperview()
        }
        
        genderInputView.snp.makeConstraints {
            $0.top.equalTo(HLineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        areaInputView.snp.makeConstraints {
            $0.top.equalTo(genderInputView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
