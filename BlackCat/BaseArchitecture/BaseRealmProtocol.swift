//
//  BaseRealmProtocol.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/18.
//

import Foundation
import RealmSwift

// π»ββοΈ NOTE: - SDKλ‘ μ΄λνμ λμλ λ¬Έμ μμ΄ μλν  μ μλλ‘ κ΅¬μν©λλ€.

public protocol BaseRealmProtocol {
    func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool
    func getRealm() -> Realm?
}

extension BaseRealmProtocol {
    // π»ββοΈ NOTE: - μ¬μ©λ°©λ²μ λν DocC λ§λ€μ΄μΌ ν©λλ€.
    
    public func getRealm() -> Realm? {
        do {
            return try Realm()
        }
        catch let error as NSError {
            print("π¨ \(error.localizedDescription)")
            return nil
        }
    }
    
    @discardableResult
    public func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool {
        guard let realm = getRealm() else { return false }
        
        // realm νμΌκ²½λ‘ -> κΈ°λ³Έμ μΌλ‘ μ£Όμμ²λ¦¬ν΄μ£ΌμΈμ.
//        print("ποΈ \(Realm.Configuration.defaultConfiguration.fileURL!)")

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
