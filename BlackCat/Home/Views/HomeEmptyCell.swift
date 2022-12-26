//
//  HomeEmptyCell.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/07.
//

import UIKit

class HomeEmptyCell: UICollectionViewCell {

    // MARK: - Initializing

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .init(hex: "#F4F4F4")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
