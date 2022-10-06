//
//  MagazineDetailTextCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import UIKit
import ReactorKit
import SnapKit

class MagazineDetailTextCell: MagazineDetailBaseCell, View {
    static let identifier = String(describing: MagazineDetailTextCell.self)
    typealias Reactor = MagazineDetailTextCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        
    }
    
    override func setUI() {
        addSubview(contentTextLabel)
        
        contentTextLabel.numberOfLines = 0
        contentTextLabel.text = "도라에몽"
        contentTextLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
    
    // MARK: - UIComponents
    private let contentTextLabel = UILabel()
}

class MagazineDetailTextCellReactor: Reactor {

    typealias Action = NoAction

    struct State { }

    var initialState = State()

    init(initialState: State = State()) {
        self.initialState = initialState
    }
}
