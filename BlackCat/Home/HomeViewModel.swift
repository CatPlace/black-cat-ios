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
    private let disposeBag = DisposeBag()

    // MARK: - Input
    let viewDidLoad = PublishRelay<Void>()
    let viewWillAppear = PublishRelay<Void>()
    let didTapSearchBarButtonItem = PublishRelay<Void>()
    let didTapHeartBarButtonItem = PublishRelay<Void>()
    let didTapCollectionViewItem = PublishRelay<IndexPath>()
    let nextFetchPage = BehaviorRelay<Int>(value: 0)
    let refreshTrigger = PublishRelay<Void>()
    
    // MARK: - Output
    let homeItems: Driver<[HomeSection]>
    let pushToBookmarkViewController: Driver<Void>
    let pushToGenreViewController: Driver<GenreType>
    let pushToTattooDetailViewController: Driver<Int>
    let refreshEndDriver: Driver<Void>
    
    init() {
        let fetchedRecommendItems = viewWillAppear
            .flatMap { _ in CatSDKTattoo.recommendTattoos()}
            .share()
        
        let didTapGenreItem = PublishRelay<Int>()
        let didTapRecommendItem = PublishRelay<Int>()
        let didTapTattooAlbumItem = PublishRelay<Int>()
        let fetchedGenreList = Observable.just(GenreType.allCases)
        
        let nextPageInfo = Observable.merge([refreshTrigger.map { _ in -1 }, nextFetchPage.asObservable()])
            .distinct()
            .filter { $0 != -1 }
            .flatMap { nextFetchPage in fetchTattoAlbumItems(at: nextFetchPage) }
            .withLatestFrom(nextFetchPage) { ($0, $1) }
            .share()
        
        let fetchedTattooAlbumItems = nextPageInfo
            .scan([HomeModel.TattooAlbum]()) { previousItems, nextPageInfo in
                let page = nextPageInfo.1
                let items = nextPageInfo.0
                return page == 0
                ? items
                : previousItems + items
            }.share()
        
        refreshEndDriver = refreshTrigger
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
        
        homeItems = Observable
            .combineLatest(
                fetchedGenreList, fetchedRecommendItems, fetchedTattooAlbumItems
            ) { genreItems, recommendItems, tattooAlbumItems -> [HomeSection] in
                [HomeSection(header: .empty,
                             items: genreItems.map { .genreCell(HomeGenreCellViewModel(with: $0)) }),
                 HomeSection(header: .title(CatSDKUser.userType() == .guest ? "추천 타투" : "\(CatSDKUser.user().name ?? "고객") 님을 위한 추천"),
                             items: recommendItems.map { .recommendCell(CommonTattooInfoCellViewModel(tattoo: $0)) }),
                 HomeSection(header: .empty,
                             items: [.emptyCell(HomeModel.Empty())]),
                 HomeSection(header: .title("실시간 인기 타투"),
                             items: tattooAlbumItems.map { .allTattoosCell(HomeTattooAlbumCellViewModel(with: $0)) })]
            }
            .asDriver(onErrorJustReturn: [])

        pushToBookmarkViewController = didTapHeartBarButtonItem
            .asDriver(onErrorJustReturn: ())

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
            .asDriver(onErrorJustReturn: .전체보기)
        
        let selectedRecommendTattooId = didTapCollectionViewItem
            .filter { $0.section == 1 }
            .withLatestFrom(fetchedRecommendItems) { ($0, $1) }
            .map { $1[$0.row].id }
        
        let selectedFamousTattooId = didTapCollectionViewItem
            .filter { $0.section == 3 }
            .withLatestFrom(fetchedTattooAlbumItems) { ($0, $1) }
            .map { $1[$0.row].tattooId }
        
        pushToTattooDetailViewController = Observable.merge([selectedRecommendTattooId,
                                                             selectedFamousTattooId])
            .asDriver(onErrorJustReturn: -1)
            
        
        func fetchTattoAlbumItems(at page: Int) -> Observable<[HomeModel.TattooAlbum]> {
            return CatSDKTattoo.famousTattoos(page: page, size: 9)
                .map { tattoos in
                    tattoos.map { tattoo in .init(tattooId: tattoo.id, imageURLString: tattoo.imageURLStrings.first ?? "")}
                }
        }
    }
    deinit {
        print("메모리 해제 잘되나 TEST, 홈")
    }
}
