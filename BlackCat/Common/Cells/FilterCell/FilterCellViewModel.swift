//
//  FilterCellViewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/09.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - FilterCellViewModel
final class FilterCellViewModel {
    let color: UIColor?
    let typeStringDriver: Driver<String>
    let isSubscribeDriver: Driver<Bool>

    init(color: UIColor?, typeString: String, isSubscribe: Bool) {
        self.color = color
        
        typeStringDriver = Observable.just(typeString)
            .map { $0 }
            .asDriver(onErrorJustReturn: "")
        
        isSubscribeDriver = Observable.just(isSubscribe)
            .asDriver(onErrorJustReturn: false)
    }
}
