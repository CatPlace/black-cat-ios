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
                owner.contentTextLabel.text = item.text
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Initalizing
    override func initialize() {
        self.setUI()
    }
   
    // MARK: - UIComponents
    private let contentTextLabel = UILabel()
    
    func contentLabelBuilder(_ sender: UILabel, _ item: MagazineDetailModel) {
        sender.textColor = item.textColor.toUIColor()
        sender.text = item.text
        sender.textAlignment = item.textAlignment.toNSTextAlignment()
    }
}

extension MagazineDetailTextCell {
    func setUI() {
        addSubview(contentTextLabel)
        
        contentTextLabel.numberOfLines = 0
        contentTextLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
}
