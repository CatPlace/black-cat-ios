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
        contentTextLabel.text = "도라에몽"
        contentTextLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
}
