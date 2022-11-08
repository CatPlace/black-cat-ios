//
//  MagazineDetailModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import UIKit

// 🐻‍❄️ NOTE: - 이거 DTO가 아니라 Model임!! 명심할 것
class MagazineDetailModel {
    
    /** 매거진 cellTyep (dafault = emptyCell) */ var cellType: MagazineDetailCellType?
    
    /** 매거진 텍스트 (dafault = nil) */ var text: String?
    /** 매거진 fontSzie  (dafault = 12) */ var fontSize: Int
    /** 매거진 textColor  (dafault = black) */ var textColor: TextColor
    /** 매거진 textAlignment  (dafault = left) */ var textAlignment: TextAlignmentType
    /** 매거진 fontWeight  (dafault = regular) */ var fontWeight: FontWeightType
    
    /** 매거진 imageUrlString  (dafault = nil) */ var imageUrlString: String?
    /** 매거진 imageCornerRadius  (dafault = 0)*/ var imageCornerRadius: Int
    
    /** 매거진 cell에 사용되는 layoutHeight  (dafault = 10)*/ var layoutHeight: Int
    /** 매거진 cell에 사용되는 layoutWidth  (dafault = 10)*/ var layoutWidth: Int
    /** 매거진 cell에 사용되는 layoutLeadingInset  (dafault = 20)*/ var layoutLeadingInset: Int
    /** 매거진 cell에 사용되는 layoutTrailingInset  (dafault = 20)*/ var layoutTrailingInset: Int
    /** 매거진 cell에 사용되는 layoutTopInset  (dafault = 20)*/ var layoutTopInset: Int
    /** 매거진 cell에 사용되는 layoutBottomInset  (dafault = 20)*/ var layoutBottomInset: Int
    
    
    init(
        cellType: MagazineDetailCellType = .emptyCell,
        text: String? = nil,
        fontSize: Int = 12,
        textColor: TextColor = .black,
        textAlignment: TextAlignmentType = .left,
        fontWeight: FontWeightType = .regular,
        imageUrlString: String? = nil,
        imageCornerRadius: Int = 0,
        layoutHeight: Int = 10,
        layoutWidth: Int = 10,
        layoutLeadingInset: Int = 20,
        layoutTrailingInset: Int = 20,
        layoutTopInset: Int = 20,
        layoutBottomInset: Int = 20
    ) {
        self.cellType = cellType
        self.text = text
        self.fontSize = fontSize
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.fontWeight = fontWeight
        self.imageUrlString = imageUrlString
        self.imageCornerRadius = imageCornerRadius
        self.layoutHeight = layoutHeight
        self.layoutWidth = layoutWidth
        self.layoutLeadingInset = layoutLeadingInset
        self.layoutTrailingInset = layoutTrailingInset
        self.layoutTopInset = layoutTopInset
        self.layoutBottomInset = layoutBottomInset
    }
    
    enum MagazineDetailCellType {
        case textCell
        case imageCell
        case bulletedCell
        case emptyCell
        case storyShareCell
    }
    
    enum TextColor: String {
        case black = "#FFFFFF"
        case white = "#111111"
        case gray = "#D9D9D9"
        
        func toUIColor() -> UIColor {
            switch self {
            case .black: return UIColor(hex: self.rawValue) ?? UIColor.black
            case .white: return UIColor(hex: self.rawValue) ?? UIColor.white
            case .gray: return UIColor(hex: self.rawValue) ?? UIColor.gray
            }
        }
    }
    
    enum TextAlignmentType {
        case left
        case center
        case right
        case justified
        case natural
        
        func toNSTextAlignment() -> NSTextAlignment {
            switch self {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            case .justified: return .justified
            case .natural: return .natural
            }
        }
    }
    
    enum FontWeightType {
        case bold
        case black
        case medium
        case heavy
        case light
        case regular
        case semibold
        case thin
        case ultraLight
        
        func toFontWeight() -> UIFont.Weight {
            switch self {
            case .bold: return .bold
            case .black: return .black
            case .medium: return .medium
            case .heavy: return .heavy
            case .light: return .light
            case .regular: return .regular
            case .semibold: return .semibold
            case .thin: return .thin
            case .ultraLight: return .ultraLight
            }
        }
    }
}
