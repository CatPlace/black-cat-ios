//
//  FilterViewModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import ReactorKit

final class FilterViewModel {
    
    // MARK: - Input
    let taskItemSelectedSubject = PublishSubject<IndexPath>()
    let taskModelSelectedSubject = PublishSubject<FilterTask>()
    
    // MARK: - Output
    let taskDriver: Driver<[FilterTask]>
    let locationDriver: Driver<[FilterLocation]>
    
    let taskItemReloadDriver: Driver<IndexPath>
    
//    let realmService
    // MARK: - Initialize
    init(provider: FilterService = FilterService()) {
        
        let tasks = provider.fetch()
        
        taskDriver = Observable.just(tasks)
            .asDriver(onErrorJustReturn: [])
        
        let loactions = FilterLocationType.allCases
            .map { item -> FilterLocation in
                FilterLocation(item: item, isSubscribe: false)
            }
        locationDriver = Observable.just(loactions)
            .asDriver(onErrorJustReturn: [])
    }
}

final class FilterService {
    @UserDefault(key: "filterTasks", defaultValue: nil, storage: .standard)
    var tasks: [FilterTask]?
    
    func fetch() {
        
    }
}
