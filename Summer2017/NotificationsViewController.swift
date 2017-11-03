//
//  NotificationsViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 8/19/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import FirebaseDatabase

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var friendRequestTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var friendRequestMemberInfo = [friendRequest]()
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var friendsCount: Int!
    
    override func viewDidLoad() {
        loadData()
        
        friendRequestTableView.delegate = self
        friendRequestTableView.dataSource = self
        super.viewDidLoad()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    func viewDidAppear() {
        loadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequestMemberInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("friendRequests in table view", DailySubclassViewController.GlobalVariable.friendRequests)
        
        if friendRequestMemberInfo.isEmpty {
            print("empty")
            return FriendRequestCell()
        } else {
            let friendRequest = friendRequestMemberInfo[indexPath.row]
            if let cell = friendRequestTableView.dequeueReusableCell(withIdentifier: "friendRequestCell") as? FriendRequestCell {
                print("configured")
                cell.configureCell(fullName: friendRequest.fullName, img: friendRequest.profileImg)
                return cell
            } else {
                print("test")
                return FriendRequestCell()
            }
        }
    }
    
    struct friendRequest {
        var uid: String
        var fullName: String
        var profileImg: UIImage
        var imgURL: String
    }
    
    func loadData() {
        print("friendRequests in loadData", DailySubclassViewController.GlobalVariable.friendRequests)
        if DailySubclassViewController.GlobalVariable.friendRequests.count != 0 {
            let ref = Database.database().reference().child("userPub")
            for member in DailySubclassViewController.GlobalVariable.friendRequests {
                ref.child(member).observeSingleEvent(of: .value, with: { snapshot in
                    self.friendRequestMemberInfo.removeAll()
                    
                    let uid = snapshot.key
                    let dict = snapshot.value as! NSDictionary
                    let fullName = dict["fullName"] as! String
                    let profileImage = dict["userImg"] as! String
                    if profileImage == "" {
                        let profileImg  = #imageLiteral(resourceName: "defaultPhoto")
                        self.friendRequestMemberInfo.append(friendRequest(uid: uid, fullName: fullName, profileImg: profileImg, imgURL: profileImage))
                        self.friendRequestTableView.reloadData()
                    } else {
                    let url = NSURL(string: profileImage)
                    let data = NSData(contentsOf: url! as URL)
                    let profileImg  = UIImage(data: data! as Data)
                    self.friendRequestMemberInfo.append(friendRequest(uid: uid, fullName: fullName, profileImg: profileImg!, imgURL: profileImage))
                    self.friendRequestTableView.reloadData()
                        
                    }
                } )
            }
        }
            
        else {
            self.friendRequestMemberInfo.removeAll()
            self.friendRequestTableView.reloadData()
        }
        
    }
    
    
    @IBAction func requestAccepted(_ sender: AnyObject) {
        guard let cell = sender.superview??.superview as? FriendRequestCell else {
            return
        }
        
        let indexPath = friendRequestTableView.indexPath(for: cell)
        let index = indexPath?.row
        let memberOfIndex = friendRequestMemberInfo[index!]
        let otherUID = memberOfIndex.uid
        
        //Sets recieveFriendsQueue to true
        var ref = Database.database().reference().child("recieveFriendsQueue").child(currentUser!).child(otherUID)
        ref.setValue(true)
        
        let key = ref.key
        print("key ", key)
        
        //Sets sentFriendsQueue for other user to true 
        ref = Database.database().reference().child("sentFriendsQueue").child(key).child(currentUser!)
        ref.setValue(true)
        
        
        print("friendRequests ", DailySubclassViewController.GlobalVariable.friendRequests)
        
        //get data information
        
        let userFriends = [
            "fullName": friendRequestMemberInfo[index!].fullName,
            "userImg": friendRequestMemberInfo[index!].imgURL
        ]
        
        print(userFriends)
        
        var setLocation = Database.database().reference().child("userFriends").child(currentUser!).child("friends").child(otherUID)
        
        print(setLocation)
        setLocation.setValue(userFriends)

        //remove uid from data set
        let indexContainingKey = DailySubclassViewController.GlobalVariable.friendRequests.index(of: key)
        DailySubclassViewController.GlobalVariable.friendRequests.remove(at: indexContainingKey!)
        
        //Updates Friend Count
        Database.database().reference().child("userFriends").child(currentUser!).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let count = value?["friendsCount"] as? Int
            print("count ", count!)
            self.friendsCount = count! + 1
            print("friendsCount ", self.friendsCount)
            
            let friendsCountInfo = [
                "friendsCount": self.friendsCount
            ]
            
            setLocation = Database.database().reference().child("userFriends").child(self.currentUser!)
            setLocation.updateChildValues(friendsCountInfo)

            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
        
        
        loadData()
        
        
    }
    
    @IBAction func requestDeclined(_ sender: AnyObject) {
        guard let cell = sender.superview??.superview as? FriendRequestCell else {
            return
        }
        
        let indexPath = friendRequestTableView.indexPath(for: cell)
        let index = indexPath?.row
        let memberOfIndex = friendRequestMemberInfo[index!]
        let otherUID = memberOfIndex.uid
        
        print(indexPath)
        
        //Removes the request
        let ref = Database.database().reference().child("recieveFriendsQueue").child(currentUser!).child(otherUID)
        ref.removeValue()
        
        loadData()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
