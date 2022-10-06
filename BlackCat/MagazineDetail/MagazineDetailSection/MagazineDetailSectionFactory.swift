//
//  MagazineDetailSectionFactory.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import Foundation

struct MagazineDetailSectionFactory {
    
    static func makeTextCell(_ item: MagazineDetailModel) -> MagazineDetailSectionItem {
        
        return MagazineDetailSectionItem.textCell(
            MagazineDetailTextCellReactor(
                initialState: item
            )
        )
    }
}
