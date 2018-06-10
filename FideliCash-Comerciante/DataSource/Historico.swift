//
//  Historico.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 09/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//


import Foundation
import Firebase

class Historico {
    private var _date : String!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    private var _value: Double!
    private var _origin: String!
    private var _target: String!
    private var _latitude : String!
    private var _longitude : String!
    
    var date: String {
        return _date
    }
    
    var latitude: String {
        return _latitude
    }
    
    var longitude: String {
        return _longitude
    }
    
    var origin: String {
        return _origin
    }
    
    var target: String {
        return _target
    }
    
    var value: Double {
        return _value
    }
    
    init(date: String, origin: String, target: String, value: Double) {
        self._date = date
        self._origin = origin
        self._target = target
        self._value = value
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let date = postData["date"] as? String {
            self._date = date
        }
        
        if let origin = postData["origin"] as? String {
            self._origin = origin
        }
        
        if let target = postData["target"] as? String {
            self._target = target
        }
        
        if let value = postData["value"] as? Double {
            self._value = value
        }
        
        _postRef = DataService.ds.REF_HISTORY.child(_postKey)
    }
    
}


