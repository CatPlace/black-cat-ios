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
        
        self.saveAllData()
    }
    
//    convenience init(typeString: String, isSubscribe: Bool = false) {
//        self.init()
//
//        self.typeString = typeString
//        self.isSubscribe = isSubscribe
//    }
}

extension FilterTask: BaseRealmProtocol {
    
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
            .map { $0.typeString }
        
        TaskType.allCases.map { $0.rawValue }
            .filter { !keys.contains($0) }
            .forEach { _ in self.write(task: FilterTask(type: type, isSubscribe: false)) }
    }
}
