//
//  HomeSectionBackgroundView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/07.
//

import UIKit

class HomeGenreSectionBackgroundReusableView: UICollectionReusableView {

    // MARK: - Properties

    static let identifier = String(describing: HomeGenreSectionBackgroundReusableView.self)

    // MARK: - Initializing

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .init(hex: "#F4F4F4FF")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
