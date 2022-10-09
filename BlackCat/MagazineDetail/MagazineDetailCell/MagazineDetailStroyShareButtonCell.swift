//
//  MagazineDetailButtonCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/09.
//

import UIKit
import ReactorKit
import SnapKit

final class MagazineDetailStroyShareButtonCell: MagazineDetailBaseCell, View {
    typealias Reactor = MagazineDetailStroyShareButtonCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        reactor.state.compactMap { $0 }
            .withUnretained(self)
            .bind { owner, item in
//                owner.contentTextLabelBuilder(owner.contentTextLabel, item)
                owner.setUI(item)
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - UIComponents
    private let stroyShareButton = UIButton()
}

extension MagazineDetailStroyShareButtonCell {
    func setUI(_ item: MagazineDetailModel) {
        addSubview(stroyShareButton)
        
        self.configureStroyShareButton(sender: stroyShareButton)
        
        let width = UIScreen.main.bounds.width * 3 / 7
        let heigth = UIScreen.main.bounds.width * 3 / 7 * 2 / 7
        stroyShareButton.snp.makeConstraints {
            $0.width.equalTo(width)
            $0.height.greaterThanOrEqualTo(heigth)
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
    
    private func configureStroyShareButton(sender: UIButton) {
        sender.layer.cornerRadius = 12
        sender.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        sender.setTitle(" 스토리 공유", for: .normal)
        
        switch overrideUserInterfaceStyle {
        case .light, .unspecified:
            sender.tintColor = .systemBlue
            sender.backgroundColor = .darkGray
        case .dark:
            sender.tintColor = .white
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = .lightGray
        @unknown default:
            assert(true, "✨")
        }
    }
}

final class MagazineDetailStroyShareButtonCellReactor: Reactor {

    typealias Action = NoAction

    var initialState: MagazineDetailModel

    init(initialState: MagazineDetailModel) {
        self.initialState = initialState
    }
}

