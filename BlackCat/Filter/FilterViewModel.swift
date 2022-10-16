//
//  FilterViewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import UIKit
import RxSwift
import RxCocoa

class FilterViewModel {
    
    // MARK: - Input
    let taskItemSelectedSubject = PublishSubject<IndexPath>()
    
    // MARK: - Output
    let taskDriver: Driver<[FilterTask]>
    let locationDriver: Driver<[FilterLocation]>
    
//    let taskItemReloadDriver: Driver<IndexPath>
    // MARK: - Initialize
    init() {
        let tasks = FilterTaskType.allCases
            .map { item -> FilterTask in
                FilterTask(type: item, isSubscribe: false)
            }
        
        taskDriver = Observable.just(tasks)
            .asDriver(onErrorJustReturn: [])
        
        let loactions = FilterLocationType.allCases
            .map { item -> FilterLocation in
                FilterLocation(item: item, isSubscribe: false)
            }
        locationDriver = Observable.just(loactions)
            .asDriver(onErrorJustReturn: [])
        
//        taskItemReloadDriver = taskItemSelectedSubject
//            .map(<#T##transform: (IndexPath) throws -> Result##(IndexPath) throws -> Result#>)
        
    }
}
