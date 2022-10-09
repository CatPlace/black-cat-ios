//
//  UIFont+.swift
//  catplace
//
//  Created by SeYeong on 2022/09/29.
//

import UIKit

public extension UIFont {
    /// 프로젝트에 등록된 폰트를 사용합니다.
    /// 등록되지 않은 폰트이거나, 폰트에 적용될 수 없는 굵기를 적용하면 시스템폰트로 바뀝니다.
    static func catPlace(name: Font.Name = .gmarketSans, ofSize size: Font.Size, weight: Font.Weight) -> UIFont {
        let font = Font.CatPlaceFont(name: name, weight: weight)

        return _font(name: font.name, size: size.rawValue)
    }

    private static func _font(name: String, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            return .systemFont(ofSize: size)
        }

        return font
    }
}
