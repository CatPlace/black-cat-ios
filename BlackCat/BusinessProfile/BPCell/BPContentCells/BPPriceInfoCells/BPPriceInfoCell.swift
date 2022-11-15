//
//  BPPriceInfoCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/15.
//

import UIKit
import SnapKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPPriceInfoCell: BPBaseCell {
    
    func configureCell(with item: BPPriceInfoModel) {
        print("A")
        textView.text = item.text
    }
    
    func setUI() {
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .white
        
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var textView: UITextView = {
        $0.layer.cornerRadius = 18
        $0.backgroundColor = UIColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 1)
        
        return $0
    }(UITextView())
    
}

