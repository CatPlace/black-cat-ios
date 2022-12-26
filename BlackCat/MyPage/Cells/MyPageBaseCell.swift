//
//  BaseMyPageCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import UIKit

class MyPageBaseCell: BaseCollectionViewCell {
    func configureCell(cornerRadius: CGFloat = 15, y: CGFloat = 1, blur: CGFloat = 40) {
        layer.applyShadow(alpha: 0.25, y: y, blur: UIScreen.main.bounds.width * blur / 375.0)
        
        backgroundColor = .white
        layer.cornerRadius = cornerRadius
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = false
    }
}
