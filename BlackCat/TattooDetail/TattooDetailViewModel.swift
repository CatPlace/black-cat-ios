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

    // MARK: - Output

    init(tattooModel: Model.Tattoo) {
        self.tattooModel = tattooModel

        self.id = tattooModel.id
        self.price = tattooModel.price
        self.description = tattooModel.description
        self.liked = tattooModel.liked
        self.imageURLStrings = tattooModel.imageURLStrings
        self.address = tattooModel.address

        didTapAskButton
            .subscribe { _ in print("Did Tap Ask Button") }
            .disposed(by: disposeBag)

        didTapBookmarkButton
            .subscribe { _ in print("Did Tap Bookmark Button") }
            .disposed(by: disposeBag)
    }
}
