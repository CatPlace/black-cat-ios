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
    var selectNumber: String?

    var showing = PublishRelay<Bool>()

    let showEditView: Driver<Bool>

    init(imageURLString: String) {
        self.imageURLString = imageURLString

//        self.showing = hidden
        showEditView = showing
            .asDriver(onErrorJustReturn: true)
    }
}
