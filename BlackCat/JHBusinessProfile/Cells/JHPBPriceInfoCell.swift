//
//  JHPBPriceInfoCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/05.
//

import UIKit
import SnapKit

final class JHBPPriceInfoCell: BPBaseCollectionViewCell {
    func configureCell(with description: String) {
        print(description)
        priceInfoDescriptionLabel.backgroundColor = .white
        priceInfoDescriptionLabel.text = description
    }
    
    func setUI() {
        contentView.addSubview(priceInfoDescriptionLabel)
        
        priceInfoDescriptionLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(30)
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var priceInfoDescriptionLabel: VerticalAlignLabel = {
        $0.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        return $0
    }(VerticalAlignLabel())
}

