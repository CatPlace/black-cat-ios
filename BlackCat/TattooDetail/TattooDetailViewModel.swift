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
    let pushToTattooistDetailVC: Driver<Void>

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

    init(tattooId: Int) {
        didTapAskButton
            .subscribe { _ in print("Did Tap Ask Button") }
            .disposed(by: disposeBag)

        let tattooModel = CatSDKTattoo.tattooDetail(tattooId: tattooId).share()

        isGuestDriver = tattooModel
            .map { $0.ownerId == CatSDKUser.user().id }
            .asDriver(onErrorJustReturn: false)
        let a = tattooModel.flatMap { tattoo in
            BehaviorRelay<Bool>(value: tattoo.liked!)
        }
        let isBookmarkedTattooWhenFirstLoad = tattooModel.compactMap { $0.liked }

        let isBookmarkedTattooAfterTapBookmarkButton =
        didTapBookmarkButton
            .map { $0 == 1 ? false : true }
            .debug("좋이요👍👍👍")

        let isBookmarkedTattoo = Observable.merge([
            isBookmarkedTattooWhenFirstLoad,
            isBookmarkedTattooAfterTapBookmarkButton
        ])

        shouldFillHeartButton = isBookmarkedTattoo
            .map { $0 }
            .asDriver(onErrorJustReturn: false)

        pushToTattooistDetailVC = Observable.merge([
            didTapProfileImageView.asObservable(),
            didTapTattooistNameLabel.asObservable()
        ]).asDriver(onErrorJustReturn: ())

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
            .debug("서버통신 on")
            .subscribe()
            .disposed(by: disposeBag)

        bookmarkOffTrigger
            .flatMap {
                CatSDKNetworkBookmark.rx.deleteBookmarkedPost(postId: tattooId)
            }
            .debug("서버통신 off")
            .subscribe()
            .disposed(by: disposeBag)

        문의하기Driver = didTapAskButton
            .filter { $0 == 1}
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        수정하기Driver = didTapAskButton
            .filter { $0 == 0 }
            .withLatestFrom(tattooModel)
            .asDriver(onErrorJustReturn: .empty)

        tattooimageUrls = tattooModel.map { $0.imageURLStrings }
            .asDriver(onErrorJustReturn: [])

        tattooCategories = tattooModel.map { $0.categoryId.map { GenreType(rawValue: $0)?.title ?? ""}}
            .asDriver(onErrorJustReturn: [])

        tattooistNameLabelText = tattooModel
            .map { $0.ownerName }
            .asDriver(onErrorJustReturn: "")

        descriptionLabelText = tattooModel
            .map { $0.description }
            .asDriver(onErrorJustReturn: "")

        createDateString = tattooModel
            .compactMap { $0.createDate }
            .asDriver(onErrorJustReturn: "")

        tattooistProfileImageUrlString = tattooModel
            .compactMap { $0.profileImageUrls }
            .asDriver(onErrorJustReturn: "")

        isOwnerDriver = tattooModel
            .map { $0.ownerId == CatSDKUser.user().id }
            .asDriver(onErrorJustReturn: false)

        imageCountDriver = tattooimageUrls.map { $0.count }
    }
}
