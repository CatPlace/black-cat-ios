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

enum BookmarkType: Int, CaseIterable {
    case tattoo
    case tattooist
}

class BookmarkViewModel {
    
    let disposeBag = DisposeBag()
    let bookmarkPageViewModels: [BookmarkPostViewModel]
    
    // MARK: - Input
    let didTapEditBarButtonItem = PublishRelay<String>()
    let didTapCancelBarButtonItem = PublishRelay<Void>()
    let currentShowingPageIndex = BehaviorRelay<Int>(value: 0)
    
    // MARK: - Output
    let updateModeDriver: Driver<EditMode>
    
    init() {
        let bookmarkTypes = PostType.allCases
        
        let editMode = BehaviorRelay<EditMode>(value: .normal)
        
        bookmarkPageViewModels = PostType.allCases
            .map { .init(bookmarkModel: .init(postType: bookmarkTypes[$0.rawValue],
                                              editMode: editMode)) }
        
        let didTapEditButton = didTapEditBarButtonItem
            .filter { EditMode(rawValue: $0) == .normal }
            .map { _ in () }
        
        let didTapDeleteButton = didTapEditBarButtonItem
            .filter { EditMode(rawValue: $0) == .edit }
            .map { _ in () }
        
        let toggleEvent = Observable.merge([
            didTapEditButton,
            didTapCancelBarButtonItem.asObservable()
        ])
        
        let currentShowingPageIndex = currentShowingPageIndex
            .distinctUntilChanged()
        
        let currentPage = currentShowingPageIndex
            .compactMap { BookmarkType(rawValue: $0) }
        
        let toggledEditMode = toggleEvent
                .withLatestFrom(editMode)
                .map { $0.toggle()}
                .share()
        
        let currentPageEditMode = currentShowingPageIndex
            .flatMap { _ in editMode }
            .share()
        
        updateModeDriver = Observable
            .merge([toggledEditMode, currentPageEditMode])
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .normal)
        
        toggledEditMode
                .bind(to: editMode)
                .disposed(by: disposeBag)
        
        didTapDeleteButton
            .withLatestFrom(currentPage)
            .bind(with: self) {
                $0.bookmarkPageViewModels[$1.rawValue].showWariningDeleteAlertTrigger.accept(())
            }.disposed(by: disposeBag)
    }
}
