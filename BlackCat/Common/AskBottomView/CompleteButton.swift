//
//  CompleteButton.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/19.
//

import UIKit

class CompleteButton: UIButton {
    init() {
        super.init(frame: .zero)
        titleLabel?.font = .appleSDGoithcFont(size: 24, style: .semiBold)
        backgroundColor = .init(hex: "#333333FF")
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
