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
    typealias GenreTitle = String

    private let disposeBag = DisposeBag()
    private let categoryItemTitles = Observable<[HomeModel.Category]>.just(HomeModel.Category.default)

    // MARK: - Input

    let viewDidLoad = PublishRelay<Void>()
    let didTapSearchBarButtonItem = PublishRelay<Void>()
    let didTapHeartBarButtonItem = PublishRelay<Void>()
    let didTapCollectionViewItem = PublishRelay<IndexPath>()
    let nextFetchPage = PublishSubject<Int>()

    // MARK: - Output

    let homeItems: Driver<[HomeSection]>
    let pushToBookmarkViewController: Driver<Void>
    let pushToGenreViewController: Driver<GenreTitle>

    init() {
        let fetchedRecommendItems = viewDidLoad
            .map { _ in Array(repeating: HomeModel.Recommend(imageURLString: "",
                                                             priceString: "15,500원",
                                                             tattooistName: "김타투"), count: 7) }
        let startFetchItems = viewDidLoad.share()
        let didTapGenreItem = PublishRelay<Int>()
        let didTapRecommendItem = PublishRelay<Int>()
        let didTapTattooAlbumItem = PublishRelay<Int>()

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

        pushToBookmarkViewController = didTapHeartBarButtonItem
            .asDriver(onErrorJustReturn: ())

        // Dummy Function입니다.
        // API가 나오는대로 SDK에서 처리할 함수입니다.
        func fetchTattoAlbumItems(at page: Int) -> Observable<[HomeModel.TattooAlbum]> {
            return .just(Array(repeating: HomeModel.TattooAlbum(imageURLString: ""), count: 15))
        }
        didTapCollectionViewItem
            .bind { indexPath in
                switch indexPath.section {
                case 0: didTapGenreItem.accept(indexPath.row)
                case 1: didTapRecommendItem.accept(indexPath.row)
                case 3: didTapTattooAlbumItem.accept(indexPath.row)
                default: return
                }
            }
            .disposed(by: disposeBag)

        pushToGenreViewController = didTapGenreItem
            .withLatestFrom(categoryItemTitles) { index, titles in
                titles[index].title
            }
            .asDriver(onErrorJustReturn: "")
    }
}

