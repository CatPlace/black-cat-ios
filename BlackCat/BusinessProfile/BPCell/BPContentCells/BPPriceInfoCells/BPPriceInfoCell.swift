//
//  BPPriceInfoCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/15.
//

import UIKit
import SnapKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPPriceInfoCell: BPBaseCollectionViewCell {
    
    func configureCell(with item: BPPriceInfoModel) {
        
        priceInfoLabel.text = item.text + "\n\n\n"
    }
    
    func setUI() {
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .white
        
        contentView.addSubview(priceInfoLabel)
        priceInfoLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var priceInfoLabel: UILabel = {
        $0.numberOfLines = 0
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        $0.font = .systemFont(ofSize: 16, weight: .semibold)

        return $0
    }(UILabel())
    
}

