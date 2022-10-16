//
//  Task.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import Foundation
import RealmSwift

public enum FilterTaskType: String, CaseIterable {
    case 작품
    case 도안
}

public class FilterTask: Object {
    
    @Persisted private var typeString: String = FilterTaskType.작품.rawValue
    
    public var type: FilterTaskType {
        get { return FilterTaskType(rawValue: typeString) ?? .작품 }
        set { typeString = newValue.rawValue }
    }
    @Persisted public var isSubscribe: Bool = false
    
    convenience init(type: FilterTaskType, isSubscribe: Bool = false) {
        self.init()
        self.typeString = type.rawValue
        self.type = type
        self.isSubscribe = isSubscribe
    }
}
