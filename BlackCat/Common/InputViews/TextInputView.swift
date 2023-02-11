//
//  TextInputView.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/18.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class BaseTextViewModel {
    // MARK: Input
    let inputStringRelay: BehaviorRelay<String>
    let inputStringShare: Observable<String>
    
    // MARK: Output
    let inputStringDriver: Driver<String>
    let placeholderDriver: Driver<String>
    let hiddenPlaceholderLabelDriver: Driver<Bool>

    init(placeholder: String = "텍스트를 입력해주세요", inputStringRelay: BehaviorRelay<String> = BehaviorRelay<String>(value: "")) {
        self.inputStringRelay = inputStringRelay
        
        placeholderDriver = .just(placeholder)
        inputStringShare = inputStringRelay.share()
        
        hiddenPlaceholderLabelDriver = inputStringShare
            .map { $0 != "" }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
        
        inputStringDriver = inputStringShare
            .asDriver(onErrorJustReturn: "")

    }
}
class BaseTextView: UITextView {
    var disposeBag = DisposeBag()
    var viewModel: BaseTextViewModel
    
    // MARK: Initializer
    init(viewModel: BaseTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero, textContainer: nil)
        setUI()
        bind(to: viewModel)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Binding
    func bind(to viewModel: BaseTextViewModel) {
        rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.inputStringRelay)
            .disposed(by: disposeBag)

        viewModel.placeholderDriver
            .drive(placeholerLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.hiddenPlaceholderLabelDriver
            .drive(placeholerLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.inputStringDriver
            .drive(rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: UIComponents
    let placeholerLabel: UILabel = {
        let l = UILabel()
        l.font = .appleSDGoithcFont(size: 12, style: .regular)
        l.textColor = .init(hex: "#999999FF")
        return l
    }()
    
    func configure() {
        sizeToFit()
        isScrollEnabled = false
        font = .appleSDGoithcFont(size: 16, style: .medium)
        contentInset = .init(top: 5, left: 5, bottom: 0, right: 0)
        textContainerInset = .init(top: 10, left: 3, bottom: 28, right: 8)
        placeholerLabel.numberOfLines = 0
    }
    
    func setUI() {
        addSubview(placeholerLabel)
        
        placeholerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(13)
            $0.leading.equalToSuperview().inset(8)
        }
    }
}

struct TextInputViewModel {
    
    // MARK: - SubViewModels
    let baseTextViewModel: BaseTextViewModel
    
    // MARK: - Input
    let inputStringRelay: BehaviorRelay<String>
    
    // MARK: - Output
    let textCountLimitDriver: Driver<String>
    
    
    // MARK: - Output
    let titleStringDriver: Driver<String>
    init(title: String, placeholder: String = "텍스트를 입력해주세요", content: String = "", textCountLimit: Int = 500) {
        inputStringRelay = .init(value: content)
        titleStringDriver = .just(title)
        baseTextViewModel = .init(placeholder: placeholder, inputStringRelay: inputStringRelay)
        
        textCountLimitDriver = inputStringRelay
            .map { "(\($0.count)/\(textCountLimit))" }
            .asDriver(onErrorJustReturn: "")
    }
}

class TextInputView: UIView {
    // MARK: Properties
    var disposeBag = DisposeBag()
    var viewModel: TextInputViewModel
    
    // MARK: - Binding
    func bind(to viewModel: TextInputViewModel) {
        viewModel.titleStringDriver
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.textCountLimitDriver
            .drive(textCountLimitLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: Initializer
    init(viewModel: TextInputViewModel) {
        self.viewModel = viewModel
        textView = BaseTextView(viewModel: viewModel.baseTextViewModel)
        super.init(frame: .zero)
        textView.delegate = self
        setUI()
        bind(to: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIComponents
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .pretendardFont(size: 16, style: .bold)
        l.textColor = .init(hex: "#666666FF")
        return l
    }()
    var textView: BaseTextView
    let textCountLimitLabel: UILabel = {
        let l = UILabel()
        $0.textColor = .init(hex: "#999999FF")
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        return $0
    }(UILabel())
    
    func setUI() {
        [titleLabel, textView, textCountLimitLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(16)
        }
        
        textView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
        }
        
        textCountLimitLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
}

extension TextInputView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let text = textView.text else { return false }
        return text.count < 500 || range.length == 1
    }
}
