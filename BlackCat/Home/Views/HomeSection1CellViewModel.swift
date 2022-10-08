//
//  HomeSection1CellViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/08.
//

import Foundation

class HomeSection1CellViewModel {
    let imageURLString: String
    let price: String
    let tattooistName: String

    init(section1: Section1) {
        self.imageURLString = section1.imageURLString
        self.price = section1.priceString
        self.tattooistName = section1.tattooistName
    }
}
