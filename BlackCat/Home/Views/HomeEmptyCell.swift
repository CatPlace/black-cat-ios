//
//  HomeEmptyCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/07.
//

import UIKit

class HomeEmptyCell: UICollectionViewCell {
    static let identifier = String(describing: self)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .lightGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
