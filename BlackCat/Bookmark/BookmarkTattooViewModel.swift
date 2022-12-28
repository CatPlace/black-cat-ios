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

        let cellViewModels = BehaviorSubject<[BMCellViewModel]>(value: UserDefaultManager.bookmarkedTattoo
            .map { BMCellViewModel(imageURLString: $0.imageURLStrings.first ?? "") } )

        let bookmarkCellViewModelsWhenFirstLoad = viewDidLoad
            .withLatestFrom(cellViewModels)

        let editModeWhenItemSelected = didSelectItem
            .withLatestFrom(editMode) { (index: $0, editMode: $1) }
            .share()

        let cellIndexForEdit = editModeWhenItemSelected
            .filter { $0.editMode == .edit }
            .map { $0.index }

        let cellIndexForPush = editModeWhenItemSelected
            .filter { $0.editMode == .normal }
            .map { $0.index }

        let cellShouldBeEdited = cellIndexForEdit
            .debug("🥵🥵🥵🥵🥵🥵 CellIndexForEdit 🥵🥵🥵🥵🥵🥵")
            .withLatestFrom(editingCellManagingDict) {
                selectItemIndex, editingCellManagingDict -> (shouldEdit: Bool, index: Int) in
                let isDictionaryContainsCellIndex = editingCellManagingDict.contains { $0.key == selectItemIndex }

                return (shouldEdit: !isDictionaryContainsCellIndex, index: selectItemIndex)
            }
            .share()

        let cellIndexShouldBeAddInManagingDict = cellShouldBeEdited
            .filter { $0.shouldEdit }
            .map { $0.index }

        let cellIndexShouldBeRemoveFromManagingDict = cellShouldBeEdited
            .filter { !$0.shouldEdit }
            .map { $0.index }

        let removeSelectedItem = didTapEditButton
            .filter { $0 == .normal }
            .withLatestFrom(editingCellManagingDict)
            .filter { !$0.isEmpty }
            .share()

        let bookmarkCellViewModelsAfterSelecedItemRemove = removeSelectedItem
            .do { editingCellDict in
                var dict = editingCellDict
                dict.sorted { $0.key > $1.key }.forEach { cellIndex, _ in
                    UserDefaultManager.bookmarkedTattoo.remove(at: cellIndex)
                    dict[cellIndex] = nil
                }
                editingCellManagingDict.accept(dict)
            }
            .do { _ in
                cellViewModels.onNext(UserDefaultManager.bookmarkedTattoo
                    .map { BMCellViewModel(imageURLString: $0.imageURLStrings.first ?? "") } )
            }
            .withLatestFrom(cellViewModels)

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
                print("🥶🥶🥶🥶🥶🥶 dict.values", returned.dict.keys)
                print("cellViewModel.count", returned.cellViewModels.count)
                returned.dict.forEach { returned.cellViewModels[$0.key].selectNumber.accept($0.value) }
            }
            .disposed(by: disposeBag)

        // TODO: - 셀 지우고 초기화 해줘야함!

        Observable.merge([
            viewWillDisappear.asObservable(),
            refreshSelectedCells.asObservable()
        ])
        .withLatestFrom(Observable.combineLatest(editingCellManagingDict, cellViewModels)) {
            var dict = $1.0
            let cellViewModels = $1.1
            dict.forEach { cellIndex, _ in
                dict[cellIndex] = nil
            }
            cellViewModels.forEach { removeSelectNumber(from: $0) }
            editingCellManagingDict.accept(dict)
        }
            .subscribe()
            .disposed(by: disposeBag)

        tattooItems = Observable.merge([
            bookmarkCellViewModelsWhenFirstLoad,
            bookmarkCellViewModelsAfterSelecedItemRemove
        ])
        .debug("🥵🥵🥵🥵🥵🥵 CellIndexForEdit 🥵🥵🥵🥵🥵🥵")
            .asDriver(onErrorJustReturn: [])

        func removeSelectNumber(from viewModel: BMCellViewModel) {
            print(viewModel)
            viewModel.selectNumber.accept(0)
        }
    }
}
