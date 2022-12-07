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
        let editingCellIndexToSelectNumberDict = BehaviorRelay<EditingCellIndexToSelectNumberDict>(value: [:])

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

        let isEditingCell = editingCellIndex
            .withLatestFrom(editingCellIndexToSelectNumberDict) { selectItemIndex, editingCellIndexToSelectNumberDict -> (shouldEdit: Bool, index: Int) in
                let isDictionaryContainsCellIndex = editingCellIndexToSelectNumberDict.contains { $0.key == selectItemIndex }

                return (shouldEdit: !isDictionaryContainsCellIndex, index: selectItemIndex)
            }
            .share()

        let addEditingCellIndex = isEditingCell
            .filter { $0.shouldEdit }
            .map { $0.index }

        let removeEditingCellIndex = isEditingCell
            .filter { !$0.shouldEdit }
            .map { $0.index }

        let observable = Observable
            .combineLatest(editingCellIndexToSelectNumberDict, cellViewModels)

        addEditingCellIndex
            .withLatestFrom(editingCellIndexToSelectNumberDict) { selectedItemIndex, editingCellDict in
                var dict = editingCellDict
                dict[selectedItemIndex] = dict.count + 1
                editingCellIndexToSelectNumberDict.accept(dict)
            }
            .subscribe { _ in () }
            .disposed(by: disposeBag)

        removeEditingCellIndex
            .withLatestFrom(observable) { editingCellIndex, observable in
                var dict = observable.0
                let targetNumber = dict[editingCellIndex, default: 0]
                observable.1[editingCellIndex].selectNumber.accept(0)
                dict[editingCellIndex] = nil
                dict.filter { $0.value > targetNumber }.forEach {
                    dict[$0.key] = $0.value - 1
                }

                editingCellIndexToSelectNumberDict.accept(dict)
            }
            .subscribe { _ in () }
            .disposed(by: disposeBag)

        editingCellIndexToSelectNumberDict
            .withLatestFrom(cellViewModels) { (dict: $0, cellViewModels: $1) }
            .subscribe { tuple in
                tuple.dict.forEach { tuple.cellViewModels[$0.key].selectNumber.accept($0.value) }
            }
            .disposed(by: disposeBag)

        Observable.merge([
            viewWillDisappear.asObservable(),
            refreshSelectedCells.asObservable()
        ])
            .withLatestFrom(observable) { _, observable in
                var dict = observable.0
                dict.forEach { observable.1[$0.key].selectNumber.accept(0) }
                dict.removeAll()
                editingCellIndexToSelectNumberDict.accept(dict)
            }
            .subscribe { _ in () }
            .disposed(by: disposeBag)

        tattooItems = bookmarkCellViewModelsWhenFirstLoad
            .asDriver(onErrorJustReturn: [])
    }
} 
