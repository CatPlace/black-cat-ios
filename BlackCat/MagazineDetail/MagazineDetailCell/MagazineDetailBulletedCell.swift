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
    typealias Reactor = MagazineDetailBulletedCellReactor
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        reactor.state.compactMap { $0 }
            .withUnretained(self)
            .bind { owner, item in
                owner.setUI(item)
                
                owner.contentTextLabelBuilder(owner.contentTextLabel, item)
                owner.contentImageViewBuilder(owner.contentImageView, item)
            }
            .disposed(by: self.disposeBag)
    }

    // MARK: - UIComponents
    private let contentImageView = UIImageView()
    private let contentTextLabel = UILabel()
    
    override func contentImageViewBuilder(_ sender: UIImageView, _ item: MagazineDetailModel) {
        
        // 부모먼저 호출해서 초기화
        super.contentImageViewBuilder(sender, item)
        
        contentImageView.backgroundColor = .darkGray
        contentImageView.layer.cornerRadius = CGFloat(item.layoutHeight) / 2.0
    }
}

extension MagazineDetailBulletedCell {
    func setUI(_ item: MagazineDetailModel) {
        [contentImageView, contentTextLabel].forEach { addSubview($0) }
        
        contentImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        contentImageView.snp.makeConstraints {
            $0.width.height.equalTo(item.layoutHeight)
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().inset(item.layoutLeadingInset)
            $0.bottom.lessThanOrEqualToSuperview().inset(10)
        }
//        print("contentImageView \(contentImageView.fra)")
        
        contentTextLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentTextLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalTo(contentImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(item.layoutTrailingInset)
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
