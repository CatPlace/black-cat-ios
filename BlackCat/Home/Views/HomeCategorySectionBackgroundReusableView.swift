//
//  HomeSectionBackgroundView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/07.
//

import UIKit

class HomeCategorySectionBackgroundReusableView: UICollectionReusableView {

    static let identifier = String(describing: HomeCategorySectionBackgroundReusableView.self)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .designSystem(.BackgroundSecondary)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}