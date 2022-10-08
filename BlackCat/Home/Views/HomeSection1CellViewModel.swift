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
    let producerName: String

    init(section1: Section1) {
        self.imageURLString = section1.imageURLString
        self.price = section1.priceString
        self.producerName = section1.producerName
    }
}
