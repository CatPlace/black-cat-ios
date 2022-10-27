//
//  BaseRealmProtocol.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation
import RealmSwift

// NOTE: - SDK로 이동했을 때에도 문제없이 작동할 수 있도록 구상합니다.

public protocol BaseRealmProtocol {
    func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool
    func getRealm() -> Realm?
}

extension BaseRealmProtocol {
    // NOTE: - 사용방법에 대한 DocC 만들어야 합니다.
    
    public func getRealm() -> Realm? {
        do {
            return try Realm()
        }
        catch let error as NSError {
            print("🚨 \(error.localizedDescription)")
            return nil
        }
    }
    
    @discardableResult
    public func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool {
        guard let realm = getRealm() else { return false }
        
        // realm 파일경로 -> 기본적으로 주석처리해주세요.
//        print("🗂️ \(Realm.Configuration.defaultConfiguration.fileURL!)")

        do {
            try realm.write { operation(realm) }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return false
        }

        return true
    }
}
