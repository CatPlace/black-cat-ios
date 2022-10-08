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
    static let identifier = String(describing: MagazineDetailEmptyCell.self)
    typealias Reactor = MagazineDetailEmptyCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        reactor.state.compactMap { $0 }
            .withUnretained(self)
            .bind { owner, item in
                
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Initalizing
    override func initialize() {
        self.setUI()
    }
   
    // MARK: - UIComponents
    private let emptyView = UIImageView()
}

extension MagazineDetailEmptyCell {
    func setUI() {
        addSubview(emptyView)
        
        emptyView.snp.makeConstraints {
            $0.width.height.equalTo(10)
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.lessThanOrEqualToSuperview().inset(10)
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
