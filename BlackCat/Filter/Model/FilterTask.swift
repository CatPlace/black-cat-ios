//
//  Task.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import Foundation
import RealmSwift

enum FilterTaskType: String, CaseIterable {
    case 작품
    case 도안
}

class FilterTask: Object {
    
    @Persisted private var typeString: String = FilterTaskType.작품.rawValue
    
    var type: FilterTaskType {
        get { return FilterTaskType(rawValue: typeString) ?? .작품 }
        set { typeString = newValue.rawValue }
    }
    @Persisted var isSubscribe: Bool = false
    
    convenience init(type: FilterTaskType, isSubscribe: Bool = false) {
        self.init()
        self.type = type
        self.isSubscribe = isSubscribe
    }
}
