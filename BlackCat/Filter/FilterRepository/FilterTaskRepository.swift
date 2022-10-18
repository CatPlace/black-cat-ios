//
//  FilterService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation

protocol FilterTaskRepository {
    
}

final class FilterTaskRepositoryImpl: BaseRealmProtocol, FilterTaskRepository {
    func fetch() -> [FilterTask] {
        guard let realm = self.getRealm() else { return [] }
        return Array(realm.objects(FilterTask.self))
    }
}
