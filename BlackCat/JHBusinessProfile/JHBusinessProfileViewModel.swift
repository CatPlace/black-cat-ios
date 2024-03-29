//
//  JHBusinessProfileViewModel.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/28.
//
import Foundation

import RxSwift
import RxCocoa
import RxRelay
import RxDataSources
import BlackCatSDK

final class JHBusinessProfileViewModel {
    let disposeBag = DisposeBag()
    let isOwner: Bool
    var currentDeleteProductIndexList: [Int] = []
    let headerViewModel: JHBPContentSectionHeaderViewModel = .init()
    let askBottomViewModel: AskBottomViewModel = .init()
    
    // MARK: - Inputs
    let viewDidLoad = PublishRelay<Void>()
    let cellWillAppear = PublishRelay<CGFloat>()
    let cellDidAppear = PublishRelay<CGFloat>()
    let viewWillAppear = PublishRelay<Void>()
    let viewDidAppear = PublishRelay<Void>()
    let selectedTattooIndex = PublishRelay<Int>()
    let deleteProductTrigger = PublishRelay<[Int]>()
    let deleteCompleteRelay = PublishRelay<Void>()
    let viewWillDisappear = PublishRelay<Void>()
    let didTapBookmarkButton = PublishRelay<Int>()
    
    // MARK: - Outputs
    let visibleCellIndexPath: Driver<Int>
    let sections: Driver<[JHBusinessProfileCellSection]>
    let showTattooDetail: Driver<Int>
    let scrollToTypeDriver: Driver<JHBPContentHeaderButtonType>
    let initEditModeDriver: Driver<Void>
    let deleteSuccessDriver: Driver<Void>
    let deleteFailDriver: Driver<Void>
    let shouldFillHeartButton: Driver<Bool>
    let bookmarkCountStringDriver: Driver<String>
    let serverErrorDriver: Driver<Void>
    let navigationTitleDriver: Driver<String>
    let alertMessageDriver: Driver<String>
    let loginNeedAlertDriver: Driver<Void>
    
