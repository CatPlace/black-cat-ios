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
        
        self.save()
    }
    
    convenience init(typeString: String, isSubscribe: Bool = false) {
        self.init(type: TaskType(rawValue: typeString) ?? .작품)
        self.typeString = typeString
        self.isSubscribe = isSubscribe
    }
}

extension FilterTask {
    /// 불러오기
    func fetch() -> [FilterTask] {
        guard let realm = self.getRealm() else { return [] }
        print("🥹 \(Array(realm.objects(FilterTask.self)))")
        return Array(realm.objects(FilterTask.self))
    }
    
    /// 글쓰기
    func write(task: FilterTask) -> Bool {
        realmWrite { realm in
            realm.add(task ,update: .modified)
        }
    }
    
    func update(task: FilterTask) {
        realmWrite { realm in
            task.isSubscribe = !task.isSubscribe
        }
    }
    
    func convertToRealmTask(task: FilterTask) -> FilterTask {
        FilterTask(typeString: task.type.rawValue, isSubscribe: task.isSubscribe)
    }
    
    /// 값을 처음에 저장해야합니다.
    func save() {
        print("나 불림용")
        guard let realm = self.getRealm() else { return }
        
        // 1. 값을 불러옵니다.
        let objects = Array(realm.objects(FilterTask.self))
        
        // 2. 키들을 뽑아냅니다.
        let keys = objects.map { $0.typeString }
        
        // 3. 없는 값인 경우 저장
        TaskType.allCases.forEach { type in
            let typeString = type.rawValue
            print("나 불림용2")
            if !keys.contains(typeString) {
                print("🌿") 
                self.write(task: FilterTask(type: type, isSubscribe: true))
            } else { print("여기 불리면 이미 값이 저장되어 있다는 말이에용") }
        }
    }
}
