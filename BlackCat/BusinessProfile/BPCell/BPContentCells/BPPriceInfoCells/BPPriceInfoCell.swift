//
//  BPPriceInfoCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/15.
//

import UIKit
import SnapKit

// π»ββοΈ NOTE: - λ€λ₯Έ κ°λ°μλμ΄ feature μ΄μ΄ λ°μΌμλλ‘ μ€νμΌλ‘ λ§μΆ€.
final class BPPriceInfoCell: BPBaseCollectionViewCell {
    
    func configureCell(with item: BPPriceInfoModel) {
        
        priceInfoLabel.text = item.text + self.labelSpacing
    }
    
    func setUI() {
        contentView.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        
        contentView.addSubview(priceInfoLabel)
        priceInfoLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(30)
        }
        
        contentView.addSubview(priceInfoAdminLabel)
        priceInfoAdminLabel.snp.makeConstraints {
            $0.top.equalTo(priceInfoLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(priceInfoLabel)
            $0.bottom.equalToSuperview().inset(20)
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
    
    lazy var priceInfoAdminLabel: UILabel = {
        $0.numberOfLines = 0
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .lightGray
        $0.textAlignment = .center
        $0.text = "νν¬μ΄μ€νΈμ μν΄ μμ±λ μμ­μλλ€."

        return $0
    }(UILabel())
}

