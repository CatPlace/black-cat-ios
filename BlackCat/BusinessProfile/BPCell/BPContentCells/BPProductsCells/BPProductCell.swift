//
//  BPProductCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit
import Nuke

// 🐻‍❄️ NOTE: - 다른 개발자님이 feature 이어 받으시도록 스타일로 맞춤.
final class BPProductCell: BPBaseCollectionViewCell {
    
    func configureCell(with item: BPProductModel) {
        loadImageUsingNuke(sender: productImageView, urlString: item.imageUrlString)
    }
    
    func setUI() {
        contentView.backgroundColor = .green
        contentView.addSubview(productImageView)
        
        productImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var productImageView: UIImageView = {
        $0.layer.backgroundColor = .init(gray: 1.0, alpha: 1.0)
        return $0
    }(UIImageView())
}
