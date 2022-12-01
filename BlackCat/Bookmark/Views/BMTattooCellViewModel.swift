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
    var showing = PublishRelay<Bool>()

    let showEditView: Driver<Bool>
    let selectNumberText: Driver<String>

    init(imageURLString: String) {
        self.imageURLString = imageURLString

        showEditView = showing
            .asDriver(onErrorJustReturn: true)

        selectNumberText = selectNumber
            .debug("===Select Number===")
            .map { $0 == 0 ? "" : String($0) }
            .asDriver(onErrorJustReturn: "")
    }
}
