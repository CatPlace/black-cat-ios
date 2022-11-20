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
    //    let hidden = PublishRelay<Bool>()
    let viewDidLoad = PublishRelay<Void>()
    let editMode = PublishRelay<EditMode>()
    let didSelectItem = PublishRelay<Int>()
    let selectedEditingCellIndexes = BehaviorRelay<[Int]>(value: [])

    let tattooItems: Driver<[BMTattooCellViewModel]>

    init() {
        let hiddenRelay = PublishRelay<Bool>()
        //        self.cellViewModel = cellViewModel
        let items = BehaviorRelay<[String]>(value: ["1", "2", "3", "4"])
        let editingCellIndexes = BehaviorRelay<[Int]>(value: [])

        let firstTattooItems = viewDidLoad
            .withLatestFrom(items)
            .map { $0.map { dummy -> BMTattooCellViewModel in
                    let viewModel = BMTattooCellViewModel(imageURLString: dummy)
                    viewModel.showing = hiddenRelay

                    return viewModel }
            }
        //            .map { _ -> [BMTattooCellViewModel] in
        //                let viewModel = BMTattooCellViewModel(imageURLString: "A", hidden: hiddenRelay)
        ////                viewModel.showing = hiddenRelay
        //
        //                return Array(repeating: viewModel, count: 23)
        //            }

        let editMode = editMode
            .share()

        editMode
            .map { $0 != .edit }
            .debug("asd")
        //            .map { editMode in editMode == .edit ? false : true }
            .bind(to: hiddenRelay)
            .disposed(by: disposeBag)

        //        let selectedEditingCellIndex = didSelectItem
        //            .withLatestFrom(editMode) { row, editMode -> Int in
        //                if editMode == .edit { return row }
        //            }

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
            //            reloadItemsByEditing,
        ]).asDriver(onErrorJustReturn: [])
    }
}
