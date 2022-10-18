//
//  FilterService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation
import RxSwift
import RealmSwift

protocol FilterTaskServiceProtocol {
    func fetch() -> Observable<[FilterTask]>
    func update(task: FilterTask) -> Observable<[FilterTask]>
    func revert(tasks: [FilterTask], revertTasks: [FilterTask])
    
    func fetchRevert() -> [RevertFilterTask]
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
    
    func fetchRevert() -> [RevertFilterTask] {
        /*
         💡 fetchRevert Idea
         1. 새로운 relation 만들기
         2. 임시 스레드를 새로 열어서 싱크 맞추는 것을 막기
         */
        
        guard let realm = self.getRealm() else { return [] }
        
        let tasks = Array(realm.objects(FilterTask.self))
        var revertTasks = Array(realm.objects(RevertFilterTask.self))
        
        print("✅ \(tasks)")
        print("❌ \(revertTasks)")
        
        zip(revertTasks, tasks).forEach { item in
            realmWrite { realm in
                var item = item
                var a = item.0
//                a.type = item.1.type
                a.isSubscribe = item.1.isSubscribe
            }
        }
        
        print("✅❌ \(revertTasks)")
        return revertTasks
    }
    
    @discardableResult
    func update(task: FilterTask) -> Observable<[FilterTask]> {
        realmWrite { realm in
            task.isSubscribe = !task.isSubscribe
        }
        
        return fetch()
    }
    
    func revert(tasks: [FilterTask], revertTasks: [FilterTask]) {
        zip(tasks, revertTasks).forEach { item in
            realmWrite { realm in
                var item = item
                item.0 = item.1
            }
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

class RevertFilterTask: FilterTask { }
