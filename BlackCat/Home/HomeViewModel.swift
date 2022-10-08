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

    // MARK: - Properties

    private let categoryItemTitles = Observable<[HomeCategory]>.just(HomeCategory.default)

    // View -> ViewModel

    let viewDidLoad = PublishRelay<Void>()

    // ViewModel -> View

    let homeItems: Driver<[HomeSection]>

    init() {
        let startFetchItems = viewDidLoad.share()

        let fetchedSection1Items = startFetchItems
            .map { () -> [Section1] in
                [
                    Section1(imageURLString: "", priceString: "", tattooistName: "")
                ]
            }

        let fetchedSection2Items = startFetchItems
            .map { () -> [Section2] in
                [
                    Section2(imageURLString: "")
                ]
            }

        homeItems = Observable
            .combineLatest(
                categoryItemTitles, fetchedSection1Items, fetchedSection2Items
            ) { categoryItems, section1Items, section2Items -> [HomeSection] in
                [
                    HomeSection(items: categoryItems.map { .HomeCategoryCellItem($0) }),
                    HomeSection(header: "항목 1", items: section1Items.map { .Section1($0) }),
                    HomeSection(items: [.Empty(Empty())]),
                    HomeSection(header: "항목 2", items: section2Items.map { .Section2($0) })
                ]
            }.asDriver(onErrorJustReturn: [])
    }

}
