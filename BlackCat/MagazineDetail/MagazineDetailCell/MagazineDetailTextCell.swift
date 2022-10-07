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
    static let identifier = String(describing: MagazineDetailTextCell.self)
    typealias Reactor = MagazineDetailTextCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        reactor.state.compactMap { $0 }
            .withUnretained(self)
            .bind { owner, item in
                owner.contentTextLabelBuilder(owner.contentTextLabel, item)
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Initalizing
    override func initialize() {
        self.setUI()
    }
   
    // MARK: - UIComponents
    private let contentTextLabel = UILabel()
    
}

extension MagazineDetailTextCell {
    func setUI() {
        addSubview(contentTextLabel)
        
        contentTextLabel.numberOfLines = 0
        contentTextLabel.lineBreakMode = .byWordWrapping
        contentTextLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
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
