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
            .bind(to: viewModel.didTapCompleteButton)
            .disposed(by: disposeBag)
        
        viewModel.showCompleteAlertViewDriver
            .drive { _ in
                print("TODO: 업데이트 됐다고 Alert~")
            }.disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
        
        viewModel.limitExcessDriver
            .drive { _ in
                print("개수 초과 !")
            }.disposed(by: disposeBag)
        
        viewModel.imageListDrvier
            .drive(viewModel.tattooImageInputViewModel.imageDataListRelay)
            .disposed(by: disposeBag)
        
        viewModel.showImagePickerViewDriver
            .drive(with: self) { owner, _ in
                owner.showImagePickerView()
            }.disposed(by: disposeBag)
        
        viewModel.showWarningRemoveViewDrvier
            .drive { index in
                // TODO: - Alert 후 확인버튼 바인딩
                viewModel.didTapWariningRemoveViewConfirmButton.accept(index)
            }.disposed(by: disposeBag)
    }
    
    func showImagePickerView() {
        let imagePickerManager = ImagePickerManager()
        
        presentImagePicker(imagePickerManager.imagePicker) { _ in
        } deselect: { _ in
        } cancel: { _ in
        } finish: { [weak self] assets in
            guard let self else { return }
            self.viewModel.imageListInputRelay.accept(imagePickerManager.convertAssetToImage(assets))
        }
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
    init(viewModel: ProductEditViewModel = ProductEditViewModel()) {
        self.viewModel = viewModel
        tattooTypeInputView = .init(viewModel: viewModel.tattooTypeViewModel)
        titleInputView = .init(viewModel: viewModel.titleInputViewModel)
        tattooImageInputView = .init(viewModel: viewModel.tattooImageInputViewModel)
        descriptionInputView = .init(viewModel: viewModel.descriptionInputViewModel)
        genreInputView = .init(viewModel: viewModel.genreInputViewModel)
    
        super.init(nibName: nil, bundle: nil)
    
        setUI()
        bind(to: viewModel)
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: viewModel.type.title())
        view.layoutIfNeeded()
        print(tattooImageInputView.collectionView.contentSize)
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
    let tattooTypeInputView: TattooTypeInputView
    let warningLabel: UILabel = {
        $0.numberOfLines = 0
        $0.text = "작품 타입 선택이 부정확한 경우,\n비공개 처리되며 수정 요청드릴 수 있습니다."
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UILabel())
    let titleInputView: SimpleInputView
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
        [tattooTypeInputView, firstHLine, warningLabel, titleInputView, tattooImageInputView, descriptionInputView, secondHLine, genreInputView, firstHLine].forEach { contentView.addSubview($0) }
        
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
        
        tattooImageInputView.snp.makeConstraints {
            $0.top.equalTo(titleInputView.snp.bottom).offset(30)
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



