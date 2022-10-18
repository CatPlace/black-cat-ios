//
//  FilterService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation
import RxSwift

protocol FilterTaskServiceProtocol {
    func fetch() -> Observable<[FilterTask]>
    func update(task: FilterTask) -> Observable<[FilterTask]>
}

final class FilterTaskService: BaseRealmProtocol, FilterTaskServiceProtocol {
    
    func fetch() -> Observable<[FilterTask]> {
        guard let realm = self.getRealm() else { return .empty() }
        
        let tasks = Array(realm.objects(FilterTask.self))
        return Observable.just(tasks)
    }
    
    func update(task: FilterTask) -> Observable<[FilterTask]> {
        realmWrite { realm in
            task.isSubscribe = !task.isSubscribe
        }
        
        return fetch()
    }
}
