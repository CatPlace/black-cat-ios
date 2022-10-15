//
//  HomeViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/10/05.
//

import Foundation

import BlackCatSDK
import RxCocoa
import RxDataSources
import RxSwift

class HomeViewModel {
    private let categoryItemTitles = Observable<[HomeModel.Category]>.just(HomeModel.Category.default)

    // MARK: - Input

    let viewDidLoad = PublishRelay<Void>()
    let didTapSearchBarButtonItem = PublishRelay<Void>()
    let didTapHeartBarButtonItem = PublishRelay<Void>()
    let didTapCollectionViewItem = PublishRelay<IndexPath>()
    let nextFetchPage = PublishSubject<Int>()

    // MARK: - Output

    let homeItems: Driver<[HomeSection]>

    init() {
        let fetchedRecommendItems = viewDidLoad
            .map { _ in Array(repeating: HomeModel.Recommend(imageURLString: "",
                                                             priceString: "15,500원",
                                                             tattooistName: "김타투"), count: 7) }

        let fetchedTattooAlbumItems = nextFetchPage
            .distinct()
            .flatMap { nextFetchPage in fetchTattoAlbumItems(at: nextFetchPage) }
            .scan([HomeModel.TattooAlbum]()) { previousItems, nextFetchPageItems in
                previousItems + nextFetchPageItems
            }

        homeItems = Observable
            .combineLatest(
                categoryItemTitles, fetchedRecommendItems, fetchedTattooAlbumItems
            ) { categoryItems, recommendItems, tattooAlbumItems -> [HomeSection] in
                [HomeSection(header: .empty,
                             items: categoryItems.map { .categoryCell(HomeCategoryCellViewModel(with: $0)) }),
                 HomeSection(header: .title("추천 항목"),
                             items: recommendItems.map { .recommendCell(HomeRecommendCellViewModel(with: $0)) }),
                 HomeSection(header: .empty,
                             items: [.emptyCell(HomeModel.Empty())]),
                 HomeSection(header: .title("전체 보기"),
                             items: tattooAlbumItems.map { .allTattoosCell(HomeTattooAlbumCellViewModel(with: $0)) })]
            }
            .asDriver(onErrorJustReturn: [])

        // Dummy Function입니다.
        // API가 나오는대로 SDK에서 처리할 함수입니다.
        func fetchTattoAlbumItems(at page: Int) -> Observable<[HomeModel.TattooAlbum]> {
            return .just(Array(repeating: HomeModel.TattooAlbum(imageURLString: ""), count: 15))
        }
    }
}

extension Observable where Element: Hashable {
    /// 이전에 발생한 이벤트가 새로 발생할 경우 해당 이벤트는 무시합니다
    func distinct() -> Observable<Element> {
        var cache = Set<Element>()
        return flatMap { element -> Observable<Element> in
            if cache.contains(element) {
                return Observable<Element>.empty()
            } else {
                cache.insert(element)
                return Observable<Element>.just(element)
            }
        }
    }
}
