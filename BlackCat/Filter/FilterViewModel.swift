//
//  FilterViewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import Foundation
import RxSwift
import RxCocoa

class FilterViewModel {
    
    // MARK: - Input
    
    // MARK: - Output
    let taskDriver: Driver<[String]>
    
    // MARK: - Initialize
    init() {
        taskDriver = Observable.from(optional: ["작업", "도안"])
            .asDriver(onErrorJustReturn: [])
    }
}
