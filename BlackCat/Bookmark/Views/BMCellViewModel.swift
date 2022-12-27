//
//  BMTattooCellViewModel.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/18.
//

import Foundation

import RxCocoa
import RxSwift

struct BMCellViewModel {
    var imageURLString: String
    var selectNumber = PublishRelay<Int>()
    var editModeIsNormal = PublishRelay<Bool>()

    let shouldHideEditView: Driver<Bool>
    let selectNumberText: Driver<String>

    init(imageURLString: String) {
        self.imageURLString = imageURLString

        shouldHideEditView = editModeIsNormal
            .debug("ShouldHideEditView")
            .asDriver(onErrorJustReturn: true)

        selectNumberText = selectNumber
            .map { $0 == 0 ? "" : String($0) }
            .asDriver(onErrorJustReturn: "")
    }
}
