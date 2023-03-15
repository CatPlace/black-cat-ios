//
//  PriceInfoEditViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/06.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import RxKeyboard
import BlackCatSDK

class PriceInfoEditViewModel {
    let priceInfoInputViewModel: TextInputViewModel = .init(title: "견적서", textCountLimit: 700)
    
    var didTapCompleteButton = PublishRelay<Void>()
    
    let priceInfoDriver: Driver<String>
    let dismissDriver: Driver<Void>
    init() {
        var localTattooistInfo = CatSDKTattooist.localTattooistInfo()
        priceInfoDriver = .just(localTattooistInfo.estimate.description)
        
        let updatedResult = didTapCompleteButton
            .withLatestFrom(priceInfoInputViewModel.baseTextViewModel.inputStringRelay)
            .flatMap { CatSDKTattooist.updatePriceInfo(estimate: .init(description: $0)) }
            .share()
        
        let updateSuccess = updatedResult
            .filter { $0.description != "error" }
            .map { estimate in
                localTattooistInfo.estimate = estimate
                CatSDKTattooist.updateLocalTattooistInfo(tattooistInfo: localTattooistInfo)
            }
        
        // TODO: - 에러처리
        let updateFail = updatedResult
            .filter { $0.description == "error"}
        
        dismissDriver = updateSuccess
            .asDriver(onErrorJustReturn: ())
        
    }
}
class PriceInfoEditViewController: VerticalScrollableViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: PriceInfoEditViewModel
    
    // MARK: - Binding
    func bind(to viewModel: PriceInfoEditViewModel) {
        RxKeyboard.instance.visibleHeight
            .drive(with: self) { owner, keyboardVisibleHeight in
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind(to: viewModel.didTapCompleteButton)
            .disposed(by: disposeBag)
        
        viewModel.priceInfoDriver
            .drive(priceInfoInputView.textView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.dismissDriver
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Initializer
    init(viewModel: PriceInfoEditViewModel = PriceInfoEditViewModel()) {
        priceInfoInputView = .init(viewModel: viewModel.priceInfoInputViewModel)
        self.viewModel = viewModel
        super.init()
        appendNavigationLeftBackButton()
        appendNavigationLeftLabel(title: "견적서 편집")
        setUI()
        bind(to: viewModel)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(hex: "#F4F4F4FF")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBackgroundColor(color: .init(hex: "#333333FF"))
    }
    
    // MARK: - UIComponents
    let priceInfoInputView: TextInputView
    let completeButton: CompleteButton = {
        $0.setTitle("수정 완료", for: .normal)
        return $0
    }(CompleteButton())
}

extension PriceInfoEditViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI() {
        
        contentView.addSubview(priceInfoInputView)
        
        priceInfoInputView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(Constant.height * 700)
            $0.bottom.equalToSuperview().inset(30)
        }
        
        view.addSubview(completeButton)
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }
    }
}
