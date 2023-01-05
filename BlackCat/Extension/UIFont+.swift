//
//  UIFont+.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/04.
//

import UIKit

extension UIFont {
    enum FontType {
        enum Pretentdard: String {
            case bold = "Pretendard-Bold"
            case extraBold = "Pretendard-ExtraBold"
            case extraLight = "Pretendard-ExtraLight"
            case light = "Pretendard-Light"
            case medium = "Pretendard-Medium"
            case regular = "Pretendard-Regular"
            case semiBold = "Pretendard-SemiBold"
            case thin = "Pretendard-Thin"
        }
        
        enum HeirOfLight: String {
            case bold = "HeirofLightOTFBold"
            case regular = "HeirofLightOTFRegular"
        }
        
        enum Didot: String {
            case bold = "Didot Bold"
            case italic = "Didot Italic"
            case regular = "Didot"
            case title = "Didot Title"
        }
        
        enum AppleSDGothic: String {
            case regular = "Regular"
            case bold = "Bold"
            case medium = "Medium"
            func fontName() -> String {
                "AppleSDGothicNeo-\(self.rawValue)"
            }
        }
    }
    
    static func pretendardFont(size: CGFloat = 15, style: FontType.Pretentdard = .regular) -> UIFont {
        if let font = UIFont(name: style.rawValue, size: size) {
            return font
        } else {
            print("pretendard 폰트 유실 에러", style)
            return systemFont(ofSize: size)
        }
    }
    
    static func heirOfLightFont(size: CGFloat = 15, style: FontType.HeirOfLight = .regular) -> UIFont {
        if let font = UIFont(name: style.rawValue, size: size) {
            return font
        } else {
            print("heirOfLightFont 폰트 유실 에러", style)
            return systemFont(ofSize: size)
        }
    }
    
    static func didotFont(size: CGFloat = 15, style: FontType.Didot = .regular) -> UIFont {
        if let font = UIFont(name: style.rawValue, size: size) {
            return font
        } else {
            print("didotFont 폰트 유실 에러", style)
            return systemFont(ofSize: size)
        }
    }
    
    static func appleSDGoithcFont(size: CGFloat = 15, style: FontType.AppleSDGothic = .regular) -> UIFont {
        if let font = UIFont(name: style.fontName(), size: size) {
            return font
        } else {
            print("apple 폰트 유실 에러", style)
            return systemFont(ofSize: size)
        }
    }
}
