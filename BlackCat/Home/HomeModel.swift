//
//  HomeModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/09.
//

import Foundation

// TODO: - SDK로 옮겨야 됨!

struct HomeCategory {
    let title: String

    static let `default`: [HomeCategory] = [
        HomeCategory(title: "전체보기"),
        HomeCategory(title: "레터링"),
        HomeCategory(title: "미니 타투"),
        HomeCategory(title: "감성 타투"),
        HomeCategory(title: "이레즈미"),
        HomeCategory(title: "블랙&그레이"),
        HomeCategory(title: "라인워크"),
        HomeCategory(title: "헤나"),
        HomeCategory(title: "커버업"),
        HomeCategory(title: "뉴스쿨"),
        HomeCategory(title: "올드스쿨"),
        HomeCategory(title: "잉크 스플래쉬"),
        HomeCategory(title: "치카노"),
        HomeCategory(title: "컬러"),
        HomeCategory(title: "캐릭터")
    ]
}

struct Section1 {
    let imageURLString: String
    let priceString: String
    let tattooistName: String
}

struct Empty {}

struct Section2 {
    let imageURLString: String
}

