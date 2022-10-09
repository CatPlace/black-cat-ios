//
//  MagazineDetailTextCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import UIKit
import ReactorKit
import SnapKit

final class MagazineDetailTextCell: MagazineDetailBaseCell, View {
    typealias Reactor = MagazineDetailTextCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        reactor.state.compactMap { $0 }
            .withUnretained(self)
            .bind { owner, item in
                owner.contentTextLabelBuilder(owner.contentTextLabel, item)
                owner.setUI(item)
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - UIComponents
    private let contentTextLabel = UILabel()
    
}

extension MagazineDetailTextCell {
    func setUI(_ item: MagazineDetailModel) {
        addSubview(contentTextLabel)
        
        contentTextLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(item.layoutLeadingInset)
            $0.trailing.equalToSuperview().inset(item.layoutTrailingInset)
            $0.top.equalToSuperview().inset(item.layoutTopInset)
            $0.bottom.equalToSuperview().inset(item.layoutBottomInset)
        }
    }
}

final class MagazineDetailTextCellReactor: Reactor {

    typealias Action = NoAction

    var initialState: MagazineDetailModel

    init(initialState: MagazineDetailModel) {
        self.initialState = initialState
    }
}
