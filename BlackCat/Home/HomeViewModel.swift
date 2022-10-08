//
//  HomeViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/05.
//

import Foundation

import RxCocoa
import RxDataSources
import RxSwift

struct HomeCategory {
    let title: String
}

struct Section1 {
    let imageURLString: String
    let priceString: String
    let producerName: String
}

struct Empty { }

struct Section2 {
    let imageURLString: String
}

struct HomeSection {
    var header: String = ""
    var items: [Item]
}

enum HomeItem {
    case HomeCategoryCellItem(HomeCategory)
    case Section1(Section1)
    case Empty(Empty)
    case Section2(Section2)
}

class HomeViewModel {
    private let categoryItemTitles = Observable<[HomeCategory]>.just([
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
    ])
    private let emptyCell = Observable<[Empty]>.just([Empty()])

    // View -> ViewModel

    // ViewModel -> View
    let categoryItems: Driver<[HomeCategory]>
    let emptyItem = BehaviorSubject<Empty>(value: Empty())
    let homeItems: Driver<[HomeSection]>

    init() {
        categoryItems = categoryItemTitles
            .asDriver(onErrorJustReturn: [])

        homeItems = categoryItemTitles.map{ categories -> [HomeSection] in
            [
                HomeSection(header: "", items: categories.map { .HomeCategoryCellItem($0) }),
                HomeSection(header: "항목 1", items: [
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: "")),
                    .Section1(Section1(imageURLString: "", priceString: "", producerName: ""))
                ]),
                HomeSection(header: "", items: [.Empty(Empty())]),
                HomeSection(header: "항목 2", items: [
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: "")),
                    .Section2(Section2(imageURLString: ""))
                ])
            ]
        }
        .asDriver(onErrorJustReturn: [])
    }

}
