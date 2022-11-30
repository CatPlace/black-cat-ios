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
    let didSelectItem = PublishRelay<Int>()
    let selectedEditingCellIndexes = BehaviorRelay<Set<Int>>(value: [])

    let tattooItems: Driver<[BMTattooCellViewModel]>

    init() {
        let items = BehaviorRelay<[String]>(value: ["100", "200", "300", "400"])

        let editingCellIndexes = BehaviorRelay<Set<Int>>(value: [])

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
            .withLatestFrom(editMode) { ($0, $1) }
            .filter { $0.1 == .edit }
            .map { $0.0 }

        editingCellIndex
            .withLatestFrom(editingCellIndexes) { selectItemIndex, editingCellSet -> (Int, Int) in
                var a = editingCellSet
                a.insert(selectItemIndex)
                editingCellIndexes.accept(a)
                return (selectItemIndex, a.count)
            }
            .withLatestFrom(cellViewModels) { count, viewModels in
                return (count.1, viewModels[count.0])
            }
            .subscribe { $0.1.selectNumber.accept($0.0) }
            .disposed(by: disposeBag)

//        didSelectItem
//            .withLatestFrom(firstTattooItems) { index, items in
//
//                return (index, items)
//            }
//            .do { $0.1[1].selectNumber = $0.0 }

//        let selectedEditingCellIndex = didSelectItem
//            .withLatestFrom(editMode) { ($0, $1) }
//            .filter { $0.1 == .edit }
//            .map { $0.0 }
//            .do { print($0) }
//        //            .do { row in a(row: row) }
//
//        selectedEditingCellIndex
//            .withLatestFrom(firstTattooItems) { ($0, $1) }
//            .do { $0.1[$0.0].selectNumber.accept(5) }
//            .bind { $0.1[$0.0].selectNumber.accept(5) }
//            .disposed(by: disposeBag)

//        func a(row: Int) {
//            var prevSet = editingCellIndexes.value
//            if prevSet.contains(row) {
//                prevSet.remove(row)
//            } else {
//                prevSet.insert(row)
//            }
//            editingCellIndexes.accept(prevSet)
//        }

        //        let reloadItemsByEditing = selectedEditingCellIndex
        //            .withLatestFrom(selectedEditingCellIndexes) { row, cellIndexes in
        //                var newCellIndexes = cellIndexes
        //                if newCellIndexes.contains(where: { $0 == row }) {
        //                    newCellIndexes.append(row)
        //                } else {
        //                    newCellIndexes.remove(at: cellIndexes.firstIndex(of: row)!)
        //                }
        //                self.selectedEditingCellIndexes.accept(newCellIndexes)
        //            }

        //            .withLatestFrom(firstTattooItems) { row, items -> [BMTattooCellViewModel] in
        //                var newItems = items
        //                print("====before NewItems: \(newItems)")
        //                let newCellViewModel = BMTattooCellViewModel(imageURLString: "")
        //                newCellViewModel.selectNumber = "\(row!)"
        //                newItems.enumerated().forEach { index, cellViewModel in
        //                    if index == row {
        //                        newItems[row!] = newCellViewModel
        //                    } else {
        //                        cellViewModel.selectNumber = nil
        //                    }
        //                }
        //                print("====After NewItems: \(newItems)")
        //
        //                return newItems
        //            }

        tattooItems = Observable.merge([
            firstTattooItems,
//            relaodBySelectItem
        ]).asDriver(onErrorJustReturn: [])
    }
}
