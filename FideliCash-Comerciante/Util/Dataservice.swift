//
//  Dataservice.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 09/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = Database.database().reference()

class DataService {
    static let ds = DataService()
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_HISTORY = DB_BASE.child("history")
    private var _REF_PRODUTO = DB_BASE.child("users").child(KeychainWrapper.standard.string(forKey: KEY_UID)!).child("produto")
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_HISTORY: DatabaseReference {
        return _REF_HISTORY
    }

    var REF_PRODUTO: DatabaseReference {
        return _REF_PRODUTO
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
}
