//
//  FilterCellViewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/09.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - FilterCellViewModel
final class FilterCellViewModel {
    let typeStringDriver: Driver<String>
    let isSubscribeDriver: Driver<Bool>

    init(typeString: String, isSubscribe: Bool) {
        typeStringDriver = Observable.just(typeString)
            .map { $0 }
            .asDriver(onErrorJustReturn: "")
        
        isSubscribeDriver = Observable.just(isSubscribe)
            .asDriver(onErrorJustReturn: false)
    }
}
