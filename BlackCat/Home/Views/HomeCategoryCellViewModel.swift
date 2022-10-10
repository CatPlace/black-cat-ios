//
//  HomeCategoryCellViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/05.
//

import Foundation

final class HomeCategoryCellViewModel {
    let category: HomeModel.Category

    init(with model: HomeModel.Category) {
        self.category = model
    }
}
