//
//  Produtos.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 10/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import Foundation
import Firebase

class Produtos {
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    private var _value: Double!
    private var _produto: String!

    var produto: String {
        return _produto
    }
    
    var value: Double {
        if let _ = _value {
            return _value
        } else {
            return 0
        }
    }
    
    init(produto: String, value: Double) {
        self._produto = produto
        self._value = value
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let produto = postData["produto"] as? String {
            self._produto = produto
        }
        
        if let value = postData["value"] as? Double {
            self._value = value
        }
        
        _postRef = DataService.ds.REF_PRODUTO.child(_postKey)
    }
    
}


