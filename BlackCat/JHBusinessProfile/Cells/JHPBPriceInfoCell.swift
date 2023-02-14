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
        textView.text = description
    }
    
    func setUI() {
        print("setUI~~~~🌈🌈🌈🌈")
        contentView.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        
        contentView.addSubview(textView)
        
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(400)
        }
        backgroundColor = .orange
    }
    
    override func initialize() {
        self.setUI()
    }
    
    let textView: UITextView = {
        return $0
    }(UITextView())
}

