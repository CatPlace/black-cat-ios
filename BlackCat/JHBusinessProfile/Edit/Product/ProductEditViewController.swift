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

class ProductEditViewController: ImageCropableViewController {
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
        
        selectedImage
            .compactMap { $0 }
            .map { [$0] }
            .bind(to: viewModel.imageListInputRelay)
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
                owner.openImageLibrary()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackgroundColor(color: .init(hex: "#333333FF"))
    }
    
    // MARK: - UIComponents
    let scrollView = UIScrollView()
    let contentView = UIView()
    
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
    let tattooSizeRequestLabel: UILabel = {
        $0.text = "1:1 비율을 권장합니다."
        $0.textColor = .init(hex: "#999999FF")
        $0.font = .appleSDGoithcFont(size: 12, style: .regular)
        return $0
    }(UILabel())
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
        
        [tattooTypeInputView, firstHLine, warningLabel, titleInputView, tattooSizeRequestLabel, priceInputView, tattooImageInputView, descriptionInputView, secondHLine, genreInputView, firstHLine].forEach { contentView.addSubview($0) }
        
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
        
        tattooSizeRequestLabel.snp.makeConstraints {
            $0.centerY.equalTo(tattooImageInputView.titleLabel)
            $0.leading.equalTo(tattooImageInputView.titleLabel.snp.trailing).offset(20)
            $0.trailing.equalTo(tattooImageInputView.limitLabel.snp.leading).offset(20)
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
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
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
