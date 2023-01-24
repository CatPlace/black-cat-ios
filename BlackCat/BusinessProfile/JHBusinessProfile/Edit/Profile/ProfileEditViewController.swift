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
                owner.openImageLibrary()
            }.disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind { _ in
                print("수정 완료 tap")
            }.disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
        
        viewModel.imageDriver
            .drive(coverImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    func openImageLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
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
    
    // MARK: - Initializer
    init(viewModel: ProfileEditViewModel = ProfileEditViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: "소개")
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(hex: "#F4F4F4FF")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackgroundColor(color: .init(hex: "#333333FF"))
    }
    
    
    // MARK: - UIComponents
    let coverImageView: UIImageView = {
        $0.image = .init(named: "DummyPict")
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    let coverImageChangeButton: UIButton = {
        $0.setTitle("커버 이미지 교체", for: .normal)
        $0.titleLabel?.font = .appleSDGoithcFont(size: 16, style: .bold)
        $0.layer.cornerRadius = 18
        $0.backgroundColor = .white.withAlphaComponent(0.4)
        return $0
    }(UIButton())
    let introduceEditView = TextInputView(viewModel: .init(title: "자기소개"))
    let completeButton: UIButton = {
        $0.setTitle("수정 완료", for: .normal)
        $0.titleLabel?.font = .appleSDGoithcFont(size: 24, style: .bold)
        $0.backgroundColor = .init(hex: "#333333FF")
        $0.layer.cornerRadius = 20
        return $0
    }(UIButton())
}

extension ProfileEditViewController {
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
            // 사진 촬영, 이미지 정보가 넘어옴
        let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        viewModel.imageRelay.accept(selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
}
