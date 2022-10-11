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

    // MARK: - Output

    let homeItems: Driver<[HomeSection]>

    init() {
        let startFetchItems = viewDidLoad.share()

        let fetchedRecommendItems = startFetchItems
            .map { () -> [HomeModel.Recommend] in
                // Dummy 모델
                [HomeModel.Recommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                 HomeModel.Recommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                 HomeModel.Recommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                 HomeModel.Recommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투"),
                 HomeModel.Recommend(imageURLString: "", priceString: "15,900원", tattooistName: "김타투")]
            }

        let fetchedTattooAlbumItems = startFetchItems
            .map { () -> [HomeModel.TattooAlbum] in
                // Dummy 모델
                [HomeModel.TattooAlbum(imageURLString: ""),
                 HomeModel.TattooAlbum(imageURLString: ""),
                 HomeModel.TattooAlbum(imageURLString: ""),
                 HomeModel.TattooAlbum(imageURLString: ""),
                 HomeModel.TattooAlbum(imageURLString: ""),
                 HomeModel.TattooAlbum(imageURLString: ""),
                 HomeModel.TattooAlbum(imageURLString: ""),
                 HomeModel.TattooAlbum(imageURLString: "")]
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
    }
}
