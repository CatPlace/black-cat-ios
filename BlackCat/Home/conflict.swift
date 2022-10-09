//
//  conflict.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/09.
//

import UIKit

extension UIColor {
    static func designSystem(_ color: Pallete) -> UIColor? {
        return UIColor(named: color.rawValue)
    }
}

enum Pallete: String {
    case background
}
