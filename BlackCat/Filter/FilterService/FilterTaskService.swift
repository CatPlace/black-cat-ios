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
    func recoverLastState(tasks: [FilterTask], mementoTasks: [FilterTask])
    
    func createMemento() -> [MementoFilterTask]
}

final class FilterTaskService: BaseRealmProtocol, FilterTaskServiceProtocol {
    
    init() {
        saveAllData()
    }
    
    /// 로컬 디바이스에서 filterTask를 fetch합니다.
    func fetch() -> Observable<[FilterTask]> {
        guard let realm = self.getRealm() else { return .empty() }
        
        let tasks = Array(realm.objects(FilterTask.self))
        return Observable.just(tasks)
    }
    
    /// 로컬 디바이스에 저장된 값과 recover할 값의 싱크릴 맞춥니다.
    func createMemento() -> [MementoFilterTask] {
        guard let realm = self.getRealm() else { return [] }
        
        let tasks = Array(realm.objects(FilterTask.self))
        let recoverTasks = Array(realm.objects(MementoFilterTask.self))
        
        zip(recoverTasks, tasks).forEach { (recoverTask, task) in
            
            realmWrite { realm in
                recoverTask.isSubscribe = task.isSubscribe
            }
        }
        
        return recoverTasks
    }
    
    /// itemSelected시 상태를 업데이트 합니다.
    @discardableResult
    func update(task: FilterTask) -> Observable<[FilterTask]> {
        realmWrite { realm in
            task.isSubscribe = !task.isSubscribe
        }
        
        return fetch()
    }
    
    /// 필터 저장을 누르지 않을시, recover를 수행합니다.
    func recoverLastState(tasks: [FilterTask], mementoTasks: [FilterTask]) {
        zip(tasks, mementoTasks).forEach { (task, recoverTask) in
            
            realmWrite { realm in
                task.isSubscribe = recoverTask.isSubscribe
            }
        }
    }
    
    // MARK: - Function 내부에서만 사용
    
    fileprivate func write(task: FilterTask) {
        realmWrite { realm in
            realm.add(task ,update: .modified)
        }
    }
    
    fileprivate func mementoWrite(mementoTask: MementoFilterTask) {
        realmWrite { realm in
            realm.add(mementoTask ,update: .modified)
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
                
                let mementoTask = MementoFilterTask(type: FilterTask.TaskType(rawValue: typeString) ?? .작품)
                self.mementoWrite(mementoTask: mementoTask)
            }
    }
}

class MementoFilterTask: FilterTask { }
