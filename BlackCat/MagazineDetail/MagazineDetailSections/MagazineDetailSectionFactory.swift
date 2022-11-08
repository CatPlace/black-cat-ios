//
//  MagazineDetailSectionFactory.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/06.
//

import Foundation

struct MagazineDetailSectionFactory {
    
    /// textCell을 만드는 factory
    static func makeTextCell(_ item: MagazineDetailModel) -> MagazineDetailSectionItem {
        
        return MagazineDetailSectionItem.textCell(
            MagazineDetailTextCellReactor(
                initialState: item
            )
        )
    }
    
    /// imageCell을 만드는 factory
    static func makeImageCell(_ item: MagazineDetailModel) -> MagazineDetailSectionItem {
        
        return MagazineDetailSectionItem.imageCell(
            MagazineDetailImageCellReactor(
                initialState: item
            )
        )
    }
    
    /// imageCell을 만드는 factory
    static func makeBulletedCell(_ item: MagazineDetailModel) -> MagazineDetailSectionItem {
        
        return MagazineDetailSectionItem.bulletedCell(
            MagazineDetailBulletedCellReactor(
                initialState: item
            )
        )
    }
    
    /// textCell을 만드는 factory
    static func makeEmptyCell(_ item: MagazineDetailModel) -> MagazineDetailSectionItem {
        
        return MagazineDetailSectionItem.emptyCell(
            MagazineDetailEmptyCellReactor(
                initialState: item
            )
        )
    }
    
    /// textCell을 만드는 factory
    static func makeStoryShareCell(_ item: MagazineDetailModel) -> MagazineDetailSectionItem {
        
        return MagazineDetailSectionItem.storyShareButtonCell(
            MagazineDetailStroyShareButtonCellReactor(initialState: MagazineDetailStroyShareButtonCellReactor.State())
        )
    }
    
    // 🐻‍❄️ NOTE: - 서버 연결이 끝난 후에 리팩토링할 부분의 코드 흔적을 미리 남겨둡니다.
    func confugurationSections() -> [MagazineDetailCellSection] {
        return []
    }
}
