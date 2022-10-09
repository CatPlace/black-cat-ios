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
            .map { () -> [HomeRecommend] in
                // Dummy 모델
                [
                    HomeRecommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                    HomeRecommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                    HomeRecommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                    HomeRecommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                    HomeRecommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투")
                ]
            }

        let fetchedSection2Items = startFetchItems
            .map { () -> [HomeAllTattoos] in
                // Dummy 모델
                [
                    HomeAllTattoos(imageURLString: ""),
                    HomeAllTattoos(imageURLString: ""),
                    HomeAllTattoos(imageURLString: ""),
                    HomeAllTattoos(imageURLString: ""),
                    HomeAllTattoos(imageURLString: ""),
                    HomeAllTattoos(imageURLString: ""),
                    HomeAllTattoos(imageURLString: ""),
                    HomeAllTattoos(imageURLString: "")
                ]
            }

        homeItems = Observable
            .combineLatest(
                categoryItemTitles, fetchedSection1Items, fetchedSection2Items
            ) { categoryItems, recommendItems, allTattoosItems -> [HomeSection] in
                [
                    HomeSection(items: categoryItems.map { .homeCategoryCellItem($0) }),
                    HomeSection(header: "항목 1", items: recommendItems.map { .recommendCellItem($0) }),
                    HomeSection(items: [.empty(Empty())]),
                    HomeSection(header: "항목 2", items: allTattoosItems.map { .allTattoosCellItem($0) })
                ]
            }
            .asDriver(onErrorJustReturn: [])
    }
}

struct HomeSection {
    var header: String = ""
    var items: [Item]

    enum HomeItem {
        case homeCategoryCellItem(HomeCategory)
        case recommendCellItem(HomeRecommend)
        case empty(Empty)
        case allTattoosCellItem(HomeAllTattoos)
    }
}

extension HomeSection: SectionModelType {
    typealias Item = HomeItem

    init(original: HomeSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}

