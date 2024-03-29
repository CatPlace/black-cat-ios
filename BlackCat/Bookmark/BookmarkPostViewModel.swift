//
//  BookmarkPostViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import Foundation

import BlackCatSDK
import RxCocoa
import RxSwift

class BookmarkPostModel {
    let postType: PostType
    let editMode: BehaviorRelay<EditMode>
    let deleteIndexList = BehaviorRelay<[Int]>(value: [])
    let posts = PublishRelay<[Model.Bookmark]>()
    
    init(postType: PostType, editMode: BehaviorRelay<EditMode>) {
        self.postType = postType
        self.editMode = editMode
    }
}

class BookmarkPostViewModel {
    typealias CellIndex = Int
    typealias SelectNumber = Int
    typealias EditingCellIndexToSelectNumberDict = Dictionary<CellIndex, SelectNumber>
    
    let disposeBag = DisposeBag()
    
    // MARK: - Input
    let didSelectItem = PublishRelay<Int>()
    let deleteIndexList = BehaviorRelay<[Int]>(value: [])
    let showWariningDeleteAlertTrigger = PublishRelay<()>()
    let deleteTrigger = PublishRelay<[Int]>()
    let viewWillAppear = PublishRelay<Bool>()
    
    // MARK: - Output
    let showWariningDeleteAlertDriver: Driver<[Int]>
    let showDeleteSuccessAlertDriver: Driver<Void>
    let showDeleteFailAlertDriver: Driver<Void>
    let postItems: Driver<[SelectableImageCellViewModel]>
    let showTattooistDetailVCDriver: Driver<Int>
    let showTattooDetailVCDriver: Driver<Int>
    let isEmptyDriver: Driver<Bool>
    let emptyLabelTextDriver: Driver<String>
    
