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
    var items: [Item]
}

enum HomeItem {
    case HomeCategoryCellItem([HomeCategory])
    case Section1([Section1])
    case Empty([Empty])
    case Section2([Section2])
}

class HomeViewModel {
    let categoryItemTitles = Observable<[String]>.of([
        "전체보기", "레터링", "미니 타투", "감성 타투", "이레즈미", "블랙&그레이", "라인워크", "헤나",
        "커버업", "뉴스쿨", "올드스쿨", "잉크 스플래쉬", "치카노", "컬러", "캐릭터"
    ])

    // SubViewModels
//    let homeCategoryCellViewModel = HomeCategoryCellViewModel()

    // View -> ViewModel

    // ViewModel -> View
    let categoryItems: Driver<[String]>

    init() {
        categoryItems = categoryItemTitles
            .asDriver(onErrorJustReturn: [])
    }

}
