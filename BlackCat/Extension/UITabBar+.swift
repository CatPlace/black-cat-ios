//
//  UITabBar.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/08.
//

import UIKit

extension UITabBar {
    /// UITabBar의 기본 스타일을 빼내는 코드
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
    }
}
