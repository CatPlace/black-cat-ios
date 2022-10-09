//
//  HomeViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/09.
//

import Foundation

import RxCocoa
import RxDataSources
import RxSwift

class HomeViewModel {
    private let categoryItemTitles = Observable<[HomeCategory]>.just(HomeCategory.default)

    // MARK: - View -> ViewModel

    let viewDidLoad = PublishRelay<Void>()
    let didTapSearchBarButtonItem = PublishRelay<Void>()
    let didTapHeartBarButtonItem = PublishRelay<Void>()
    let didTapCollectionViewItem = PublishRelay<IndexPath>()

    // MARK: - ViewModel -> View

    let homeItems: Driver<[HomeSection]>

    init() {
        let startFetchItems = viewDidLoad.share()

        let fetchedSection1Items = startFetchItems
            .map { () -> [Section1] in
                // Dummy 모델
                [
                    Section1(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                    Section1(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                    Section1(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                    Section1(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                    Section1(imageURLString: "", priceString: "15,900원", tattooistName: "김타투")
                ]
            }

        let fetchedSection2Items = startFetchItems
            .map { () -> [Section2] in
                // Dummy 모델
                [
                    Section2(imageURLString: ""),
                    Section2(imageURLString: ""),
                    Section2(imageURLString: ""),
                    Section2(imageURLString: ""),
                    Section2(imageURLString: ""),
                    Section2(imageURLString: ""),
                    Section2(imageURLString: ""),
                    Section2(imageURLString: "")
                ]
            }

        homeItems = Observable
            .combineLatest(
                categoryItemTitles, fetchedSection1Items, fetchedSection2Items
            ) { categoryItems, recommendItems, allTattoosItems -> [HomeSection] in
                [
                    HomeSection(items: categoryItems.map { .HomeCategoryCellItem($0) }),
                    HomeSection(header: "항목 1", items: recommendItems.map { .Section1($0) }),
                    HomeSection(items: [.Empty(Empty())]),
                    HomeSection(header: "항목 2", items: allTattoosItems.map { .Section2($0) })
                ]
            }
            .do(onNext: { print($0) })
            .asDriver(onErrorJustReturn: [])
    }
}

struct HomeSection {
    var header: String = ""
    var items: [Item]

    enum HomeItem {
        case HomeCategoryCellItem(HomeCategory)
        case Section1(Section1)
        case Empty(Empty)
        case Section2(Section2)
    }
}

extension HomeSection: SectionModelType {
    typealias Item = HomeItem

    init(original: HomeSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}