    init(bookmarkModel: BookmarkPostModel) {
        
        let postAtViewWillAppear = viewWillAppear
            .flatMap { _ in CatSDKBookmark.bookmarkListInSpecificUser(postType: bookmarkModel.postType) }
            .share()
        
        let postItemsObservable = Observable.merge([postAtViewWillAppear, bookmarkModel.posts.asObservable()])
            .share()
            
        
        let cellViewModels = postItemsObservable
            .do { _ in bookmarkModel.editMode.accept(.normal) }
            .map {
            $0.map { SelectableImageCellViewModel(
                editMode: bookmarkModel.editMode,
                product: .init(tattooId: $0.postId,
                               imageUrlString: $0.imageUrl ?? "")
            ) }
        }
        
        postItems = cellViewModels
            .asDriver(onErrorJustReturn: [])
        
        let deleteResult = deleteTrigger
            .withLatestFrom(postItemsObservable) { ($0, $1) }
            .map { indexList, posts in
                indexList.map { posts[$0].postId }
            }.flatMap(CatSDKBookmark.deleteBookmark)
            .share()
        
        // TODO: - 에러처리
        let deleteSuccess = deleteResult
            .filter { $0.postIds != [-1] }
        
        let deleteFail = deleteResult
            .filter { $0.postIds == [-1]}
        
        _ = deleteSuccess
            .withLatestFrom(bookmarkModel.deleteIndexList)
            .withLatestFrom(postItemsObservable) { ($0, $1) }
            .map { deletedIndexList, posts in
                var newPosts = posts
                newPosts.remove(atOffsets: IndexSet(deletedIndexList))
                bookmarkModel.editMode.accept(.normal)
                bookmarkModel.deleteIndexList.accept([])
                return newPosts
            }.bind(to: bookmarkModel.posts)
            .disposed(by: disposeBag)
        
        showWariningDeleteAlertDriver = showWariningDeleteAlertTrigger
            .withLatestFrom(bookmarkModel.deleteIndexList)
            .asDriver(onErrorJustReturn: [])
        
        showDeleteSuccessAlertDriver = deleteSuccess
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        showDeleteFailAlertDriver = deleteFail
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        let didSelectItemWithEditMode = didSelectItem
            .withLatestFrom(bookmarkModel.editMode) { ($0, $1) }
        
        let selectedItemInEditMode = didSelectItemWithEditMode
            .filter { $0.1 == .edit }
            .map { $0.0 }
        
        let selectedItemInNormalMode = didSelectItemWithEditMode
            .filter { $0.1 == .normal }
            .map { $0.0 }
        
        showTattooDetailVCDriver = selectedItemInNormalMode
            .filter { _ in bookmarkModel.postType == .tattoo }
            .withLatestFrom(postItemsObservable) { ($0, $1) }
            .map { $1[$0].postId }
            .asDriver(onErrorJustReturn: -1)
        
        // TODO: - 서버에서 어떡할껀지 의논
        showTattooistDetailVCDriver = selectedItemInNormalMode
            .filter { _ in bookmarkModel.postType == .tattooist }
            .withLatestFrom(postItemsObservable) { ($0, $1) }
            .map { $1[$0].userId }
            .asDriver(onErrorJustReturn: -1)

        
        let postIndexInfo = selectedItemInEditMode
            .withLatestFrom(bookmarkModel.deleteIndexList) { ($0, $1) }
            .map { (
                findedPostIndex: $0.1.firstIndex(of: $0.0),
                postIndex: $0.0,
                deletePostIndexList: $0.1
            ) }
            .share()
        
        let indexThatShouldSetCount = postIndexInfo
            .filter { $0.findedPostIndex == nil }
            .map { _, postIndex, deletePostIndexList in
                var temp = deletePostIndexList
                temp.append(postIndex)
                bookmarkModel.deleteIndexList.accept(temp)
                return (postIndex, temp.count)
            }
        
        _ = indexThatShouldSetCount
            .withLatestFrom(postItems) { ($0.0, $0.1, $1) }
            .map { selectedIndex, count, cellViewModels in
                cellViewModels[selectedIndex].editCountRelay.accept(count)
                cellViewModels[selectedIndex].isSelectEditViewRelay.accept(true)
            }.subscribe()
            .disposed(by: disposeBag)
        
        let countDownAndDeleteInfo = postIndexInfo
            .filter { $0.findedPostIndex != nil }
            .map { index, postIndex, deletePostIndexList in
                guard let index else { return (-1, [-1]) } // 위에 필터링 했기 때문에 강제 언래핑 해도 상관 없습니다.
                var temp = deletePostIndexList
                temp.remove(at: index)
                bookmarkModel.deleteIndexList.accept(temp)
                let countDownIndexList = temp.enumerated().filter { i, value in i >= index }.map { $1 }
                return (postIndex, countDownIndexList)
            }
        
        _ = countDownAndDeleteInfo
            .withLatestFrom(postItems) { ($0.0, $0.1, $1) }
            .map { deletedIndex, countDownIndexList, cellViewModels in
                countDownIndexList.forEach {
                    guard let preValue = cellViewModels[$0].editCountRelay.value else { return }
                    cellViewModels[$0].editCountRelay.accept(preValue - 1)
                }
                cellViewModels[deletedIndex].isSelectEditViewRelay.accept(false)
            }.subscribe()
            .disposed(by: disposeBag)
        
        _ = bookmarkModel.editMode
            .withLatestFrom(postItems) { ($0, $1) }
            .bind { editMode, cellViewModels in
                if editMode == .normal {
                    cellViewModels.forEach {
                        $0.isSelectEditViewRelay.accept(false)
                    }
                }
                bookmarkModel.deleteIndexList.accept([])
            }.disposed(by: disposeBag)
        
        isEmptyDriver = postItems
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        emptyLabelTextDriver = .just(bookmarkModel.postType.asKorean())
            .asDriver(onErrorJustReturn: "error")
    }
    
    deinit {
        print("메모리 해제 잘되나 TEST, 북마크")
    }
}
