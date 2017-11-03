//
//  Group.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 6/1/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper
import os.log

class Group: NSObject, NSCoding {

    
    //MARK: Properties
    var name: String!
    var color: UIColor!
    var groupImage: UIImage?
    var memCount: Int!
    var memberString: String!
//    var createDate: Date!
//    var members: [String?]
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("groups")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let color = "color"
        static let groupImage = "photo"
        static let memCount = "memCount"
        static let memberString = "memberString"
//        static let createDate = "createDate"
//        static let members = "members"
    }
    
    //MARKL Initialization 
    init?(name: String, color: UIColor, groupImage: UIImage?, memCount: Int!, memberString: String!){
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
//        // The color must not be empty
//        guard !color.isEmpty else {
//            return nil
//        }
//    
        
        self.name = name
        self.color = color
        self.groupImage = groupImage
        self.memCount = memCount
        self.memberString = memberString
        //self.createDate = createDate
        //self.members = members
        
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(groupImage, forKey: PropertyKey.groupImage)
        aCoder.encode(color, forKey: PropertyKey.color)
        aCoder.encode(memCount, forKey: PropertyKey.memCount)
        aCoder.encode(memberString, forKey: PropertyKey.memCount)
        //aCoder.encode(createDate, forKey: PropertyKey.createDate)
        //aCoder.encode(members, forKey: PropertyKey.members)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Group object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let groupImage = aDecoder.decodeObject(forKey: PropertyKey.groupImage) as? UIImage
        
        let color = aDecoder.decodeObject(forKey: PropertyKey.color) as? UIColor
        
        let memCount = aDecoder.decodeObject(forKey: PropertyKey.memCount) as? Int
        
        let memberString = aDecoder.decodeObject(forKey: PropertyKey.memberString) as? String
        
        //let createDate = aDecoder.decodeObject(forKey: PropertyKey.createDate) as? Date
        
       // let members = aDecoder.decodeObject(forKey: PropertyKey.members) as? [String?]
        
        // Must call designated initializer
        self.init(name: name, color: color!, groupImage: groupImage, memCount: memCount, memberString: memberString)
    }
}
