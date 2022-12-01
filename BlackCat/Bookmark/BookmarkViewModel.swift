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
    let bookmarkPageViewModels: [BookmarkTattooViewModel]

    // MARK: - Input

    let viewDidLoad = PublishRelay<Void>()
    let didTap = PublishRelay<EditMode>()
    let didTapEditBarButtonItem = PublishRelay<EditMode>()
    let currentShowingPageIndex = BehaviorRelay<Int>(value: 0)

    // MARK: - Output

    let updateModeDriver: Driver<EditMode>

    init(
        bookmarkPageViewModels: [BookmarkTattooViewModel]
    ) {
        self.bookmarkPageViewModels = bookmarkPageViewModels

        let didTapEditButton = didTapEditBarButtonItem
            .share()

        let currentShowingPageViewModel = currentShowingPageIndex
            .distinctUntilChanged()
            .debug("currentShowingPageIndex")
            .map { bookmarkPageViewModels[$0] }

        let updateEditMode = didTapEditButton
            .withLatestFrom(currentShowingPageViewModel) { ($0, $1) }
            .do { editMode, viewModel in viewModel.editMode.accept(editMode) }
            .map { editMode, _ in editMode }
            .map { $0.toggle() }

        let childViewWillDisappearObservables = bookmarkPageViewModels
            .map { $0.viewWillDisappear.asObservable() }

        let viewWillDisappear = Observable.merge(childViewWillDisappearObservables)
            .withLatestFrom(currentShowingPageViewModel) { _, showingPageViewModel in
                showingPageViewModel.editMode.accept(.edit)
            }

        updateModeDriver = Observable.merge([
            viewWillDisappear.map { _ in EditMode.normal },
            updateEditMode
        ])
        .asDriver(onErrorJustReturn: .normal)
    }
}
