//
//  OneButtonAlertViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/02/15.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import VisualEffectView

struct OneButtonAlertViewModel {
    
    // MARK: Output
    let contentStringDriver: Driver<String>
    let buttonTextDriver: Driver<String>
    let textColorDriver: Driver<UIColor?>
    
    init(content: String, buttonText: String, textColor: UIColor? = .init(hex: "#7210A0FF")) {
        contentStringDriver = .just(content)
        buttonTextDriver = .just(buttonText)
        textColorDriver = .just(textColor)
    }
}

protocol OneButtonAlertDelegate: AnyObject {
    func didTapButton()
}

class OneButtonAlertViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    weak var delegate: OneButtonAlertDelegate?
    
    // MARK: - Binding
    func bind(to viewModel: OneButtonAlertViewModel) {
        viewModel.contentStringDriver
            .drive(contentLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.buttonTextDriver
            .drive(completeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.textColorDriver
            .drive(completeLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        completeLabel.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .bind { owner, _ in
                    owner.dismiss(animated: true)
                    owner.delegate?.didTapButton()
            }.disposed(by: disposeBag)
    }
    
    func configure() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
    }
    
    // MARK: - Initializer
    init(viewModel: OneButtonAlertViewModel) {
        super.init(nibName: nil, bundle: nil)
        bind(to: viewModel)
        setUI()
        configure()
        [contentLabel, completeLabel].forEach(labelBuilder)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let blurEffectView: VisualEffectView = {
        let v = VisualEffectView()
        v.colorTintAlpha = 1
        v.backgroundColor = .black.withAlphaComponent(0.6)
        v.blurRadius = 5
        return v
    }()
    let contentView = UIView()
    let contentLabel = UILabel()
    let completeLabel = UILabel()
    let HLine: UIView = {
        $0.backgroundColor = .init(hex: "#C4C4C4FF")
        return $0
    }(UIView())
    func labelBuilder(_ sender: UILabel) {
        sender.font = .pretendardFont(size: 15,
                                      style: .light)
        sender.textAlignment = .center
    }
}

extension OneButtonAlertViewController {
    func setUI() {
        view.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(300 / 375.0)
            $0.height.equalToSuperview().multipliedBy(171 / 812.0)
        }
        
        [contentLabel, completeLabel, HLine].forEach { contentView.addSubview($0) }
        
        
        contentLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(121/171.0)
        }
        
        completeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(50/171.0)
        }
        
        HLine.snp.makeConstraints {
            $0.bottom.equalTo(completeLabel.snp.top)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(1)
        }
    }
}
