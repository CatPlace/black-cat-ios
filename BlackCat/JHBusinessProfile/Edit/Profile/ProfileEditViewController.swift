//
//  ProfileEditViewController.swift.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/06.
//

import UIKit
import RxSwift
import RxKeyboard
import PhotosUI

class ProfileEditViewController: VerticalScrollableViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: ProfileEditViewModel
    
    // MARK: - Binding
    func bind(to viewModel: ProfileEditViewModel) {
        coverImageChangeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.activeActionSheet()
            }.disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind(to: viewModel.didTapCompleteButton)
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
        
        viewModel.imageDriver
            .drive(with: self) { owner, image in
                if let image {
                    owner.coverImageView.image = image
                } else {
                    owner.coverImageView.image = .init(named: "defaultCover")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.updateSuccessDriver
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.updateFailDriver
            .drive(with: self) { owner, message in
                // TODO: 알러트
                print(message)
            }.disposed(by: disposeBag)
        
        viewModel.introduceDriver
            .drive(introduceEditView.textView.rx.text)
            .disposed(by: disposeBag)
    }
    
    func activeActionSheet() {
        let actionSheet = UIAlertController(title: "커버 이미지 관리", message: nil, preferredStyle: .actionSheet)
        let updateImageAction = UIAlertAction(title: "커버 이미지 변경", style: .default) { [weak self] action in
            guard let self else { return }
            self.openImageLibrary()
        }
        let deleteImageAction = UIAlertAction(title: "커버 이미지 삭제", style: .destructive) { [weak self] action in
            guard let self else { return }
            
            self.viewModel.imageRelay.accept(nil)
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        [updateImageAction, deleteImageAction, actionCancel].forEach { actionSheet.addAction($0) }
        
        self.present(actionSheet, animated: true)
    }
    
    func openImageLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            present(imagePicker, animated: true)
        default:
            PHPhotoLibrary.requestAuthorization() { [weak self] afterStatus in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch afterStatus {
                    case .authorized:
                        self.present(imagePicker, animated: true)
                    case .denied:
                        self.moveToSetting()
                    default:
                        break
                    }
                }
            }
        }
    }
    
    
    func moveToSetting() {
        let alertController = UIAlertController(title: "권한 거부됨", message: "앨범 접근이 거부 되었습니다.\n 사진을 변경하시려면 설정으로 이동하여 앨범 접근 권한을 허용해주세요.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "설정으로 이동하기", style: .default) { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: false, completion: nil)
    }
    
   func updateView(with height: CGFloat) {
        scrollView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(height)
        }
        
        completeButton.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(
                height == 0
                ? 30
                : height + 15
            )
        }
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    func configure() {
        view.backgroundColor = .init(hex: "#F4F4F4FF")
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: "소개")
    }
    
    // MARK: - Initializer
    init(viewModel: ProfileEditViewModel = ProfileEditViewModel()) {
        introduceEditView = .init(viewModel: viewModel.introduceEditViewModel)
        self.viewModel = viewModel
        super.init()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bind(to: viewModel)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackgroundColor(color: .init(hex: "#333333FF"))
    }
    
    // MARK: - UIComponents
    let coverImageView: UIImageView = {
        $0.image = .init(named: "defaultCover")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        return $0
    }(UIImageView())
    let coverImageChangeButton: UIButton = {
        $0.setTitle("커버 이미지 교체", for: .normal)
        $0.titleLabel?.font = .appleSDGoithcFont(size: 16, style: .bold)
        $0.layer.cornerRadius = 18
        $0.backgroundColor = .white.withAlphaComponent(0.4)
        return $0
    }(UIButton())
    let introduceEditView: TextInputView
    let completeButton: UIButton = {
        $0.setTitle("수정 완료", for: .normal)
        $0.titleLabel?.font = .appleSDGoithcFont(size: 24, style: .bold)
        $0.backgroundColor = .init(hex: "#333333FF")
        $0.layer.cornerRadius = 20
        return $0
    }(UIButton())
}

extension ProfileEditViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI() {
        [coverImageView, coverImageChangeButton, introduceEditView].forEach { contentView.addSubview($0) }
        
        coverImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.height * 375)
        }
        
        coverImageChangeButton.snp.makeConstraints {
            $0.bottom.equalTo(coverImageView).inset(15)
            $0.width.equalTo(Constant.width * 150)
            $0.height.equalTo(Constant.height * 36)
            $0.centerX.equalToSuperview()
        }
        
        introduceEditView.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.bottom).offset(30)
            $0.height.greaterThanOrEqualTo(Constant.height * 279)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(Constant.height * 60 + 30)
        }
        
        view.addSubview(completeButton)
        completeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(30)
            $0.width.equalTo(Constant.width * 251)
            $0.height.equalTo(Constant.height * 60)
            $0.centerX.equalToSuperview()
        }
    }
}

extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        viewModel.imageRelay.accept(selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
}
