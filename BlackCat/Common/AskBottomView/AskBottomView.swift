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
        return $0
    }(UIButton())

    let bookmarkView: UIView = {
        $0.backgroundColor = .init(hex: "#333333FF")
        $0.layer.cornerRadius = 20
        return $0
    }(UIView())

    private let heartButton: UIButton = {
        let heartImage = UIImage(systemName: "heart")?.withTintColor(.white).withRenderingMode(.alwaysOriginal)
        $0.setImage(heartImage, for: .normal)
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIButton())

    private let bookmarkCountLabel: UILabel = {
        $0.font = .systemFont(ofSize: 18)
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .white
        $0.text = "25"
        return $0
    }(UILabel())
}

extension AskBottomView {
    private func setUI() {
        self.backgroundColor = .clear

        [askButton, bookmarkView].forEach { addSubview($0) }

        bookmarkView.snp.makeConstraints {
            $0.width.equalTo(72)
            $0.top.trailing.bottom.equalToSuperview()
        }

        askButton.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(bookmarkView.snp.leading).offset(-12)
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
