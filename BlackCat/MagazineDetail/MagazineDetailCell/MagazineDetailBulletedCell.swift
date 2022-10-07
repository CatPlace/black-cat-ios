//
//  MagazineDetailBulletedCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/07.
//

import UIKit
import ReactorKit
import SnapKit

final class MagazineDetailBulletedCell: MagazineDetailBaseCell, View {
    static let identifier = String(describing: MagazineDetailBulletedCell.self)
    typealias Reactor = MagazineDetailBulletedCellReactor
    
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
    private let bulletImageView = UIImageView()
    private let contentTextLabel = UILabel()
}

extension MagazineDetailBulletedCell {
    func setUI() {
        [bulletImageView, contentTextLabel].forEach { addSubview($0) }
        
        bulletImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.leading.equalToSuperview().offset(24)
        }
        
        contentTextLabel.snp.makeConstraints {
            $0.leading.equalTo(bulletImageView.snp.trailing).offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(bulletImageView.snp.top)
        }
    }
}

final class MagazineDetailBulletedCellReactor: Reactor {

    typealias Action = NoAction

    var initialState: MagazineDetailModel

    init(initialState: MagazineDetailModel) {
        self.initialState = initialState
    }
}
