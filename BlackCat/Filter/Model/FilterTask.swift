//
//  Task.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import Foundation
import RealmSwift

// NOTE: - GOTO SDK 🥕
public class FilterTask: Object {
    
    public enum TaskType: String, CaseIterable {
        case 작품
        case 도안
    }
    
    @Persisted(primaryKey: true) private var typeString: String = TaskType.작품.rawValue
    
    public var type: TaskType {
        get { return TaskType(rawValue: typeString) ?? .작품 }
        set { typeString = newValue.rawValue }
    }
    @Persisted public var isSubscribe: Bool = false
    
    convenience init(type: TaskType, isSubscribe: Bool = false) {
        self.init()
        self.typeString = type.rawValue
        self.type = type
        self.isSubscribe = isSubscribe
    }
}
