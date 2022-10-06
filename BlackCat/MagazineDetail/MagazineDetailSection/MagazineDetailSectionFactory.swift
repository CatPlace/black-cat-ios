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
    
    
    // ✅ NOTE: - 서버 연결이 끝난 후에 리팩토링할 부분의 코드 흔적을 미리 남겨둡니다.
    func confugurationSections() -> [MagazineDetailCellSection] {
        return []
    }
}
