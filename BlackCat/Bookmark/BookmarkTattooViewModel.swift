//
//  BookmarkTattooViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import Foundation

import RxCocoa
import RxSwift

class BookmarkTattooViewModel {
    typealias EditingCellIndexToSelectNumberDict = Dictionary<Int, Int>

    let disposeBag = DisposeBag()

    // MARK: - Input

    let hidden = PublishRelay<Bool>()
    let viewDidLoad = PublishRelay<Void>()
    let viewWillDisappear = PublishRelay<Void>()
    let refreshSelectedCells = PublishRelay<Void>()

    // MARK: - Output

    let editMode = PublishRelay<EditMode>()
    let didSelectItem = PublishRelay<Int>()
    let selectedEditingCellIndexes = BehaviorRelay<Set<Int>>(value: [])

    let tattooItems: Driver<[BMCellViewModel]>

    init() {
        let editingCellManagingDict = BehaviorRelay<EditingCellIndexToSelectNumberDict>(value: [:])

        let cellViewModels = Observable.just([
            BMCellViewModel(imageURLString: "100"),
            BMCellViewModel(imageURLString: "200"),
            BMCellViewModel(imageURLString: "300"),
            BMCellViewModel(imageURLString: "400"),
        ])

        let bookmarkCellViewModelsWhenFirstLoad = viewDidLoad
            .withLatestFrom(cellViewModels)

        let editingCellIndex = didSelectItem
            .withLatestFrom(editMode) { (index: $0, editMode: $1) }
            .filter { $0.editMode == .normal }
            .map { $0.index }

        let cellShouldBeEdited = editingCellIndex
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
            .subscribe { _ in () }
            .disposed(by: disposeBag)

        editingCellManagingDict
            .withLatestFrom(cellViewModels) { (dict: $0, cellViewModels: $1) }
            .subscribe { returned in
                returned.dict.forEach { returned.cellViewModels[$0.key].selectNumber.accept($0.value) }
            }
            .disposed(by: disposeBag)

        Observable.merge([
            viewWillDisappear.asObservable(),
            refreshSelectedCells.asObservable()
        ])
        .withLatestFrom(Observable.combineLatest(editingCellManagingDict, cellViewModels)) {
            let dict = $1.0
            let cellViewModels = $1.1
            dict.forEach { removeSelectNumber(from: cellViewModels[$0.key]) }
            editingCellManagingDict.accept(dict)
        }
            .subscribe { _ in () }
            .disposed(by: disposeBag)

        tattooItems = bookmarkCellViewModelsWhenFirstLoad
            .asDriver(onErrorJustReturn: [])

        func removeSelectNumber(from viewModel: BMCellViewModel) {
            viewModel.selectNumber.accept(0)
        }
    }
}
