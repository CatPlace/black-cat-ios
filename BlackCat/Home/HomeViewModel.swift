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

    // MARK: - Input

    let viewDidLoad = PublishRelay<Void>()
    let didTapSearchBarButtonItem = PublishRelay<Void>()
    let didTapHeartBarButtonItem = PublishRelay<Void>()
    let didTapCollectionViewItem = PublishRelay<IndexPath>()

    // MARK: - Output

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
                    HomeSection(
                        items: categoryItems.map { .categoryCellItem(HomeCategoryCellViewModel(with: $0)) }
                    ),
                    HomeSection(
                        header: "추천 항목",
                        items: recommendItems.map { .recommendCellItem(HomeRecommendCellViewModel(with: $0)) }
                    ),
                    HomeSection(
                        items: [.empty(Empty())]
                    ),
                    HomeSection(
                        header: "전체 보기",
                        items: allTattoosItems.map { .allTattoosCellItem(HomeAllTattoosCellViewModel(with: $0)) }
                    )
                ]
            }
            .asDriver(onErrorJustReturn: [])
    }
}

struct HomeSection {
    var header: String = ""
    var items: [Item]

    enum HomeItem {
        case categoryCellItem(HomeCategoryCellViewModel)
        case recommendCellItem(HomeRecommendCellViewModel)
        case empty(Empty)
        case allTattoosCellItem(HomeAllTattoosCellViewModel)
    }
}

extension HomeSection: SectionModelType {
    typealias Item = HomeItem

    init(original: HomeSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}

