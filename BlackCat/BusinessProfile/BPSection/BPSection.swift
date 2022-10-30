//
//  BPSection.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/30.
//

import Foundation
import RxDataSources
import Differentiator


enum BusinessProfileItem: Equatable, IdentifiableType {
    var identity: some Hashable { UUID().uuidString }
    
    case thumbnailImageItem(BPThumnailImageCellReactor)
    case contentItem(BPContentCellReactor)
    
    static func == (lhs: BusinessProfileItem, rhs: BusinessProfileItem) -> Bool {
        lhs.identity == rhs.identity
    }
}

enum BusinessProfileCellSection {
    case thumbnailImageCell([BusinessProfileItem])
    case contentCell([BusinessProfileItem])
}

extension BusinessProfileCellSection: AnimatableSectionModelType {
    var identity: String { UUID().uuidString }
    
    typealias Item = BusinessProfileItem
    
    var items: [Item] {
        switch self {
        case .thumbnailImageCell(let items): return items
        case .contentCell(let items): return items
        }
    }
    
    init(original: BusinessProfileCellSection, items: [BusinessProfileItem]) {
        switch original {
        case .thumbnailImageCell: self = .thumbnailImageCell(items)
        case .contentCell: self = .contentCell(items)
        }
    }
}

// cell and reactor
final class BPThumbnailImageCell: BaseCollectionViewCell {
    
}

final class BPThumnailImageCellReactor {
    
}

final class BPContentCell: BaseCollectionViewCell {
    
}

final class BPContentCellReactor {
    
}

