//
//  BPSectionFactory.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/31.
//

import Foundation

struct BPSectionFactory {
    
    static func makeThumbnailCell() -> BusinessProfileItem {
        let item = BPThumbnailModel(urlString: String.createRandomString(length: 5))
        
        return BusinessProfileItem.thumbnailImageItem(
            BPThumbnailImageCellReactor(initialState: item)
        )
    }
    
    static func makeContentCell(order: Int) -> BusinessProfileItem {
        let item = BPContentModel(order: order)
        
        return BusinessProfileItem.contentItem(
            BPContentCellReactor(initialState: .init(contentModel: item))
        )
    }
}

