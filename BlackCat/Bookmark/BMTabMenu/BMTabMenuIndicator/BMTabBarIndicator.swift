//
//  KNTabBarIndicator.swift
//  KidsNoteAssignment
//
//  Created by SeYeong on 2022/11/06.
//

import UIKit

class BMTabBarIndicator: UIView {

    // MARK: - Properties

    override var tintColor: UIColor? {
        didSet {
            backgroundColor = tintColor
        }
    }

    var cornerStyle: CornerStyle = .eliptical {
        didSet {
            setNeedsLayout()
        }
    }

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        superview?.layoutSubviews()
        layer.cornerRadius = cornerStyle.cornerRadius(in: bounds)
    }
}
