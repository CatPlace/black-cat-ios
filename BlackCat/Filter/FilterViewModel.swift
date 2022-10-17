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
    
    // MARK: - Output
    let taskDriver: Driver<[FilterTask]>
    let locationDriver: Driver<[FilterLocation]>
    
//    let taskItemReloadDriver: Driver<IndexPath>
    
//    let realmService
    // MARK: - Initialize
    init(provider: FilterService = FilterService()) {
        // 초기화할때 값 모두 저장
        provider.loadSavedData()
        
        let tasks = provider.all
        
        taskDriver = tasks
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

//public class FilterService {
//    var all = PublishSubject<[FilterTask]>()
//
//    func add(task: FilterTask) {
//        guard write(task: task) else { return }
//
////        all.append(task)
//    }
//
//    func loadSavedData() {
//        DispatchQueue.global().async {
//            guard let realm = self.getRealm() else { return }
//
//            let allType = FilterTask.TaskType.allCases
//
//            let result = allType.map { type -> FilterTask in
//                self.buildFilterTask(type: type)
//            }
//
//            result.forEach { task in
//                self.write(task: task)
//            }
//
//            let objects = realm.objects(FilterTask.self)
//            print("objects \(objects)")
//
//            DispatchQueue.global().sync {
//                self.all.onNext(Array(objects))
//            }
//
//        }
//    }
//
//    func buildFilterTask(type :FilterTask.TaskType) -> FilterTask {
//        FilterTask(type: type, isSubscribe: false)
//    }
//
//    @discardableResult
//    private func write(task: FilterTask) -> Bool {
//        realmWrite { realm in
//            realm.add(task, update: .modified)
//        }
//    }
//
//    private func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool {
//        guard let realm = getRealm() else { return false }
//
//        // realm 파일위치
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
//
//        do {
//            try realm.write { operation(realm) }
//        }
//        catch let error as NSError {
//            print(error.localizedDescription)
//            return false
//        }
//
//        return true
//    }
//
//    private func getRealm() -> Realm? {
//        do {
//            return try Realm()
//        }
//        catch let error as NSError {
//            print(error.localizedDescription)
//            return nil
//        }
//    }
//}
