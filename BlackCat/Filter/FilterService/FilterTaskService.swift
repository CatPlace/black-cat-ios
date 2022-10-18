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
    func executeRevert(tasks: [FilterTask], revertTasks: [FilterTask])
    
    func fetchRevert() -> [RevertFilterTask]
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
    
    /// 로컬 디바이스에 저장된 값과 revert할 값의 싱크릴 맞춥니다.
    func fetchRevert() -> [RevertFilterTask] {
        guard let realm = self.getRealm() else { return [] }
        
        let tasks = Array(realm.objects(FilterTask.self))
        let revertTasks = Array(realm.objects(RevertFilterTask.self))
        
        zip(revertTasks, tasks).forEach { (revertTask, task) in
            
            realmWrite { realm in
                revertTask.isSubscribe = task.isSubscribe
            }
        }
        
        return revertTasks
    }
    
    /// itemSelected시 상태를 업데이트 합니다.
    @discardableResult
    func update(task: FilterTask) -> Observable<[FilterTask]> {
        realmWrite { realm in
            task.isSubscribe = !task.isSubscribe
        }
        
        return fetch()
    }
    
    /// 필터 저장을 누르지 않을시, revert를 수행합니다.
    func executeRevert(tasks: [FilterTask], revertTasks: [FilterTask]) {
        zip(tasks, revertTasks).forEach { (task, revertTask) in
            
            realmWrite { realm in
                task.isSubscribe = revertTask.isSubscribe
            }
        }
    }
    
    // MARK: - Function 내부에서만 사용
    
    fileprivate func write(task: FilterTask) {
        realmWrite { realm in
            realm.add(task ,update: .modified)
        }
    }
    
    fileprivate func revertWrite(revertTask: RevertFilterTask) {
        realmWrite { realm in
            realm.add(revertTask ,update: .modified)
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
                
                let revertTask = RevertFilterTask(type: FilterTask.TaskType(rawValue: typeString) ?? .작품)
                self.revertWrite(revertTask: revertTask)
            }
    }
}

/// Revert를 시도하기 위한 클래스
class RevertFilterTask: FilterTask { }
