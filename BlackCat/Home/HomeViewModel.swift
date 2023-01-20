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
    typealias Genre = Model.Category

    private let disposeBag = DisposeBag()

    // MARK: - Input

    let viewDidLoad = PublishRelay<Void>()
    let didTapSearchBarButtonItem = PublishRelay<Void>()
    let didTapHeartBarButtonItem = PublishRelay<Void>()
    let didTapCollectionViewItem = PublishRelay<IndexPath>()
    let nextFetchPage = PublishSubject<Int>()

    // MARK: - Output

    let homeItems: Driver<[HomeSection]>
    let pushToBookmarkViewController: Driver<Void>
    let pushToGenreViewController: Driver<Genre>

    init() {
        let fetchedRecommendItems = viewDidLoad
            .map { _ in Array(repeating: Model.Tattoo(id: 1, ownerName: "김타투", price: 0, description: "제목", liked: false, imageURLStrings: [], address: "주소"), count: 5) }
            
        let startFetchItems = viewDidLoad.share()
        let didTapGenreItem = PublishRelay<Int>()
        let didTapRecommendItem = PublishRelay<Int>()
        let didTapTattooAlbumItem = PublishRelay<Int>()

        let fetchedGenreList = startFetchItems
            .flatMap { _ in CatSDKNetworkCategory.rx.fetchCategories() }

        let fetchedTattooAlbumItems = nextFetchPage
            .distinct()
            .flatMap { nextFetchPage in fetchTattoAlbumItems(at: nextFetchPage) }
            .scan([HomeModel.TattooAlbum]()) { previousItems, nextFetchPageItems in
                previousItems + nextFetchPageItems
            }

        homeItems = Observable
            .combineLatest(
                fetchedGenreList, fetchedRecommendItems, fetchedTattooAlbumItems
            ) { genreItems, recommendItems, tattooAlbumItems -> [HomeSection] in
                [HomeSection(header: .empty,
                             items: genreItems.map { .genreCell(HomeGenreCellViewModel(with: $0)) }),
                 HomeSection(header: .title("추천 타투"),
                             items: recommendItems.map { .recommendCell(CommonTattooInfoCellViewModel(tattoo: $0)) }),
                 HomeSection(header: .empty,
                             items: [.emptyCell(HomeModel.Empty())]),
                 HomeSection(header: .title("실시간 인기 타투"),
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
            .withLatestFrom(fetchedGenreList) { index, list in
                list[index]
            }
            .asDriver(onErrorJustReturn: Model.Category(id: 0, name: "", count: 0))
    }
}

