//
//  BookmarkTattooViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import Foundation

import BlackCatSDK
import RxCocoa
import RxSwift

class BookmarkTattooViewModel {
    typealias CellIndex = Int
    typealias SelectNumber = Int
    typealias EditingCellIndexToSelectNumberDict = Dictionary<CellIndex, SelectNumber>

    let disposeBag = DisposeBag()

    // MARK: - Input

    let hidden = PublishRelay<Bool>()
    let viewDidLoad = PublishRelay<Void>()
    let viewWillDisappear = PublishRelay<Void>()
    let refreshSelectedCells = PublishRelay<Void>()

    // MARK: - Output

    let didTapEditButton = BehaviorRelay<EditMode>(value: .normal)
    let editMode = BehaviorRelay<EditMode>(value: .normal)
    let didSelectItem = PublishRelay<Int>()
    let selectedEditingCellIndexes = BehaviorRelay<Set<Int>>(value: [])

    let tattooItems: Driver<[BMCellViewModel]>

    init() {
        let editingCellManagingDict = BehaviorRelay<EditingCellIndexToSelectNumberDict>(value: [:])

        let cellViewModels = Observable.just(UserDefaultManager.bookmarkedTattoo
            .map { BMCellViewModel(imageURLString: $0.imageURLStrings.first ?? "") }
        )

        let bookmarkCellViewModelsWhenFirstLoad = viewDidLoad
            .withLatestFrom(cellViewModels)

        let editModeWhenItemSelected = didSelectItem
            .withLatestFrom(didTapEditButton) { (index: $0, editMode: $1) }
            .share()

        let cellIndexForEdit = editModeWhenItemSelected
            .filter { $0.editMode == .edit }
            .map { $0.index }

        let cellIndexForPush = editModeWhenItemSelected
            .filter { $0.editMode == .normal }
            .map { $0.index }

        let cellShouldBeEdited = cellIndexForEdit
            .withLatestFrom(editingCellManagingDict) { selectItemIndex, editingCellIndexToSelectNumberDict -> (shouldEdit: Bool, index: Int) in
                let isDictionaryContainsCellIndex = editingCellIndexToSelectNumberDict.contains { $0.key == selectItemIndex }

                return (shouldEdit: !isDictionaryContainsCellIndex, index: selectItemIndex)
            }
            .share()

        let cellIndexShouldBeAddInManagingDict = cellShouldBeEdited
            .filter { $0.shouldEdit }
            .map { $0.index }

        let cellIndexShouldBeRemoveFromManagingDict = cellShouldBeEdited
            .filter { !$0.shouldEdit }
            .map { $0.index }

        cellIndexShouldBeAddInManagingDict
            .withLatestFrom(editingCellManagingDict) { selectedItemIndex, editingCellDict in
                var dict = editingCellDict
                dict[selectedItemIndex] = dict.count + 1
                editingCellManagingDict.accept(dict)
            }
            .subscribe { _ in () }
            .disposed(by: disposeBag)

        cellIndexShouldBeRemoveFromManagingDict
            .withLatestFrom(editingCellManagingDict) { selectedCellIndex, editingCellDict -> Int in
                var dict = editingCellDict
                let selectNumber = dict[selectedCellIndex, default: 0]
                dict[selectedCellIndex] = nil
                dict.filter { $0.value > selectNumber }.forEach { dict[$0.key] = $0.value - 1 }
                editingCellManagingDict.accept(dict)
                return selectedCellIndex
            }
            .withLatestFrom(cellViewModels) { selectedCellIndex, cellViewModels in
                removeSelectNumber(from: cellViewModels[selectedCellIndex])
            }
            .subscribe()
            .disposed(by: disposeBag)

        editingCellManagingDict
            .withLatestFrom(cellViewModels) { (dict: $0, cellViewModels: $1) }
            .subscribe { returned in
                returned.dict.forEach { returned.cellViewModels[$0.key].selectNumber.accept($0.value) }
            }
            .disposed(by: disposeBag)

        let bookmarkCellViewModelsAfterEdited = didTapEditButton
            .filter { $0 == .normal }
            .withLatestFrom(editingCellManagingDict)
            .filter { $0.count != 0 }
            .do { editingCellDict in
                var dict = editingCellDict
                dict.forEach { cellIndex, _ in
                    UserDefaultManager.bookmarkedTattoo.remove(at: cellIndex)
                    dict[cellIndex] = nil
                }
                editingCellManagingDict.accept(dict)
            }
            .flatMap{ _ in
                Observable.just(UserDefaultManager.bookmarkedTattoo
                    .map { BMCellViewModel(imageURLString: $0.imageURLStrings.first ?? "") } )
            }

        Observable.merge([
            viewWillDisappear.asObservable(),
            refreshSelectedCells.asObservable()
        ])
        .withLatestFrom(Observable.combineLatest(editingCellManagingDict, cellViewModels)) {
            var dict = $1.0
            let cellViewModels = $1.1
            dict.forEach { cellIndex, _ in
                removeSelectNumber(from: cellViewModels[cellIndex])
                dict[cellIndex] = nil
            }
            editingCellManagingDict.accept(dict)
        }
            .subscribe()
            .disposed(by: disposeBag)

        tattooItems = Observable.merge([
            bookmarkCellViewModelsWhenFirstLoad,
            bookmarkCellViewModelsAfterEdited
        ])
            .asDriver(onErrorJustReturn: [])

        func removeSelectNumber(from viewModel: BMCellViewModel) {
            print(viewModel)
            viewModel.selectNumber.accept(0)
        }
    }
}
