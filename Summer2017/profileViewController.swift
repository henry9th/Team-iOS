//
//  profileViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 8/18/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class profileViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileFullName: UILabel!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var fullNameEditButton: UIButton!
    @IBOutlet weak var usernameEditButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var newGroupButton: UIButton!
    
    var profileImage: UIImage!
    var profileImgString: String!
    var fullName: String!
    var username: String!
    var showEdit = false
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImg.layer.borderWidth = 0
        profileImg.layer.masksToBounds = true
        profileImg.layer.cornerRadius = profileImg.frame.width/2
        profileImg.clipsToBounds = true

        
        
        if showEdit == true {
            loadMyData()
            fullNameEditButton.isHidden = false
            usernameEditButton.isHidden = false
            messageButton.isHidden = true
            newGroupButton.isHidden = true
            showEdit = false
        }
        
        else {
            loadFriendData()
            fullNameEditButton.isHidden = true
            usernameEditButton.isHidden = true
            messageButton.isHidden = false
            newGroupButton.isHidden = false
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFriendData() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        if profileImgString == "" {
            self.profileImage = #imageLiteral(resourceName: "defaultPhoto")
        } else {
            let url = NSURL(string: self.profileImgString)
            let data = NSData(contentsOf: url! as URL)
            self.profileImage = UIImage(data: data! as Data)
          }
        
        self.setupProfile(image: self.profileImage, fullName: self.fullName, username: self.username)
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func loadMyData() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        
        Database.database().reference().child("userPub").child(currentUser!).observe(.value, with:{ (snapshot: DataSnapshot) in
            let dict = snapshot.value as! NSDictionary
            self.fullName = dict["fullName"] as! String
            self.username = dict["username"] as! String
            let imgString = dict["userImg"] as! String
            if imgString == "" {
                self.profileImage = #imageLiteral(resourceName: "defaultPhoto")
                self.setupProfile(image: self.profileImage, fullName: self.fullName, username: self.username)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            } else {
                let url = NSURL(string: imgString)
                let data = NSData(contentsOf: url! as URL)
                self.profileImage = UIImage(data: data! as Data)
                self.setupProfile(image: self.profileImage, fullName: self.fullName, username: self.username)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        })
        
    }
    
    func setupProfile(image: UIImage!, fullName: String!, username: String!) {
        profileImg.image = image
        profileFullName.text = fullName
        profileUsername.text = username
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func messageGroup(_ sender: Any) {
    }
    
    @IBAction func newGroup(_ sender: Any) {
    }
    
    
}
