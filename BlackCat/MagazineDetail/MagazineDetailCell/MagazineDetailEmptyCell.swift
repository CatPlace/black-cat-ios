//
//  MagazineDetailEmptyCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/08.
//

import UIKit
import ReactorKit
import SnapKit

final class MagazineDetailEmptyCell: MagazineDetailBaseCell, View {
    typealias Reactor = MagazineDetailEmptyCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        reactor.state.compactMap { $0 }
            .withUnretained(self)
            .bind { owner, item in owner.setUI(item.layoutHeight) }
            .disposed(by: self.disposeBag)
    }
   
    // MARK: - UIComponents
    private var emptyView = UIView()
}

extension MagazineDetailEmptyCell {
    func setUI(_ height: Int = 0) {
        addSubview(emptyView)

        emptyView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(height)
            $0.bottom.equalToSuperview()
        }
    }
}

final class MagazineDetailEmptyCellReactor: Reactor {
    typealias Action = NoAction

    var initialState: MagazineDetailModel

    init(initialState: MagazineDetailModel) {
        self.initialState = initialState
    }
}
