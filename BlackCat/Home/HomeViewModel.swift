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
    let price: String
    let producer: String
}

struct Empty { }

struct Section2 {
    let imaeURLString: String
}

struct HomeSection {
    var header: String
    var items: [Item]
}

enum HomeItem {
    case HomeCategoryCellItem(HomeCategory)
    case Section1(Section1)
    case Empty(Empty)
    case Section2(Section2)
}

class HomeViewModel {
    let categoryItemTitles = Observable<[HomeCategory]>.of([
        HomeCategory(title: "전체보기"),
        HomeCategory(title: "레터링"),
        HomeCategory(title: "미니 타투"),
        HomeCategory(title: "감성 타투"),
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

    // SubViewModels
    //    let homeCategoryCellViewModel = HomeCategoryCellViewModel()

    // View -> ViewModel

    // ViewModel -> View
    let categoryItems: Driver<[HomeCategory]>
    let emptyItem = BehaviorSubject<Empty>(value: Empty())

//    let homeItems: Observable<[HomeSection]>
    let homeItems2 = BehaviorSubject<[HomeSection]>(value: [
        HomeSection(header: "", items: [
            .HomeCategoryCellItem(HomeCategory(title: "전체보기")),
            .HomeCategoryCellItem(HomeCategory(title: "레터링")),
            .HomeCategoryCellItem(HomeCategory(title: "미니 타투")),
            .HomeCategoryCellItem(HomeCategory(title: "감성 타투")),
            .HomeCategoryCellItem(HomeCategory(title: "이레즈미")),
            .HomeCategoryCellItem(HomeCategory(title: "블랙&그레이")),
            .HomeCategoryCellItem(HomeCategory(title: "라인워크")),
            .HomeCategoryCellItem(HomeCategory(title: "헤나")),
            .HomeCategoryCellItem(HomeCategory(title: "커버업")),
            .HomeCategoryCellItem(HomeCategory(title: "뉴스쿨")),
            .HomeCategoryCellItem(HomeCategory(title: "올드스쿨")),
            .HomeCategoryCellItem(HomeCategory(title: "잉크 스플래쉬")),
            .HomeCategoryCellItem(HomeCategory(title: "치카노")),
            .HomeCategoryCellItem(HomeCategory(title: "컬러")),
            .HomeCategoryCellItem(HomeCategory(title: "캐릭터"))
        ]),
        HomeSection(header: "항목 1", items: [
            .Section1(Section1(imageURLString: "", price: "10000", producer: "김타투")),
            .Section1(Section1(imageURLString: "", price: "20000", producer: "김타투")),
            .Section1(Section1(imageURLString: "", price: "30000", producer: "김타투")),
            .Section1(Section1(imageURLString: "", price: "40000", producer: "김타투"))
        ]),
        HomeSection(header: "", items: [
            .Empty(Empty())
        ]),
        HomeSection(header: "항목 2", items: [
            .Section2(Section2(imaeURLString: "")),
            .Section2(Section2(imaeURLString: "")),
            .Section2(Section2(imaeURLString: "")),
            .Section2(Section2(imaeURLString: "")),
            .Section2(Section2(imaeURLString: "")),
            .Section2(Section2(imaeURLString: "")),
            .Section2(Section2(imaeURLString: "")),
            .Section2(Section2(imaeURLString: ""))
        ])
    ])

    init() {
        categoryItems = categoryItemTitles
            .asDriver(onErrorJustReturn: [])

//        homeItems = categoryItemTitles.map({ categories -> [HomeSection] in
//            [
//                HomeSection(items: [
//                    .HomeCategoryCellItem(categories)
//                ]),
//                HomeSection(items: [
//                    .Section1([
//                        Section1(imageURLString: "", price: "10000", producer: "김타투"),
//                        Section1(imageURLString: "", price: "20000", producer: "김타투"),
//                        Section1(imageURLString: "", price: "30000", producer: "김타투"),
//                        Section1(imageURLString: "", price: "40000", producer: "김타투")
//                    ])
//                ]),
//                HomeSection(items: [
//                    .Empty([Empty()])
//                ]),
//                HomeSection(items: [
//                    .Section2([
//                        Section2(imaeURLString: ""),
//                        Section2(imaeURLString: ""),
//                        Section2(imaeURLString: ""),
//                        Section2(imaeURLString: ""),
//                        Section2(imaeURLString: ""),
//                        Section2(imaeURLString: ""),
//                        Section2(imaeURLString: ""),
//                        Section2(imaeURLString: "")
//                    ])
//                ])
//            ]
//        })
    }

}
