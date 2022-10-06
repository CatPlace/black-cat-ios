//
//  MagazineDetailTextCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import UIKit
import ReactorKit
import SnapKit

class MagazineDetailBaseCell: UITableViewCell {
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Initializing
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        self.setUI()
    }
    
    func setUI() { /* override setUI */ }
}

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
