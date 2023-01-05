//
//  BookmarkViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import Foundation

import BlackCatSDK
import RxCocoa
import RxSwift

class BookmarkViewModel {

    let disposeBag = DisposeBag()
    let bookmarkPageViewModels: [BookmarkTattooViewModel]

    // MARK: - Input

    let viewDidLoad = PublishRelay<Void>()
    let didTapEditBarButtonItem = PublishRelay<Void>()
    let didTapCancelBarButtonItem = PublishRelay<Void>()
    let currentShowingPageIndex = BehaviorRelay<Int>(value: 0)

    // MARK: - Output

    let updateModeDriver: Driver<EditMode>

    init(bookmarkPageViewModels: [BookmarkTattooViewModel]) {
        self.bookmarkPageViewModels = bookmarkPageViewModels

        let currentEditMode = BehaviorRelay<EditMode>(value: .normal)

        let currentShowingPageViewModel = currentShowingPageIndex
            .distinctUntilChanged()
            .map { bookmarkPageViewModels[$0] }

        let editModeWhenDidTapEditButton = didTapEditBarButtonItem
            .withLatestFrom(currentEditMode) { $1 == .normal ? EditMode.edit : EditMode.normal }
            .withLatestFrom(currentShowingPageViewModel) { editMode, viewModel in
                viewModel.didTapEditButton.accept(editMode)
                return editMode
            }
            .share()

        let editModeWhenDidTapCancelButton = didTapCancelBarButtonItem
            .withLatestFrom(currentEditMode) { $1 == .normal ? EditMode.edit : EditMode.normal }
            .withLatestFrom(currentShowingPageViewModel) { editMode, viewModel -> (editMode: EditMode, viewModel: BookmarkTattooViewModel) in
                return (editMode, viewModel)
            }
            .do { $0.viewModel.refreshSelectedCells.accept(()) }
            .map { $0.editMode }

        let updateEditMode = Observable.merge([
            editModeWhenDidTapEditButton,
            editModeWhenDidTapCancelButton
        ])
            .do { currentEditMode.accept($0) }
            .withLatestFrom(currentShowingPageViewModel) { ($0, $1) }
            .do { editMode, viewModel in viewModel.editMode.accept(editMode) }
            .map { editMode, _ in editMode }

        let childViewWillDisappearObservables = bookmarkPageViewModels
            .map { $0.viewWillDisappear.asObservable() }

        let viewWillDisappear = Observable.merge(childViewWillDisappearObservables)
            .withLatestFrom(currentShowingPageViewModel) { _, showingPageViewModel in
                showingPageViewModel.didTapEditButton.accept(.edit)
            }

        updateModeDriver = Observable.merge([
            viewWillDisappear.map { _ in EditMode.normal },
            updateEditMode
        ])
        .do { print("EditMode DRiver: \($0)") }
        .asDriver(onErrorJustReturn: .normal)
    }
}
