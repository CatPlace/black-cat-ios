//
//  ProfileEditViewController.swift.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/06.
//

import UIKit
import RxSwift
import RxKeyboard

class ProfileEditViewModel {
    
}

class ProfileEditViewController: VerticalScrollableViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: ProfileEditViewModel
    
    // MARK: - Binding
    func bind(to viewModel: ProfileEditViewModel) {
        coverImageChangeButton.rx.tap
            .bind { _ in
                print("커버 이미지 교체 tap")
            }.disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind { _ in
                print("수정 완료 tap")
            }.disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
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


//import BSImagePicker
//import Photos
//extension AddProductViewController {
//    func convertAssetToImages(_ sender: [PHAsset]) {
//        for i in 0..<sender.count {
//
//            let imageManager = PHImageManager.default()
//            let option = PHImageRequestOptions()
//            option.isSynchronous = true
//            option.deliveryMode = .highQualityFormat
//            imageManager.requestImage(for: sender[i],
//                                      targetSize: .zero,
//                                      contentMode: .aspectFill,
//                                      options: option) { [weak self] (result, info) in
//                self?.viewModel.photoImages.append(result!)
//            }
//
//        }
//        self.viewModel.photoInput.onNext(self.viewModel.photoImages)
//    }
//
//    func didTapCameraImageView() {
//        let imagePicker = ImagePickerController()
//        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
//
//        presentImagePicker(imagePicker) { _ in
//        } deselect: { _ in
//        } cancel: { _ in
//        } finish: { [weak self] (assets) in
//            guard let self else { return }
//
//            if assets.count + self.viewModel.photoImages.count < 13 {
//                self.convertAssetToImages(assets)
//            } else {
//                self.photoCount = -1
//            }
//        } completion: { [weak self] in
//            guard let self else { return }
//            if self.photoCount == -1 {
//                self.present(AlertViewController(message: "최대 사진 개수를 초과했습니다"), animated: true)
//                self.photoCount = self.viewModel.photoImages.count
//            }
//        }
//
//    }
}


