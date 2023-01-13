//
//  HomeCategoryCellViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/05.
//

import Foundation

import BlackCatSDK

final class HomeCategoryCellViewModel {
    let category: Model.Category

    init(with category: Model.Category) {
        self.category = category
    }
}
