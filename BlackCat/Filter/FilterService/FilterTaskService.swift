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
    func revert(tasks: [FilterTask]) 
}

final class FilterTaskService: BaseRealmProtocol, FilterTaskServiceProtocol {
    
    init() {
        saveAllData()
    }
    
    func fetch() -> Observable<[FilterTask]> {
        guard let realm = self.getRealm() else { return .empty() }
        
        let tasks = Array(realm.objects(FilterTask.self))
        return Observable.just(tasks)
    }
    
    @discardableResult
    func update(task: FilterTask) -> Observable<[FilterTask]> {
        realmWrite { realm in
            task.isSubscribe = !task.isSubscribe
        }
        
        return fetch()
    }
    
    func revert(tasks: [FilterTask]) {
        tasks.forEach { task in
            update(task: task)
        }
    }
    
    fileprivate func write(task: FilterTask) {
        realmWrite { realm in
            realm.add(task ,update: .modified)
        }
    }
    
    /// 값을 처음에 저장해야합니다.
    fileprivate func saveAllData() {
        guard let realm = self.getRealm() else { return }
        let keys = Array(realm.objects(FilterTask.self))
            .map { $0.type.rawValue }
        
        FilterTask.TaskType.allCases.map { $0.rawValue }
            .filter { !keys.contains($0) }
            .forEach { typeString in
                let task = FilterTask(type: FilterTask.TaskType(rawValue: typeString) ?? .작품)
                self.write(task: task)
            }
    }
}
