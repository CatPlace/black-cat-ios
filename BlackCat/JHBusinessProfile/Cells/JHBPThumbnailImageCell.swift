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
    
}
final class JHBPThumbnailImageCell: BPBaseCollectionViewCell {
    func bind(viewModel: JHBPThumbnailImageCellViewModel) {

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
        $0.backgroundColor = .gray
        return $0
    }(UIImageView())
}

