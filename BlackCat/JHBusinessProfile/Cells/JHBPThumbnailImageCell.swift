//
//  JHBPThumbnailImageCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Nuke

final class JHBPThumbnailImageCellViewModel {
    let imageUrlStringDriver: Driver<String>
    
    init(imageUrlString: String) {
        self.imageUrlStringDriver = .just(imageUrlString)
    }
    
}
final class JHBPThumbnailImageCell: BPBaseCollectionViewCell {
    func bind(viewModel: JHBPThumbnailImageCellViewModel) {
        viewModel.imageUrlStringDriver
            .compactMap { URL(string: $0) }
            .drive(with: self) { owner, url in
                Nuke.loadImage(with: url, into: owner.thumnailImageView)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - initialize
    override func initialize() {
        self.setUI()
    }
    
    private func setUI() {
        contentView.addSubview(thumnailImageView)
        // 🐻‍❄️ NOTE: - Pin + Flex 조합으로 변경 가능하면 바꾸기
        thumnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    let thumnailImageView: UIImageView = {
        $0.image = .init(named: "defaultCover")
        return $0
    }(UIImageView())
}

