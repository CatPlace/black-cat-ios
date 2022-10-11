//
//  HomeSection.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/10.
//

import UIKit

import RxDataSources

struct HomeSection {
    var header: Header
    var items: [Item]

    enum Header {
        case empty
        case title(String)
        case image(UIImage)
    }

    enum HomeItem {
        case categoryCell(HomeCategoryCellViewModel)
        case recommendCell(HomeRecommendCellViewModel)
        case emptyCell(HomeModel.Empty)
        case allTattoosCell(HomeTattooAlbumCellViewModel)
    }
}

extension HomeSection: SectionModelType {
    typealias Item = HomeItem

    init(original: HomeSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}
