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

class ProfileViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: ProfileViewModel
    
    // MARK: - Binding
    func bind(to viewModel: ProfileViewModel) {
        
        disposeBag.insert {
            uploadCoverView.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .bind { owner, _ in
                    owner.openImageLibrary()
                }
            
            completeButtonLabel.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .bind(to: viewModel.completeButtonTapped)
        }
        
        viewModel.completeAlertDriver
            .drive(with: self) { owner, _ in
                // TODO: Alert
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.alertMassageDriver
            .drive(with: self) { owner, message in
                let vc = OneButtonAlertViewController(viewModel: .init(content: message, buttonText: "확인"))
                owner.present(vc, animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.profileImageDriver
            .debug("프로필 이미지 업데이트 ~~")
            .drive(profileImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Function
    func openImageLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func configure() {
        view.backgroundColor = .init(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: "프로필")
    }
    
    // MARK: - Initializer
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        
        nameInputView = SimpleInputView(viewModel: viewModel.nameInputViewModel)
        emailInputView = SimpleInputView(viewModel: viewModel.emailInputViewModel)
        phoneNumberInputView = SimpleInputView(viewModel: viewModel.phoneNumberInputViewModel)
        genderInputView = GenderInputView(viewModel: viewModel.genderInputViewModel)
        areaInputView = AreaInputView(viewModel: viewModel.areaInputViewModel)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setUI()
        bind(to: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBackgroundColor(color: .init(hex: "#333333FF"))
    }
    
    // MARK: - UIComponents
    let scrollView = UIScrollView()
    let contentView = UIView()
    lazy var profileImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = view.frame.width * 4 / 25
        v.clipsToBounds = true
        return v
    }()
    lazy var uploadCoverView: UIView = {
        $0.backgroundColor = .init(hex: "#333333FF")?.withAlphaComponent(0.6)
        $0.layer.cornerRadius = view.frame.width * 4 / 25
        $0.clipsToBounds = true
        return $0
    }(UIView())
    let uploadImageView: UIImageView = {
        $0.image = UIImage(named: "upload")
        return $0
    }(UIImageView())
    let nameInputView: SimpleInputView
    let emailInputView: SimpleInputView
    let phoneNumberInputView: SimpleInputView
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
        $0.font = .appleSDGoithcFont(size: 24, style: .bold)
        $0.textAlignment = .center
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
        
        [profileImageView, uploadCoverView, uploadImageView, nameInputView, emailInputView, phoneNumberInputView, HLineView, genderInputView, areaInputView].forEach { contentView.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(view.frame.width * 8 / 25)
            $0.top.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        uploadCoverView.snp.makeConstraints {
            $0.edges.equalTo(profileImageView)
        }
        uploadImageView.snp.makeConstraints {
            $0.center.equalTo(uploadCoverView)
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        viewModel.imageInputRelay.accept(selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
}
