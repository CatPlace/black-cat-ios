//
//  MyPageSection.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/11/23.
//

import Foundation
import Differentiator

enum MyPageSectionType: Int {
    case profile
    case recentTattoo
    case menu
}

struct MyPageSection {
    var items: [Item]
}

extension MyPageSection: SectionModelType {
    typealias Item = MyPageItem
    
    init(original: MyPageSection, items: [Item] = []) {
        self.items = items
    }
}

enum MyPageItem {
    case profileSection(MyPageProfileCellViewModel)
    case recentTattooSection(MyPageTattooCellViewModel)
    case menuSection(MyPageMenuCellViewModel)
}
