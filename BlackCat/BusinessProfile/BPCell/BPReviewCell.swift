//
//  BPReviewCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPReviewCell: BPBaseCell {
    
    func configureCell(with: BPReviewModel) {
        peiceLabel.text = with.imageUrlString
    }
    
    func setUI() {
        contentView.backgroundColor = .green
        contentView.addSubview(peiceLabel)
        
        peiceLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    let peiceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
}
