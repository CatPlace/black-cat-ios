//
//  BPPriceInfoEditSectionsFactory.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/07.
//

import Foundation

struct BPPriceInfoEditSectionsFactory {
    
    /// textCell을 만드는 factory
    static func makeTextCell(_ item: BPPriceInfoEditModel) -> BPPriceInfoEditSectionItem {
        
        return BPPriceInfoEditSectionItem.textCell(
            BPPriceInfoEditTextCellReactor(
                initialState: item
            )
        )
    }
    
//    /// imageCell을 만드는 factory
//    static func makeImageCell(_ item: BPPriceInfoEditModel) -> MagazineDetailSectionItem {
//
//        return MagazineDetailSectionItem.imageCell(
//            MagazineDetailImageCellReactor(
//                initialState: item
//            )
//        )
//    }
//
}
