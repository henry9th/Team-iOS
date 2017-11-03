//
//  Search.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/31/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper


class Search {

    private var _fullName: String!
    private var _userImg: String!
    private var _userKey: String!
    private var _username: String!
    private var _userRef: DatabaseReference!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var fullName: String {
        return _fullName
    }
    
    var userImg: String {
        return _userImg
    }
    
    var userKey: String {
        return _userKey
    }
    
    var username: String {
        return _username
    }
    
    
    init(fullName: String, userImg: String, username: String) {
        _fullName = fullName
        _userImg = userImg
        _username = username
        
    }
    
    init(userKey: String, postData: Dictionary<String, AnyObject>) {
        _userKey = userKey
        if let fullName = postData["fullName"] as? String {
            _fullName = fullName
        }
        
        if let userImg = postData["userImg"] as? String {
            _userImg = userImg
            
        }
        
        if let username = postData["username"] as? String {
            _username = username
        }
        _userRef = Database.database().reference().child("messages").child(_userKey)
    }




}
