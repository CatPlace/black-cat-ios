//
//  FilterLoactionService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation
import RxSwift

protocol FilterLoactionServiceProtocol {
    func fetch() -> Observable<[FilterLocation]>
    func update(location: FilterLocation) -> Observable<[FilterLocation]>
}

final class FilterLoactionService: BaseRealmProtocol, FilterLoactionServiceProtocol {
    
    init() {
        saveAllData()
    }

    func fetch() -> Observable<[FilterLocation]> {
        guard let realm = self.getRealm() else { return .empty() }

        let locations = Array(realm.objects(FilterLocation.self))
        return Observable.just(locations)
    }

    func update(location: FilterLocation) -> Observable<[FilterLocation]> {
        realmWrite { realm in
            location.isSubscribe = !location.isSubscribe
        }

        return fetch()
    }
    
    fileprivate func write(task: FilterTask) {
        realmWrite { realm in
            realm.add(task ,update: .modified)
        }
    }
    
    /// 값을 처음에 저장해야합니다.
    fileprivate func saveAllData() {
        print("탯ㅌ")
        guard let realm = self.getRealm() else { return }
        
        let keys = Array(realm.objects(FilterTask.self))
            .map { $0.type.rawValue }
        
        FilterTask.TaskType.allCases.map { $0.rawValue }
            .filter { !keys.contains($0) }
            .forEach { key in
//                self.write(task: FilterTask(type: type))
            }
    }
}
