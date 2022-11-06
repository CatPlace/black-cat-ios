//
//  BPPriceInfoEditImageCell.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/06.
//

import UIKit

final class BPPriceInfoEditImageCell: BaseTableViewCell {
    
    func configureCell(with item: BPPriceInfoEditModel) {
        editImageView.image = item.image
    }
    
    func setUI() {
        contentView.backgroundColor = .blue
        contentView.addSubview(editImageView)
        editImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(50)
        }
    }
    
    override func initialize() {
        self.setUI()
    }
    
    lazy var editImageView: UIImageView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        return $0
    }(UIImageView())
}
