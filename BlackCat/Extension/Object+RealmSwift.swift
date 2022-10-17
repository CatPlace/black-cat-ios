//
//  Object+RealmSwift.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/17.
//

import Foundation
import RealmSwift

extension Object {
    public func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool {
        guard let realm = getRealm() else { return false }
        
        // realm 파일위치
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        do {
            try realm.write { operation(realm) }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return false
        }

        return true
    }

    public func getRealm() -> Realm? {
        do {
            return try Realm()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
}
