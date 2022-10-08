//
//  MagazineDetailSection.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import Foundation
import RxDataSources
import Differentiator

// MARK: - 섹션마다 들어갈 수 있는 셀들을 모아서 정의합니다.
enum MagazineDetailSectionItem: Equatable, IdentifiableType {
    var identity: some Hashable { UUID().uuidString }
    
    case textCell(MagazineDetailTextCellReactor)
    
    static func == (lhs: MagazineDetailSectionItem, rhs: MagazineDetailSectionItem) -> Bool {
        lhs.identity == rhs.identity
    }
}


// MARK: - 섹션들을 정의합니다.
enum MagazineDetailCellSection {
    case textCell([MagazineDetailSectionItem])
}

extension MagazineDetailCellSection: AnimatableSectionModelType {
    var identity: String { UUID().uuidString }
    
    typealias Item = MagazineDetailSectionItem
    
    var items: [Item] {
        switch self {
        case .textCell(let items):
            return items
        }
    }
    
    init(original: MagazineDetailCellSection, items: [MagazineDetailSectionItem]) {
        switch original {
        case .textCell:
            self = .textCell(items)
        }
    }
}