    init(tattooistId: Int) {
        // TODO: - 유저 구분
        let isOwner = tattooistId == CatSDKUser.user().id
        self.isOwner = isOwner
        
        let fetchTrigger = Observable.merge([viewWillAppear.asObservable(), deleteCompleteRelay.asObservable()])
        
        let localTattooistInfo = fetchTrigger
            .filter { isOwner }
            .map { _ in CatSDKTattooist.localTattooistInfo() }
        
        let fetchedTattooistInfo = viewDidLoad
            .flatMap { _ in
                
                let fetchedProfileData = CatSDKTattooist.profile(tattooistId: tattooistId).share()
                let fetchedProductsData = CatSDKTattooist.products(tattooistId: tattooistId).share()
                let fetchedPriceInfoData = CatSDKTattooist.priceInfo(tattooistId: tattooistId).share()
                return Observable.combineLatest(fetchedProfileData, fetchedProductsData, fetchedPriceInfoData) {
                    Model.TattooistInfo(introduce: $0, tattoos: $1, estimate: $2)
                }
            }
            .share()
        
        let profileId = fetchedTattooistInfo
            .map { $0.introduce.profileId }
            .share()
        
        let fetchedTattooistInfoSuccess = fetchedTattooistInfo
            .filter { $0.introduce.introduce != "error" }
            .do {
                CatSDKTattooist.updateLocalTattooistInfo(tattooistInfo: $0)
            }
        
        let fetchedTattooistInfoFail = fetchedTattooistInfo
            .filter { $0.introduce.introduce == "error" }
            .map { _ in () }
        
        serverErrorDriver = fetchedTattooistInfoFail
            .asDriver(onErrorJustReturn: ())
        
        let currentTattooistInfo = Observable.merge([
            localTattooistInfo.filter { $0 != .empty },
            fetchedTattooistInfoSuccess
        ]).share()
        
        sections = currentTattooistInfo
            .map { configurationSections(
                imageUrlString: $0.introduce.imageUrlString ?? "",
                profileDescription: $0.introduce,
                products: $0.tattoos,
                priceInformation: $0.estimate.description
            ) }
            .asDriver(onErrorJustReturn: [])
        
        navigationTitleDriver = currentTattooistInfo
            .compactMap { $0.introduce.userName }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
        
        visibleCellIndexPath = cellWillAppear
            .map { Int($0) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
        
        // TODO: - 에러 처리
        showTattooDetail = selectedTattooIndex
            .map { CatSDKTattooist.localTattooistInfo().tattoos[$0].tattooId }
            .asDriver(onErrorJustReturn: -1)
        
        scrollToTypeDriver = viewWillAppear
            .withLatestFrom(visibleCellIndexPath)
            .compactMap { .init(rawValue: $0) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .product)
        
        let deleteReuslt = deleteProductTrigger
            .withLatestFrom(currentTattooistInfo) { (index: $0, tattooist: $1) }
            .map { indexList, tattooist in
                indexList.map { tattooist.tattoos[$0].tattooId }
            }.flatMap { CatSDKTattooist.deleteTattoo(tattooIds: $0) }
            .share()
        
        let deleteSuccess = deleteReuslt.filter { $0.0 == $0.1 }
        
        // TODO: - 에러 처리
        let deleteFail = deleteReuslt.filter { $0.0 != $0.1 }
        
        deleteSuccessDriver = deleteSuccess
            .withLatestFrom(deleteReuslt)
            .map { $0.1 }
            .map { ids in
                ids.forEach {
                    CatSDKTattoo.updateRecentViewTattoos(deletedTattooId: $0)
                    CatSDKTattooist.updateTattooist(deletedTattooId: $0)
                }
                return ()
            }.asDriver(onErrorJustReturn: ())
        
        deleteFailDriver = deleteFail
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        let isGuest = viewWillAppear
            .map { _ in CatSDKUser.userType() == .guest }
        
        let isBookmarkedTattooWhenFirstLoad = viewWillAppear
            .flatMap { _ in profileId }
            .withLatestFrom(isGuest) { ($0, $1) }
            .filter { !$0.1 }
            .map { $0.0 }
            .flatMap {  CatSDKBookmark.isBookmarked(postId: $0) }
            .share()
        
        loginNeedAlertDriver = didTapBookmarkButton
            .withLatestFrom(isGuest) { ($0, $1) }
            .filter { $0.1 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        let isBookmarkedTattooAfterTapBookmarkButton =
        didTapBookmarkButton
            .withLatestFrom(isGuest) { ($0, $1) }
            .filter { !$0.1 }
            .filter { _ in !isOwner }
            .map { $0.0 == 1 ? false : true }
        
        let isBookmarkedTattoo = Observable.merge([
            isBookmarkedTattooWhenFirstLoad,
            isBookmarkedTattooAfterTapBookmarkButton
        ]).share()
        
        let warningOwnerTapMessage = didTapBookmarkButton
            .filter { _ in isOwner }
            .map { _ in "본인 게시물은 찜할 수 없습니다." }
        
        alertMessageDriver = warningOwnerTapMessage
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
        
        shouldFillHeartButton = isBookmarkedTattoo
            .map { $0 }
            .asDriver(onErrorJustReturn: false)
        
        initEditModeDriver = cellWillAppear
            .distinctUntilChanged()
            .filter { $0 != 1 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        let bookmarkCountWhenFirstLoad =  profileId.flatMap { CatSDKNetworkBookmark.rx.countOfBookmark(postId: $0).map { $0.counts } }
            .share()
        
        let changeBookmarkCount = isBookmarkedTattoo // 북마크 탭
            .withLatestFrom(isBookmarkedTattooWhenFirstLoad) { ($0, $1) }
            .withLatestFrom(bookmarkCountWhenFirstLoad) { ($0.0, $0.1, $1) }
            .map { changedIsBookmarked, firstIsBookmarked, count in
                if firstIsBookmarked {
                    return count + (changedIsBookmarked ? 0 : -1)
                } else {
                    return count + (changedIsBookmarked ? 1 : 0)
                }
            }
        
        bookmarkCountStringDriver = Observable.merge([
            bookmarkCountWhenFirstLoad,
            changeBookmarkCount
        ])
        .map { String($0) }
        .asDriver(onErrorJustReturn: "")
        
        let changedBookmark = viewWillDisappear
            .withLatestFrom(Observable.combineLatest(isBookmarkedTattooWhenFirstLoad, isBookmarkedTattooAfterTapBookmarkButton))
            .filter { $0.0 != $0.1 }
            .map { $0.1 }
        
        let bookmarkOnTrigger = changedBookmark
            .filter { $0 }
            .map { _ in () }
        
        let bookmarkOffTrigger = changedBookmark
            .filter { !$0 }
            .map { _ in () }
        
        bookmarkOnTrigger
            .withLatestFrom(profileId)
            .flatMap { CatSDKNetworkBookmark.rx.bookmarkPost(postId: $0) }
            .subscribe()
            .disposed(by: disposeBag)
        
        bookmarkOffTrigger
            .withLatestFrom(profileId)
            .flatMap { CatSDKNetworkBookmark.rx.deleteBookmarkedPost(postId: $0) }
            .subscribe()
            .disposed(by: disposeBag)
        
        func configurationSections(imageUrlString: String, profileDescription: Model.TattooistIntroduce, products: [Model.TattooThumbnail], priceInformation: String) -> [JHBusinessProfileCellSection] {
            
            let thumbnailCell: JHBusinessProfileItem = .thumbnailImageItem(.init(imageUrlString: imageUrlString))
            
            let thumbnailSection = JHBusinessProfileCellSection.thumbnailImageCell([thumbnailCell])
            
            let contentProfile: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 0), profile: profileDescription, products: [], priceInfo: ""))
            let contentProductCellViewModel: JHBPContentCellViewModel = .init(contentModel: .init(order: 1),
                                                                              profile: .init(introduce: ""),
                                                                              products: products,
                                                                              priceInfo: "")
            
            let contentProduct: JHBusinessProfileItem = .contentItem(contentProductCellViewModel)
            
            let contentPriceInfo: JHBusinessProfileItem = .contentItem(.init(contentModel: .init(order: 2), profile: .init(introduce: ""), products: [], priceInfo: priceInformation))
            
            let contentSection = JHBusinessProfileCellSection.contentCell([contentProfile, contentProduct, contentPriceInfo])
            
            return [thumbnailSection, contentSection]
        }
        
    }
}

enum JHBusinessProfileItem: Equatable, IdentifiableType {
    var identity: some Hashable { UUID().uuidString }
    
    case thumbnailImageItem(JHBPThumbnailImageCellViewModel)
    case contentItem(JHBPContentCellViewModel)
    
    static func == (lhs: JHBusinessProfileItem, rhs: JHBusinessProfileItem) -> Bool {
        lhs.identity == rhs.identity
    }
}

enum JHBusinessProfileCellSection {
    case thumbnailImageCell([JHBusinessProfileItem])
    case contentCell([JHBusinessProfileItem])
}

extension JHBusinessProfileCellSection: AnimatableSectionModelType {
    var identity: String { UUID().uuidString }
    
    typealias Item = JHBusinessProfileItem
    
    var items: [Item] {
        switch self {
        case .thumbnailImageCell(let items): return items
        case .contentCell(let items): return items
        }
    }
    
    init(original: JHBusinessProfileCellSection, items: [JHBusinessProfileItem]) {
        switch original {
        case .thumbnailImageCell: self = .thumbnailImageCell(items)
        case .contentCell: self = .contentCell(items)
        }
    }
}
