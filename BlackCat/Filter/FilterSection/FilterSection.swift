//
//  FilterSection.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/15.
//

import UIKit
import Differentiator

enum FilterSectionItem: Equatable {
    case titleCell
    case lineCell
    case contentCell
}

enum FilterCellSection {
    case titleCell
    case lineCell
    case contentCell
}

extension FilterCellSection: SectionModelType {
    typealias Item = FilterSectionItem
    
    var items: [Item] {
        switch self {
        case .titleCell: return []
        case .lineCell: return []
        case .contentCell: return []
        }
    }

    init(original: FilterCellSection, items: [FilterSectionItem]) {
        switch original {
        case .titleCell: self = .titleCell
        case .lineCell: self = .lineCell
        case .contentCell: self = .contentCell
        }
    }
}
