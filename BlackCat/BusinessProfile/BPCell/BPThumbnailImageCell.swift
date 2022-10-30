//
//  BPThumbnailImageCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit
import ReactorKit
import SnapKit
import Nuke

final class BPThumbnailImageCell: BPBaseCell, View {
    typealias Reactor = BPThumnailImageCellReactor
    
    func bind(reactor: Reactor) {
        //
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

final class BPThumnailImageCellReactor: Reactor {
    typealias Action = NoAction

    var initialState: BPThumbnailModel

    init(initialState: BPThumbnailModel) {
        self.initialState = initialState
    }
}
