//
//  Task.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/16.
//

import Foundation
import RealmSwift

// 🐻‍❄️ NOTE: - GOTO SDK 🥕
public class FilterTask: Object {
    
    public enum TaskType: String, CaseIterable {
        case 작품
        case 도안

        func serverString() -> String {
            switch self {
            case .작품: return "WORK"
            case .도안: return "DESIGN"
            }
        }
    }
    
    @Persisted(primaryKey: true) private var typeString: String
    
     // public private(set) var type: TaskType private(set)이 테스트코드 때문에 열어야 할 수도 있음.
    public private(set) var type: TaskType {
        get { return TaskType(rawValue: typeString) ?? .작품 }
        set { typeString = newValue.rawValue }
    }
    @Persisted public var isSubscribe: Bool
    
    convenience init(type: TaskType, isSubscribe: Bool = false) {
        self.init()
        
        self.type = type
        self.isSubscribe = isSubscribe // 테스트코드 작성하다가 이거 빠진거 발견함 ㅠㅠ
    }
}
