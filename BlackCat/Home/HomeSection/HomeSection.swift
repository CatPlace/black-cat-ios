//
//  HomeSection.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/10.
//

import Foundation

import RxDataSources

struct HomeSection {
    var header: String = ""
    var items: [Item]

    enum HomeItem {
        case categoryCell(HomeCategoryCellViewModel)
        case recommendCell(HomeRecommendCellViewModel)
        case emptyCell(HomeModel.Empty)
        case allTattoosCell(HomeAllTattoosCellViewModel)
    }
}

extension HomeSection: SectionModelType {
    typealias Item = HomeItem

    init(original: HomeSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}
