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
}

final class AskBottomView: UIView {

    let disposeBag = DisposeBag()

    private func bind(to viewModel: AskBottomViewModel) {
        disposeBag.insert {
            askLabel.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .debug("문의하기 탭")
                .bind(to: viewModel.didTapAskButton)
            
            bookmarkView.rx.tapGesture()
                .when(.recognized)
                .map { _ in () }
                .debug("북마크 탭")
                .bind(to: viewModel.didTapBookmarkButton)
        }
    }
    
    func setAskingText(_ text: String) {
        askLabel.text = text
    }

    func askButtonTag() -> Int {
        askLabel.tag
    }
    
    func setAskButtonTag(_ tag: Int) {
        askLabel.tag = tag
    }

    init(viewModel: AskBottomViewModel) {
        super.init(frame: .zero)
        
        setUI()
        bind(to: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let askLabel: UILabel = {
        $0.text = "문의하기"
        $0.tag = -1
        $0.textColor = .white
        $0.font = .appleSDGoithcFont(size: 24, style: .bold)
        $0.textAlignment = .center
        return $0
    }(UILabel())

    let bookmarkView = UIView()

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
        backgroundColor = .init(hex: "#333333FF")
        
        [askLabel, bookmarkView].forEach { addSubview($0) }

        askLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bookmarkView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        [heartButton, bookmarkCountLabel].forEach { bookmarkView.addSubview($0) }

        heartButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.width.equalTo(20)
            $0.height.equalTo(18)
            $0.centerY.equalToSuperview().offset(-10)
        }

        bookmarkCountLabel.snp.makeConstraints {
            $0.centerX.equalTo(heartButton)
            $0.centerY.equalToSuperview().offset(10)
        }
    }
}
