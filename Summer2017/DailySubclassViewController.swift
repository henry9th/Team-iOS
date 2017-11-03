//
//  DailySubclassViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 8/7/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import CalendarKit
import FirebaseDatabase
import Firebase
import SwiftKeychainWrapper


class DailySubclassViewController: UIViewController {
    
    
    struct GlobalVariable {
        static var isFromMonth = false
        static var dateFromMonth: Date!
        static var dateLabelText: String!
        static var friendRequests = [String]()
        
    }
    
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    
    @IBOutlet var dayView: DayView!
    
    override func viewDidAppear(_ animated: Bool) {
        if GlobalVariable.isFromMonth == true {
            print("TEST")
            GlobalVariable.isFromMonth = false
            dayView.changeCurrentDate(to: GlobalVariable.dateFromMonth)
            dayView.configureHeaderWeek(date: GlobalVariable.dateFromMonth)
            
        }
        
        observeNotifications()
    }
    
    func observeNotifications() {
        //Observe change in sentFriendsQueue
        var friendInfo = [String: String]()
        
        var setLocation = Database.database().reference().child("sentFriendsQueue").child(currentUser!)
        
        setLocation.observe(.value, with: { (snapshot) in
            print("DETECTED")
            for snap in snapshot.children {
                let childSnap = snap as! DataSnapshot
                print("childSnap ", childSnap)
                let sentFriendsRequest = childSnap.value as! Bool
                let key = childSnap.key
                print(key)
                if sentFriendsRequest == true && key != "test" {
                    print("REACHEDMOATDSFASDF")

                    Database.database().reference().child("userPub").child(key).observeSingleEvent(of: .value, with: { snapshot in
                        let dict = snapshot.value as! NSDictionary
                        let fullName = dict["fullName"] as! String
                        let userImg = dict["userImg"] as! String
                        let username = dict["username"] as! String
                        
                        friendInfo = [
                            "fullName": fullName,
                            "userImg": userImg,
                            "username": username
                        ]
                        let setLocation = Database.database().reference().child("userFriends").child(self.currentUser!).child("friends").child(key)
                        setLocation.setValue(friendInfo)

                    })
                }
                
            }
            
        }
        )
        
        
        
        
        //Observe change in recieveFriendsQueue
        let ref = Database.database().reference().child("recieveFriendsQueue").child(currentUser!)
        
        
        ref.observe(.value, with: { (snapshot) in
            GlobalVariable.friendRequests.removeAll()
            for snap in snapshot.children {
                let childSnap = snap as! DataSnapshot
                print(childSnap.key)
                print(childSnap.value! as! Bool)
                let recievedFriendRequest = childSnap.value as! Bool
                let key = childSnap.key
                if recievedFriendRequest == false {
                    print("friend request pending")
                    if GlobalVariable.friendRequests.contains(key) {
                        
                    } else {
                        GlobalVariable.friendRequests.append(key)
                    }
                    
                } else {
                    if GlobalVariable.friendRequests.contains(key) {
                        let index = GlobalVariable.friendRequests.index(of: key)
                        GlobalVariable.friendRequests.remove(at: index!)
                    }
                }
                
            }
            print(GlobalVariable.friendRequests.count)
            
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
