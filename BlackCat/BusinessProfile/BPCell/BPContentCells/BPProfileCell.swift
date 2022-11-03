//
//  BPProfileCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/03.
//

import UIKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPProfileCell: BPBaseCell {
    
    func configureCell(with item: BPProductModel) {
        
    }
    
    func setUI() {
        
        contentView.addSubview(infoTextView)
        infoTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(30)
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var infoTextView = UITextView()
    lazy var descriptionTextView = UITextView()
}
