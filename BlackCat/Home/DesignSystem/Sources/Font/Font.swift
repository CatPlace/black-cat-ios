//
//  Font.swift
//  catplace
//
//  Created by SeYeong on 2022/09/29.
//

import UIKit

public enum Font {

    // 폰트 추가되면 Name enum에만 등록해주세요!😃
    public enum Name: String {
        case gmarketSans = "GmarketSans"
    }

    public enum Size: CGFloat {
        case _50 = 50
        case _30 = 30
        case _25 = 25
        case _20 = 20
        case _18 = 18
        case _17 = 17
        case _15 = 15
        case _13 = 13
        case _10 = 10
        case _9 = 9
    }

    public enum Weight: String {
        case heavy = "Heavy"
        case bold = "Bold"
        case regular = "Regular"
        case medium = "Medium"
        case light = "Light"

        var real: UIFont.Weight {
            switch self {
            case .heavy:
                return .heavy
            case .bold:
                return .bold
            case .regular:
                return .regular
            case .medium:
                return .medium
            case .light:
                return .light
            }
        }
    }

    public struct CatPlaceFont {
        private let _name: Name
        private let _weight: Weight

        init(name: Name, weight: Weight) {
            self._name = name
            self._weight = weight
        }

        var name: String {
            return "\(_name.rawValue)TTF\(_weight.rawValue)"
        }

        var `extension`: String {
            return "ttf"
        }
    }

    public static func registerFonts() {
        fonts.forEach { font in
            Font.registerFont(fontName: font.name, fontExtension: font.extension)
        }
    }
}

extension Font {
    public static var fonts: [CatPlaceFont] {
        [
            CatPlaceFont(name: .gmarketSans, weight: .light),
            CatPlaceFont(name: .gmarketSans, weight: .medium),
            CatPlaceFont(name: .gmarketSans, weight: .bold)
        ]
    }

    private static func registerFont(fontName: String, fontExtension: String) {
        guard let fontURL = Bundle(identifier: "kr.co.catplace")?.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            debugPrint("Couldn't create font from filename: \(fontName) with extension \(fontExtension)")
            return
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}
