//
//  BookmarkViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import Foundation

import RxCocoa
import RxSwift

class BookmarkViewModel {

    let disposeBag = DisposeBag()

    let bookmarkTattooViewModel = BookmarkTattooViewModel()

    // MARK: - Input

    let viewDidLoad = PublishRelay<Void>()
    let didTap = PublishRelay<EditMode>()
    let didTapEditBarButtonItem = PublishRelay<EditMode>()

    // MARK: - Output
    let updateModeDriver: Driver<EditMode>

    init() {
        let didTapEditButton = didTapEditBarButtonItem
            .share()

        didTapEditButton
            .bind(to: bookmarkTattooViewModel.editMode)
            .disposed(by: disposeBag)

        updateModeDriver = didTapEditButton
            .map { $0.toggle() }
            .asDriver(onErrorJustReturn: .edit)
    }
}
