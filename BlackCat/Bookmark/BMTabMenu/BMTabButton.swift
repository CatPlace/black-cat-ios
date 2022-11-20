//
//  KNButton.swift
//  KidsNoteAssignment
//
//  Created by SeYeong on 2022/11/03.
//

import UIKit

protocol BMTabButtonDelegate: AnyObject {
    func didSelectButton(tag: Int)
}

class BMTabButton: UIButton {

    // MARK: - Properties

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted { delegate?.didSelectButton(tag: tag) }
        }
    }

    override var tintColor: UIColor? {
        didSet {
            setTitleColor(tintColor, for: .normal)
        }
    }

    var title: String? {
        didSet {
            setTitle(title, for: .normal)
        }
    }

    weak var delegate: BMTabButtonDelegate?

    // MARK: - Initializi

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
