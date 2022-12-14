//
//  BPProductCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import UIKit
import Nuke

// π»ββοΈ NOTE: - λ€λ₯Έ κ°λ°μλμ΄ feature μ΄μ΄ λ°μΌμλλ‘ μ€νμΌλ‘ λ§μΆ€.
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
        $0.layer.backgroundColor = UIColor.gray.cgColor
        return $0
    }(UIImageView())
}
