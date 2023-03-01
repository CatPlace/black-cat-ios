//
//  TattooDetailViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/12/27.
//

import UIKit

import BlackCatSDK
import RxCocoa
import RxSwift

struct TattooDetailViewModel {

    // MARK: - Properties
    private let disposeBag = DisposeBag()

    // MARK: - Input
    typealias ButtonTag = Int
    
    let viewWillAppear = PublishRelay<Bool>()
    let didTapAskButton = PublishRelay<ButtonTag>()
    let didTapBookmarkButton = PublishRelay<Int>()
    let didTapProfileImageView = PublishRelay<Void>()
    let didTapTattooistNameLabel = PublishRelay<Void>()
    let bookmarkTrigger = PublishRelay<Void>()
    let deleteTrigger = PublishRelay<Void>()
    
    // MARK: - Output
    let shouldFillHeartButton: Driver<Bool>
    let pushToTattooistDetailVC: Driver<Int>

    let 문의하기Driver: Driver<Void>
    let 수정하기Driver: Driver<Model.Tattoo>
    let tattooimageUrls: Driver<[String]>
    let tattooCategories: Driver<[String]>
    let imageCountDriver: Driver<Int>
    let isOwnerDriver: Driver<Bool>
    let tattooistNameLabelText: Driver<String>
    let descriptionLabelText: Driver<String>
    let createDateString: Driver<String>
    let tattooistProfileImageUrlString: Driver<String>
    let bookmarkCountStringDriver: Driver<String>
    let tattooTitleStringDriver: Driver<String>
    let loginNeedAlertDriver: Driver<Void>
    let alertMessageDriver: Driver<String>
    let popViewDriver: Driver<Void>
    let genreCountDriver: Driver<Int>
    
    init(tattooId: Int) {
        let tattooModel = viewWillAppear
            .flatMap { _ in CatSDKTattoo.tattooDetail(tattooId: tattooId) }
            .share()
        
        let tattooModelSuccess = tattooModel
            .filter { $0 != .empty }
            .do { CatSDKTattoo.updateRecentViewTattoos(tattoo: $0) }
        
        let tattooModelFail = tattooModel
            .filter { $0 == .empty }
            .map { _ in "오류가 발생했습니다." }
        
        let isBookmarkedTattooWhenFirstLoad = tattooModelSuccess
            .flatMap { CatSDKNetworkBookmark.rx.statusOfBookmark(postId: $0.id) }
            .map { $0.liked }
            .share()

        let isGuest = viewWillAppear
            .map { _ in CatSDKUser.userType() == .guest }
        
        let isBookmarkedTattooAfterTapBookmarkButton =
        didTapBookmarkButton
            .withLatestFrom(isGuest) { ($0, $1) }
            .filter { !$0.1 }
            .map { $0.0 == 1 ? false : true }
        
        loginNeedAlertDriver = didTapBookmarkButton
            .withLatestFrom(isGuest) { ($0, $1) }
            .filter { $0.1 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        let isBookmarkedTattoo = Observable.merge([
            isBookmarkedTattooWhenFirstLoad,
            isBookmarkedTattooAfterTapBookmarkButton
        ]).share()

        shouldFillHeartButton = isBookmarkedTattoo
            .map { $0 }
            .asDriver(onErrorJustReturn: false)

        pushToTattooistDetailVC = Observable.merge([
            didTapProfileImageView.asObservable(),
            didTapTattooistNameLabel.asObservable()
        ]).withLatestFrom(tattooModelSuccess) { $1.ownerId }
            .share()
        .asDriver(onErrorJustReturn: -1)

        let bookmarkCountWhenFirstLoad = tattooModelSuccess.map { $0.likeCount ?? 0 }

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

        let changedBookmark = bookmarkTrigger
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
            .flatMap { CatSDKNetworkBookmark.rx.bookmarkPost(postId: tattooId) }
            .subscribe()
            .disposed(by: disposeBag)

        bookmarkOffTrigger
            .flatMap {
                CatSDKNetworkBookmark.rx.deleteBookmarkedPost(postId: tattooId)
            }
            .subscribe()
            .disposed(by: disposeBag)

        문의하기Driver = didTapAskButton
            .filter { $0 == 1}
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        수정하기Driver = didTapAskButton
            .filter { $0 == 0 }
            .withLatestFrom(tattooModelSuccess)
            .debug("이전 타투값")
            .asDriver(onErrorJustReturn: .empty)

        tattooimageUrls = tattooModelSuccess.map { $0.imageURLStrings }
            .asDriver(onErrorJustReturn: [])

        tattooCategories = tattooModelSuccess.map { $0.categoryIds.map { GenreType(rawValue: $0)?.title ?? ""}}
            .asDriver(onErrorJustReturn: [])

        tattooistNameLabelText = tattooModelSuccess
            .map { $0.ownerName }
            .asDriver(onErrorJustReturn: "")

        descriptionLabelText = tattooModelSuccess
            .map { $0.description }
            .asDriver(onErrorJustReturn: "")

        createDateString = tattooModelSuccess
            .compactMap { $0.createDate?.toDate()?.toSimpleString() }
            .asDriver(onErrorJustReturn: "")

        tattooistProfileImageUrlString = tattooModelSuccess
            .compactMap { $0.profileImageUrls }
            .asDriver(onErrorJustReturn: "")

        isOwnerDriver = tattooModelSuccess
            .map { $0.ownerId == CatSDKUser.user().id }
            .asDriver(onErrorJustReturn: false)

        imageCountDriver = tattooimageUrls.map { $0.count }
        
        tattooTitleStringDriver = tattooModelSuccess
            .map { $0.title }
            .asDriver(onErrorJustReturn: "error")
        
        genreCountDriver = tattooModelSuccess
            .map { $0.categoryIds.count }
            .asDriver(onErrorJustReturn: 0)
        
        let deleteResult = deleteTrigger
            .flatMap { CatSDKTattooist.deleteTattoo(tattooIds: [tattooId]) }
            .share()
        
        let deleteSuccess = deleteResult
            .filter { $0.0 == $0.1 }
            .do { _ in
                CatSDKTattooist.updateTattooist(deletedTattooId: tattooId)
                CatSDKTattoo.updateRecentViewTattoos(deletedTattooId: tattooId)
            }
            .map { _ in "삭제에 성공했습니다." }
        
        let deleteFail = deleteResult
            .filter { $0.0 != $0.1}
            .map { _ in "삭제에 실패했습니다." }
        
        alertMessageDriver = Observable.merge([deleteSuccess, deleteFail])
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
        
        popViewDriver = Observable.merge([deleteSuccess, tattooModelFail])
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
    }

}
