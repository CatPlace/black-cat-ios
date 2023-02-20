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
    
    let viewWillAppear = PublishRelay<Bool>()
    let didTapEditBarButtonItem = PublishRelay<String>()
    let didTapCancelBarButtonItem = PublishRelay<Void>()
    let currentShowingPageIndex = BehaviorRelay<Int>(value: 0)
    
    // MARK: - Output
    let updateModeDriver: Driver<EditMode>
    
    init() {
        let bookmarkTypes = PostType.allCases
        
        let editModes: [BehaviorRelay<EditMode>] = bookmarkTypes
            .map { _ in .init(value: .normal) }
        
        bookmarkPageViewModels = editModes.enumerated()
            .map { .init(bookmarkModel: .init(postType: bookmarkTypes[$0], editMode: $1)) }
        
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
        
        let currentPage = currentShowingPageIndex
            .compactMap { BookmarkType(rawValue: $0) }
        
        let toggledEditMode = bookmarkTypes.enumerated().map { index, _ in
            return toggleEvent
                .withLatestFrom(currentPage)
                .filter { $0.rawValue == index }
                .withLatestFrom(editModes[index])
                .map { $0.toggle()}
                .share()
        }
        
        let disposeBag = disposeBag
        
        bookmarkTypes.enumerated().forEach { index, _ in
            toggledEditMode[index]
                .bind(to: editModes[index])
                .disposed(by: disposeBag)
        }
        
        let currentPageEditMode = currentShowingPageIndex
            .flatMap { editModes[$0] }
        
        updateModeDriver = Observable
            .merge(toggledEditMode + [currentPageEditMode])
            .asDriver(onErrorJustReturn: .normal)
        
        didTapDeleteButton
            .withLatestFrom(currentPage)
            .bind(with: self) {
                $0.bookmarkPageViewModels[$1.rawValue].showWariningDeleteAlertTrigger.accept(())
            }.disposed(by: disposeBag)
    }
}
