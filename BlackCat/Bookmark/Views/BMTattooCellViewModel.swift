//
//  BMTattooCellViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import Foundation

import RxCocoa
import RxSwift

protocol cellEditable {
    var showing: PublishRelay<Bool> { get }
    var showEditView: Driver<Bool> { get }
}

class BMTattooCellViewModel: cellEditable {
    var imageURLString: String
    var selectNumber = PublishRelay<Int>()
    var decreaseSelectNumber = PublishRelay<Void>()
    var showing = PublishRelay<Bool>()

    let showEditView: Driver<Bool>
    let selectNumberText: Driver<String>

    init(imageURLString: String) {
        self.imageURLString = imageURLString

        showEditView = showing
            .asDriver(onErrorJustReturn: true)

        let currentSelectNumber = selectNumber

        let decreasedCurrentSelectNumber = selectNumber
            .withLatestFrom(decreaseSelectNumber) { currentNumber, _ in
                return currentNumber - 1
            }

        selectNumberText = Observable.merge([
            currentSelectNumber.asObservable(),
            decreasedCurrentSelectNumber
        ])
            .debug("===Select Number===")
            .map { String($0) }
            .asDriver(onErrorJustReturn: "")
    }
}
