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
    let disposeBag = DisposeBag()

    //    let cellViewModels = PublishRelay<[BMTattooCellViewModel]>()
    let hidden = PublishRelay<Bool>()
    let viewDidLoad = PublishRelay<Void>()
    let editMode = PublishRelay<EditMode>()
    let decreaseSelectNumber = PublishRelay<Int>()
    let didSelectItem = PublishRelay<Int>()
    let selectedEditingCellIndexes = BehaviorRelay<Set<Int>>(value: [])

    let tattooItems: Driver<[BMTattooCellViewModel]>

    init() {
        let items = BehaviorRelay<[String]>(value: ["100", "200", "300", "400"])

        let editingCellIndexes = BehaviorRelay<Dictionary<Int, Int>>(value: [:])

        let cellViewModels = Observable.just([
            BMTattooCellViewModel(imageURLString: "100"),
            BMTattooCellViewModel(imageURLString: "200"),
            BMTattooCellViewModel(imageURLString: "300"),
            BMTattooCellViewModel(imageURLString: "400"),
        ])

        let firstTattooItems = viewDidLoad
            .withLatestFrom(cellViewModels)
            .debug("😀😀😀")

        let editingCellIndex = didSelectItem
            .withLatestFrom(editMode) { (index: $0, editMode: $1) }
            .filter { $0.editMode == .edit }
            .map { $0.index }

        let isEditingCell = editingCellIndex
            .withLatestFrom(editingCellIndexes) { selectItemIndex, editingCellDict -> (contains: Bool, index: Int) in
                let isDictionaryContainsItemIndex = editingCellDict.contains { $0.key == selectItemIndex }

                return (contains: !isDictionaryContainsItemIndex, index: selectItemIndex)
            }
            .share()

        let addEditingCellIndex = isEditingCell
            .filter { $0.contains }
            .map { $0.index }

        let removeEditingCellIndex = isEditingCell
            .filter { !$0.contains }
            .map { $0.index }

        let observable = Observable
            .combineLatest(editingCellIndexes, cellViewModels)

        addEditingCellIndex
            .debug("🤬🤬🤬🤬🤬 addEditingCellIndex 🤬🤬🤬🤬🤬")
            .withLatestFrom(editingCellIndexes) { selectedItemIndex, editingCellDict in
                var dict = editingCellDict
                dict[selectedItemIndex] = dict.count + 1
                editingCellIndexes.accept(dict)
            }
            .subscribe { _ in () }
            .disposed(by: disposeBag)

        removeEditingCellIndex
            .withLatestFrom(observable) { editingCellIndex, observable in
                var dict = observable.0
                var targetNumber = dict[editingCellIndex, default: 0]
                observable.1[editingCellIndex].selectNumber.accept(0)
                dict[editingCellIndex] = nil
                dict.filter { $0.value > targetNumber }.forEach {
                    dict[$0.key] = $0.value - 1
                }

                editingCellIndexes.accept(dict)
            }
            .subscribe { _ in () }
            .disposed(by: disposeBag)

        editingCellIndexes
            .withLatestFrom(cellViewModels) { (dict: $0, cellViewModels: $1) }
            .subscribe { tuple in
                tuple.dict.forEach { tuple.cellViewModels[$0.key].selectNumber.accept($0.value) }
            }
            .disposed(by: disposeBag)

        tattooItems = firstTattooItems
            .asDriver(onErrorJustReturn: [])
    }
}
