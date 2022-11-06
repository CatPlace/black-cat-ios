//
//  BPPriceInfoEditCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/06.
//

import Foundation
import UIKit

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPPriceInfoEditTextCell: BaseTableViewCell {
    
    func configureCell(with item: BPPriceInfoEditModel) {
//        profileTitleLabel.text = item.title
//        profileDescriptionLabel.text = item.description
    }
    
    func setUI() {
        contentView.backgroundColor = .green
        contentView.addSubview(editTextView)
        editTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(50)
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var editTextView: UITextView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        $0.isScrollEnabled = false
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        
        return $0
    }(UITextView())
}
