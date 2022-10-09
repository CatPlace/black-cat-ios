//
//  MagazineDetailImageCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/07.
//

import UIKit
import ReactorKit
import SnapKit

final class MagazineDetailImageCell: MagazineDetailBaseCell, View {
    typealias Reactor = MagazineDetailImageCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        reactor.state.compactMap { $0 }
            .withUnretained(self)
            .bind { owner, item in
                owner.contentImageViewBuilder(owner.contentImageView, item)
                owner.setUI(item)
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - UIComponents
    private let contentImageView = UIImageView()
    
}

extension MagazineDetailImageCell {
    func setUI(_ item: MagazineDetailModel) {
        addSubview(contentImageView)
        
        contentImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(item.layoutLeadingInset)
            $0.top.bottom.equalToSuperview()
        }
    }
}

final class MagazineDetailImageCellReactor: Reactor {

    typealias Action = NoAction

    var initialState: MagazineDetailModel

    init(initialState: MagazineDetailModel) {
        self.initialState = initialState
    }
}
