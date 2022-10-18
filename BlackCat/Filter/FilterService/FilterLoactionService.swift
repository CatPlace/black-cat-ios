//
//  FilterLoactionService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation
import RxSwift

protocol FilterLocationServiceProtocol {
    func fetch() -> Observable<[FilterLocation]>
    func update(location: FilterLocation) -> Observable<[FilterLocation]>
}

final class FilterLoactionService: BaseRealmProtocol, FilterLocationServiceProtocol {
    
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
    
    fileprivate func write(location: FilterLocation) {
        realmWrite { realm in
            realm.add(location ,update: .modified)
        }
    }
    
    /// 값을 처음에 저장해야합니다.
    fileprivate func saveAllData() {
        guard let realm = self.getRealm() else { return }
        let keys = Array(realm.objects(FilterLocation.self))
            .map { $0.type.rawValue }
        
        FilterLocation.LocationType.allCases.map { $0.rawValue }
            .filter { !keys.contains($0) }
            .forEach { typeString in
                let location = FilterLocation(type: FilterLocation.LocationType(rawValue: typeString) ?? .서울)
                self.write(location: location)
            }
    }
}
