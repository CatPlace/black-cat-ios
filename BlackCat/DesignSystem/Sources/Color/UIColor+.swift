//
//  UIColor_.swift
//  catplace
//
//  Created by SeYeong on 2022/09/29.
//

import UIKit

public extension UIColor {
    static func designSystem(_ color: Pallete) -> UIColor? {
        return UIColor(named: color.rawValue)
    }
}
