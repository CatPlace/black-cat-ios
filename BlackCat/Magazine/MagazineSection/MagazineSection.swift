//
//  MagazineSection.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/12.
//

import Foundation
import Differentiator

enum MagazineSectionType: Int {
    case recentMagazine
    case lastMagazine
}

struct MagazineSection {
    var items: [Item]
}

extension MagazineSection: SectionModelType {
    typealias Item = MagazineItem
    
    init(original: MagazineSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}

enum MagazineItem {
    case topSection(RecentMagazineCellViewModel)
    case lastStorySection(LastMagazineCellViewModel)
}
