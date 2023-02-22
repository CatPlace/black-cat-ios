//
//  AskBottomView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/12/28.
//

import UIKit

import SnapKit
import RxCocoa
import RxGesture
import RxSwift

struct AskBottomViewModel {
    let disposeBag = DisposeBag()

    let didTapAskButton = PublishRelay<Void>()
    let didTapBookmarkButton = PublishRelay<Void>()
    
    init() {
        didTapAskButton
            .subscribe { _ in print("Did Tap Ask Button") }
            .disposed(by: disposeBag)

        didTapBookmarkButton
            .subscribe { _ in print("Did Tap Bookmark Button") }
            .disposed(by: disposeBag)
    }
}

final class AskBottomView: UIView {

    let disposeBag = DisposeBag()
    let viewModel = AskBottomViewModel()

    private func bind(to viewModel: AskBottomViewModel) {
        disposeBag.insert {
            askButton.rx.tap
                .bind(to: viewModel.didTapAskButton)

            bookmarkView.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .bind(to: viewModel.didTapBookmarkButton)
        }
    }
    
    func setAskingText(_ text: String) {
        askButton.setTitle(text, for: .normal)
    }

    func askButtonTag() -> Int {
        askButton.tag
    }
    
    func setAskButtonTag(_ tag: Int) {
        askButton.tag = tag
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUI()
        bind(to: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let askButton: UIButton = {
        $0.setTitle("문의하기", for: .normal)
        $0.backgroundColor = .init(hex: "#333333FF")
        $0.layer.cornerRadius = 20
        $0.tag = -1
        $0.titleLabel?.font = .appleSDGoithcFont(size: 24, style: .bold)
        return $0
    }(UIButton())

    let bookmarkView: UIView = {
        $0.backgroundColor = .init(hex: "#333333FF")
        $0.layer.cornerRadius = 20
        return $0
    }(UIView())

    let heartButton: UIButton = {
        let heartImage = UIImage(named: "like")
        $0.setImage(heartImage, for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
        return $0
    }(UIButton())

    let bookmarkCountLabel: UILabel = {
        $0.font = .appleSDGoithcFont(size: 18, style: .regular)
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .white
        return $0
    }(UILabel())

}

extension AskBottomView {
    private func setUI() {
        self.backgroundColor = .clear

        [askButton, bookmarkView].forEach { addSubview($0) }

        askButton.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(Constant.width * 251)
        }
        
        bookmarkView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(askButton.snp.trailing).offset(12)
        }

        [heartButton, bookmarkCountLabel].forEach { bookmarkView.addSubview($0) }

        heartButton.snp.makeConstraints {
            $0.leading.equalTo(14)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(20)
            $0.height.equalTo(18)
        }

        bookmarkCountLabel.snp.makeConstraints {
            $0.leading.equalTo(heartButton.snp.trailing).offset(5)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(14)
        }
    }
}
