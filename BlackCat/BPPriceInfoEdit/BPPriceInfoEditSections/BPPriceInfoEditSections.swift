//
//  BPPriceInfoEditSection.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/07.
//

import Foundation
import RxDataSources

// 🐻‍❄️ MARK: - 여기서는 애니메이션이 적용되면 오히려 사용자가 이상하게 느끼니까 없애기
// 마치 UITextView를 사용하고 있는 것처럼 느껴야 해. 물론! 셀을 활용해서.
enum BPPriceInfoEditSectionItem {
    case textCell(BPPriceInfoEditTextCellReactor)
    case imageCell(BPPriceInfoEditImageCellReactor)
}


// MARK: - 섹션들을 정의합니다.
enum  BPPriceInfoEditCellSection {
    case textCell([BPPriceInfoEditSectionItem])
    case imageCell([BPPriceInfoEditSectionItem])
}

extension BPPriceInfoEditCellSection: SectionModelType {    
    typealias Item = BPPriceInfoEditSectionItem
    
    var items: [Item] {
        switch self {
        case .textCell(let items): return items
        case .imageCell(let items): return items
        }
    }
    
    init(original: BPPriceInfoEditCellSection, items: [BPPriceInfoEditSectionItem]) {
        switch original {
        case .textCell: self = .textCell(items)
        case .imageCell: self = .imageCell(items)
        }
    }
}
