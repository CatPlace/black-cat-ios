//
//  MagazineModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/10/10.
//

import Foundation
import Differentiator

struct Magazine {
    let id: Int
    let imageUrlString: String
    let title: String
    let writer: String
    let dateString: String
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
