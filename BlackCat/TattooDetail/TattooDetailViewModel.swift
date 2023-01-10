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
    private let tattooModel: Model.Tattoo

    let id: Int
    let price: Int
    let description: String
    let liked: Bool
    let imageURLStrings: [String?]
    let address: String

    // MARK: - Input
    let didTapAskButton = PublishRelay<Void>()
    let didTapBookmarkButton = PublishRelay<Void>()
    let didTapProfileImageView = PublishRelay<Void>()
    let didTapTattooistNameLabel = PublishRelay<Void>()

    // MARK: - Output

    let shouldFillHeartButton: Driver<Bool>
    let pushToTattooistDetailVC: Driver<Void>

    init(tattooModel: Model.Tattoo) {
        self.tattooModel = tattooModel

        self.id = tattooModel.id
        self.price = tattooModel.price
        self.description = tattooModel.description
        self.liked = tattooModel.liked
        self.imageURLStrings = tattooModel.imageURLStrings
        self.address = tattooModel.address

        let isBookmarkedTattooWhenFirstLoad = BehaviorRelay<Bool>(value: UserDefaultManager.bookmarkedTattoo.contains { $0.id == tattooModel.id } )

        didTapAskButton
            .subscribe { _ in print("Did Tap Ask Button") }
            .disposed(by: disposeBag)

        let isBookmarkedTattooAfterTapBookmarkButton = didTapBookmarkButton
            .map { _ in UserDefaultManager.bookmarkedTattoo.contains { $0.id == tattooModel.id } }
            .do { isBookmarked in
                if isBookmarked {
                    let index = UserDefaultManager.bookmarkedTattoo.firstIndex { $0.id == tattooModel.id }!
                    UserDefaultManager.bookmarkedTattoo.remove(at: index)
                } else {
                    UserDefaultManager.bookmarkedTattoo.append(tattooModel)
                }
            }
            .map { !$0 }

        let isBookmarkedTattoo = Observable.merge([
            isBookmarkedTattooWhenFirstLoad.asObservable(),
            isBookmarkedTattooAfterTapBookmarkButton
        ])

        shouldFillHeartButton = isBookmarkedTattoo
            .map { $0 }
            .asDriver(onErrorJustReturn: false)
        didTapBookmarkButton
            .subscribe { _ in print("Did Tap Bookmark Button") }
            .disposed(by: disposeBag)

        pushToTattooistDetailVC = Observable.merge([
            didTapProfileImageView.asObservable(),
            didTapTattooistNameLabel.asObservable()
        ])
        .asDriver(onErrorJustReturn: ())
        
        CatSDKTattoo.updateRecentViewTattoos(tattoo: tattooModel)
    }
}
