//
//  ProductEditViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/06.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import RxKeyboard
import Photos

class ProductEditViewController: VerticalScrollableViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: ProductEditViewModel
    
    // MARK: - Binding
    func bind(to viewModel: ProductEditViewModel) {
        tattooImageInputView.collectionView.rx.itemSelected
            .bind(to: viewModel.selectedIndexRelay)
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .do { [weak self] _ in self?.completeButton.isUserInteractionEnabled = false }
            .bind(to: viewModel.didTapCompleteButton)
            .disposed(by: disposeBag)
        
        viewModel.dismissDriver
            .drive(with: self) { owner, message in
                let vc = OneButtonAlertViewController(viewModel: .init(content: message, buttonText: "확인"))
                vc.delegate = owner
                owner.present(vc, animated: true)
                
            }.disposed(by: disposeBag)
        
        viewModel.OneButtonAlertDriver
            .drive(with: self) { owner, message in
                owner.completeButton.isUserInteractionEnabled = true
                let vc = OneButtonAlertViewController(viewModel: .init(content: message, buttonText: "확인"))
                owner.present(vc, animated: true)
            }.disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
        

        
        viewModel.imageListDrvier
            .drive(viewModel.tattooImageInputViewModel.imageDataListRelay)
            .disposed(by: disposeBag)
        
        viewModel.showImagePickerViewDriver
            .drive(with: self) { owner, _ in
                owner.showImagePickerView()
            }.disposed(by: disposeBag)
        
        viewModel.showWarningRemoveViewDrvier
            .drive(with: self) { owner, index in
                var indexList: [Int]
                if let index { indexList = [index] } else { indexList = [] }
                let vc = TwoButtonAlertViewController(viewModel: .init(type: .warningDelete(indexList)))
                vc.delegate = owner
                owner.present(vc, animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.pageTitleDriver
            .drive(with: self) { owner, title in
                owner.configure(title: title)
            }.disposed(by: disposeBag)
        
        viewModel.completeButtonTextDriver
            .drive(with: self) { owner, text in
                owner.completeButton.setTitle(text, for: .normal)
            }.disposed(by: disposeBag)
    }
    
    //MARK: - Function
    func showImagePickerView() {
        let imagePickerManager = ImagePickerManager()
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            presentImagePicker(imagePickerManager.imagePicker) { _ in
            } deselect: { _ in
            } cancel: { _ in
            } finish: { [weak self] assets in
                guard let self else { return }
                self.viewModel.imageListInputRelay.accept(imagePickerManager.convertAssetToImage(assets))
            }
        default:
            PHPhotoLibrary.requestAuthorization() { [weak self] afterStatus in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch afterStatus {
                    case .authorized:
                        self.presentImagePicker(imagePickerManager.imagePicker) { _ in
                        } deselect: { _ in
                        } cancel: { _ in
                        } finish: { [weak self] assets in
                            guard let self else { return }
                            self.viewModel.imageListInputRelay.accept(imagePickerManager.convertAssetToImage(assets))
                        }
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
        let alertController = UIAlertController(title: "권한 거부됨", message: "앨범 접근이 거부 되었습니다.\n 사진을 등록하시려면 설정으로 이동하여 앨범 접근 권한을 허용해주세요.", preferredStyle: UIAlertController.Style.alert)
        
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
    
    func configure(title: String) {
        view.backgroundColor = .init(hex: "#F4F4F4FF")
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: title)
    }
    
    // MARK: - Initializer
    init(viewModel: ProductEditViewModel = ProductEditViewModel()) {
        self.viewModel = viewModel
        tattooTypeInputView = .init(viewModel: viewModel.tattooTypeViewModel)
        titleInputView = .init(viewModel: viewModel.titleInputViewModel)
        priceInputView = .init(viewModel: viewModel.priceInputViewModel)
        tattooImageInputView = .init(viewModel: viewModel.tattooImageInputViewModel)
        descriptionInputView = .init(viewModel: viewModel.descriptionInputViewModel)
        genreInputView = .init(viewModel: viewModel.genreInputViewModel)
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackgroundColor(color: .init(hex: "#333333FF"))
    }
    
    // MARK: - UIComponents
    let tattooTypeInputView: TattooTypeInputView
    let warningLabel: UILabel = {
        $0.numberOfLines = 0
        $0.text = "작품 타입 선택이 부정확한 경우,\n비공개 처리되며 수정 요청드릴 수 있습니다."
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UILabel())
    let titleInputView: SimpleInputView
    let priceInputView: PriceInputView
    let tattooImageInputView: TattooImageInputView
    let descriptionInputView: TextInputView
    let genreInputView: GenreInputView
    let firstHLine: UIView = {
        $0.backgroundColor = .init(hex: "#666666FF")
        return $0
    }(UIView())
    let secondHLine: UIView = {
        $0.backgroundColor = .init(hex: "#666666FF")
        return $0
    }(UIView())
    let completeButton: CompleteButton = {
        $0.setTitle("수정 완료", for: .normal)
        return $0
    }(CompleteButton())
}

extension ProductEditViewController {
    func setUI() {
        [tattooTypeInputView, firstHLine, warningLabel, titleInputView, priceInputView, tattooImageInputView, descriptionInputView, secondHLine, genreInputView, firstHLine].forEach { contentView.addSubview($0) }
        
        tattooTypeInputView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(tattooTypeInputView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        firstHLine.snp.makeConstraints {
            $0.top.equalTo(warningLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        titleInputView.snp.makeConstraints {
            $0.top.equalTo(firstHLine.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        priceInputView.snp.makeConstraints {
            $0.top.equalTo(titleInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        tattooImageInputView.snp.makeConstraints {
            $0.top.equalTo(priceInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionInputView.snp.makeConstraints {
            $0.top.equalTo(tattooImageInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(Constant.height * 305)
        }
        
        secondHLine.snp.makeConstraints {
            $0.top.equalTo(descriptionInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        genreInputView.snp.makeConstraints {
            $0.top.equalTo(secondHLine.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(133)
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

extension ProductEditViewController: TwoButtonAlertViewDelegate {
    func didTapRightButton(type: TwoButtonAlertType) {
        switch type {
        case .warningDelete(let index):
            // TODO: - Alert 후 확인버튼 바인딩
            viewModel.didTapWariningRemoveViewConfirmButton.accept(index.first)
        default: return
        }
        dismiss(animated: true)
    }
    
    func didTapLeftButton(type: TwoButtonAlertType) {
        dismiss(animated: true)
    }
}

extension ProductEditViewController: OneButtonAlertDelegate {
    func didTapButton() {
        didTapBackButton()
    }
}
