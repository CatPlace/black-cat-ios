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
        
        taskItemReloadDriver = Observable.zip(taskModelSelectedSubject, taskItemSelectedSubject)
            .do(onNext: { (task, indexPath) in
                provider.update(task: task)
            })
                .map { (task, indexPath) -> IndexPath in
                    return indexPath
                }
            .asDriver(onErrorJustReturn: IndexPath(row: 0, section: 0))
    }
}

class FilterService {
    private let realm = try! Realm()

    init() {
        let tasks = FilterTask.TaskType.allCases
            .map { type -> FilterTask in
                FilterTask(type: type, isSubscribe: false)
            }
        
        tasks.forEach { task in
            self.write(task: task)
        }
        
        print("값 저장 성공")
    }
    
    func fetch() -> [FilterTask] {
        Array(realm.objects(FilterTask.self))
    }
    
    func update(task: FilterTask) {
        task.isSubscribe = !task.isSubscribe
        self.write(task: task)
    }
    
    private func getRealm() -> Realm? {
        do {
            return try Realm()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func write(task: FilterTask) -> Bool {
        realmWrite { realm in
            realm.add(task, update: .modified)
        }
    }
    
    private func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool {
        guard let realm = getRealm() else { return false }
        
        // realm 파일위치
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        do {
            try realm.write { operation(realm) }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return false
        }

        return true
    }
}
