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
    let didTapCancelBarButtonItem = PublishRelay<EditMode>()
    let currentShowingPageIndex = BehaviorRelay<Int>(value: 0)

    // MARK: - Output

    let updateModeDriver: Driver<EditMode>

    init(bookmarkPageViewModels: [BookmarkTattooViewModel]) {
        self.bookmarkPageViewModels = bookmarkPageViewModels

        let currentShowingPageViewModel = currentShowingPageIndex
            .distinctUntilChanged()
            .map { bookmarkPageViewModels[$0] }

        let editModeWhenDidTapEditButton = didTapEditBarButtonItem
            .share()

        let editModeWhenDidTapCancelButton = didTapCancelBarButtonItem
            .withLatestFrom(currentShowingPageViewModel) { editMode, viewModel -> (editMode: EditMode, viewModel: BookmarkTattooViewModel) in
                return (editMode, viewModel)
            }
            .do { $0.viewModel.refreshSelectedCells.accept(()) }
            .map { $0.editMode }

        let updateEditMode = Observable.merge([
            editModeWhenDidTapEditButton,
            editModeWhenDidTapCancelButton
        ])
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
