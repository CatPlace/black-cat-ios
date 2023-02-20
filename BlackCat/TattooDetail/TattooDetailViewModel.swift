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
    
    let didTapAskButton = PublishRelay<ButtonTag>()
    let didTapBookmarkButton = PublishRelay<Int>()
    let didTapProfileImageView = PublishRelay<Void>()
    let didTapTattooistNameLabel = PublishRelay<Void>()
    let bookmarkTrigger = PublishRelay<Void>()

    // MARK: - Output

    let shouldFillHeartButton: Driver<Bool>
    let pushToTattooistDetailVC: Driver<Int>

    let 문의하기Driver: Driver<Void>
    let 수정하기Driver: Driver<Model.Tattoo>
    let isGuestDriver: Driver<Bool>
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
    
    init(tattooId: Int) {
        didTapAskButton
            .subscribe { _ in print("Did Tap Ask Button") }
            .disposed(by: disposeBag)

        let tattooModel = CatSDKTattoo.tattooDetail(tattooId: tattooId)
            .share()
        
        let tattooModelSuccess = tattooModel
            .filter { $0 != .empty }
            .do { CatSDKTattoo.updateRecentViewTattoos(tattoo: $0) }
        
        let tattooModelFail = tattooModel
            .filter { $0 == .empty }
        
        isGuestDriver = .just(CatSDKUser.userType() == .guest)

        let isBookmarkedTattooWhenFirstLoad = tattooModelSuccess.compactMap { $0.liked }

        let isBookmarkedTattooAfterTapBookmarkButton =
        didTapBookmarkButton
            .map { $0 == 1 ? false : true }

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
            .asDriver(onErrorJustReturn: .empty)

        tattooimageUrls = tattooModelSuccess.map { $0.imageURLStrings }
            .asDriver(onErrorJustReturn: [])

        tattooCategories = tattooModelSuccess.map { $0.categoryId.map { GenreType(rawValue: $0)?.title ?? ""}}
            .asDriver(onErrorJustReturn: [])

        tattooistNameLabelText = tattooModelSuccess
            .map { $0.ownerName }
            .asDriver(onErrorJustReturn: "")

        descriptionLabelText = tattooModelSuccess
            .map { $0.description }
            .asDriver(onErrorJustReturn: "")

        createDateString = tattooModelSuccess
            .compactMap { $0.createDate }
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
    }
}
