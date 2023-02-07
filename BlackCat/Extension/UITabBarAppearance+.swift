//
//  UITabBarAppearance+.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/29.
//

import UIKit

extension UITabBarAppearance {
    func clearBackground() {
        UITabBar.appearance().backgroundColor = UIColor.white
        shadowColor = nil
        shadowImage = UIImage()
        backgroundImage = UIImage()
        backgroundColor = nil
        backgroundEffect = nil
    }
}
