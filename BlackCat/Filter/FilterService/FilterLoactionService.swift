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
    func recoverLastState(locations: [FilterLocation], mementoLocations: [FilterLocation])
    
    func createMemento() -> [MementoFilterLocation]
}

final class FilterLoactionService: BaseRealmProtocol, FilterLocationServiceProtocol {
    
    init() {
        saveAllData()
    }

    /// 로컬 디바이스에서 filterLocation를 fetch합니다.
    func fetch() -> Observable<[FilterLocation]> {
        guard let realm = self.getRealm() else { return .empty() }

        let locations = Array(realm.objects(FilterLocation.self))
        return Observable.just(locations)
    }
    
    /// 로컬 디바이스에 저장된 값과 recover할 값의 싱크를 맞춥니다.
    func createMemento() -> [MementoFilterLocation] {
        guard let realm = self.getRealm() else { return [] }
        
        let locations = Array(realm.objects(FilterLocation.self))
        let recoverLocations = Array(realm.objects(MementoFilterLocation.self))
        
        zip(recoverLocations, locations).forEach { (recoverLocation, location) in
            
            realmWrite { realm in
                recoverLocation.isSubscribe = location.isSubscribe
            }
        }
        
        return recoverLocations
    }

    /// itemSelected시 상태를 업데이트 합니다.
    @discardableResult
    func update(location: FilterLocation) -> Observable<[FilterLocation]> {
        realmWrite { realm in
            location.isSubscribe = !location.isSubscribe
        }

        return fetch()
    }
    
    /// 필터 저장을 누르지 않을시, recover를 수행합니다.
    func recoverLastState(locations: [FilterLocation], mementoLocations: [FilterLocation]) {
        zip(locations, mementoLocations).forEach { (location, recoverLocation) in
            
            realmWrite { realm in
                location.isSubscribe = recoverLocation.isSubscribe
            }
        }
    }
    
    // MARK: - Function 내부에서만 사용
    
    fileprivate func write(location: FilterLocation) {
        realmWrite { realm in
            realm.add(location ,update: .modified)
        }
    }
    
    fileprivate func memotoWrite(mementoLocation: MementoFilterLocation) {
        realmWrite { realm in
            realm.add(mementoLocation ,update: .modified)
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
                
                let mementoLocation = MementoFilterLocation(type: FilterLocation.LocationType(rawValue: typeString) ?? .서울)
                self.memotoWrite(mementoLocation: mementoLocation)
            }
    }
}

class MementoFilterLocation: FilterLocation { }
