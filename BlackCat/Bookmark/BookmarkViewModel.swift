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
//    let bookmarkTattooViewModel: BookmarkTattooViewModel
//    let bookmarkMagazineViewModel: BookmarkTattooViewModel

    // MARK: - Input

    let viewDidLoad = PublishRelay<Void>()
    let didTap = PublishRelay<EditMode>()
    let didTapEditBarButtonItem = PublishRelay<EditMode>()
    let currentShowingPageIndex = BehaviorRelay<Int>(value: 0)

    // MARK: - Output
    let updateModeDriver: Driver<EditMode>

    init(
//        bookmarkTattooViewModel: BookmarkTattooViewModel,
//        bookmarkMagazineViewModel: BookmarkTattooViewModel
        bookmarkPageViewModels: [BookmarkTattooViewModel]
    ) {
        self.bookmarkPageViewModels = bookmarkPageViewModels

        let didTapEditButton = didTapEditBarButtonItem
            .share()

        let currentShowingPageViewModel = currentShowingPageIndex
            .distinctUntilChanged()
            .debug("currentShowingPageIndex")
            .map { bookmarkPageViewModels[$0] }

        didTapEditButton
            .withLatestFrom(currentShowingPageViewModel) { ($0, $1) }
            .subscribe { editMode, viewModel in
                print("editMode: \(editMode)")
                print("viewModel: \(viewModel)")
                viewModel.editMode.accept(editMode)
            }
            .disposed(by: disposeBag)

        updateModeDriver = currentShowingPageViewModel
            .flatMap { $0.editMode }
            .map { $0.toggle() }
            .asDriver(onErrorJustReturn: .edit)
    }
}
