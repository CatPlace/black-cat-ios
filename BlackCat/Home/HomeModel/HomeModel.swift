//
//  HomeModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/08.
//

import Foundation

// TODO: - SDK로 옮겨야 됨!

enum HomeModel {
    struct Category {
        let title: String

        static let `default`: [Category] = [
            Category(title: "전체보기"),
            Category(title: "레터링"),
            Category(title: "미니 타투"),
            Category(title: "감성 타투"),
            Category(title: "이레즈미"),
            Category(title: "블랙&그레이"),
            Category(title: "라인워크"),
            Category(title: "헤나"),
            Category(title: "커버업"),
            Category(title: "뉴스쿨"),
            Category(title: "올드스쿨"),
            Category(title: "잉크 스플래쉬"),
            Category(title: "치카노"),
            Category(title: "컬러"),
            Category(title: "캐릭터")
        ]
    }

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

