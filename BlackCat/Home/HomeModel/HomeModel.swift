//
//  HomeModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/08.
//

import Foundation

// TODO: - SDK로 옮겨야 됨!

struct HomeModel {
    struct Recommend {
        let imageURLString: String
        let priceString: String
        let tattooistName: String
    }

    struct Empty {}

    struct TattooAlbum {
        let imageURLString: String
    }
}
