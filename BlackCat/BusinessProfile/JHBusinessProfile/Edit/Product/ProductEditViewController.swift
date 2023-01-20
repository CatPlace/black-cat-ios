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
import BlackCatSDK
import RxKeyboard

enum ProductInputType {
    case add, modify
    
    func title() -> String {
        switch self {
        case .add: return "타투 업로드"
        case .modify: return "타투 수정"
        }
    }
}

class ProductEditViewModel {
    let tattooImageInputViewModel = TattooImageInputViewModel()
    let genreInputViewModel = GenreInputViewModel()
    
    let type: ProductInputType
    
    init(type: ProductInputType) {
        self.type = type
    }
}

class ProductEditViewController: VerticalScrollableViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: ProductEditViewModel
    
    // MARK: - Binding
    func bind(to viewModel: ProductEditViewModel) {
        tattooImageInputView.collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.didTapCameraImageView()
                
            }.disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind { _ in
                print("타투 수정 페이지 완료 tap")
            }.disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
    }
    
    func didTapCameraImageView() {
        let imagePickerManager = ImagePickerManager()
    
        presentImagePicker(imagePickerManager.imagePicker) { _ in
        } deselect: { _ in
        } cancel: { _ in
        } finish: { [weak self] (assets) in
            imagePickerManager.convertAssetToImages(assets)
            print(imagePickerManager.photoImages)
        } completion: { [weak self] in
            print(imagePickerManager.photoImages)
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
    init(viewModel: ProductEditViewModel = ProductEditViewModel(type: .add)) {
        self.viewModel = viewModel
        self.tattooImageInputView = .init(viewModel: viewModel.tattooImageInputViewModel)
        self.genreInputView = .init(viewModel: viewModel.genreInputViewModel)
        super.init(nibName: nil, bundle: nil)
        setUI()
        bind(to: viewModel)
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: viewModel.type.title())
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
    let titleInputView = SimpleInputView(viewModel: .init(type: .tattooTitle))
    let tattooImageInputView: TattooImageInputView
    let descriptionInputView = TextInputView(viewModel: .init(title: "내용"))
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
        [titleInputView, tattooImageInputView, descriptionInputView, firstHLine, genreInputView, secondHLine].forEach { contentView.addSubview($0) }
        
        titleInputView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        tattooImageInputView.snp.makeConstraints {
            $0.top.equalTo(titleInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionInputView.snp.makeConstraints {
            $0.top.equalTo(tattooImageInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(Constant.height * 279)
        }
        
        firstHLine.snp.makeConstraints {
            $0.top.equalTo(descriptionInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        genreInputView.snp.makeConstraints {
            $0.top.equalTo(firstHLine.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(14)
        }
        
        secondHLine.snp.makeConstraints {
            $0.top.equalTo(genreInputView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview().inset(203)
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



