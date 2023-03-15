//
//  ProfileEditViewController.swift.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/06.
//

import UIKit
import RxSwift
import RxKeyboard

class ProfileEditViewController: ImageCropableViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: ProfileEditViewModel
    
    // MARK: - Binding
    func bind(to viewModel: ProfileEditViewModel) {
        coverImageChangeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.activeActionSheet(with: "커버")
            }.disposed(by: disposeBag)
        
        selectedImage
            .map { $0 as Any }
            .bind(to: viewModel.imageRelay)
            .disposed(by: disposeBag)
        
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
    
   func updateView(with height: CGFloat) {
        scrollView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(height)
        }
        
        completeButton.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(
                height == 0
                ? 0
                : height
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
        super.init(cropShapeType: .rect)
        
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
    let scrollView = UIScrollView()
    let contentView = UIView()
    
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
    let completeButton: CompleteButton = {
        $0.setTitle("수정 완료", for: .normal)
        return $0
    }(CompleteButton())
}

extension ProfileEditViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
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
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }
    }
}
