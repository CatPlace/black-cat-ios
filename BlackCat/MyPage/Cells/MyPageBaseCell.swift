//
//  BaseMyPageCell.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/24.
//

import UIKit

class MyPageBaseCell: BaseCollectionViewCell {
    func configureCell(cornerRadius: CGFloat = 15, y: CGFloat = 1, blur: CGFloat = 40) {
        contentView.layer.applyShadow(alpha: 0.15, y: y, blur: UIScreen.main.bounds.width * blur / 375.0)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = false
    }
}
