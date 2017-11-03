//
//  addFriendViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 8/10/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import SwiftKeychainWrapper

class addFriendViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var uid: String!
    var fullName: String!
    var userImg: String!
    var friendsCount: Int!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    
    override func viewDidLoad() {
        //updateButton()
        usernameTextField.autocapitalizationType = UITextAutocapitalizationType.none
        
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        errorMessage.isHidden = true
        usernameTextField.delegate = self
        profileView.isHidden = true
        profileView.layer.cornerRadius = 10
        profileView.layer.masksToBounds = true
        
        //Gives image as circular view
        profileImageView.layer.borderWidth = 0.0
        profileImageView.layer.masksToBounds = true
        //createGroupImage.layer.borderColor = UIColor.white as! CGColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
        
        
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //updateButton()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //updateButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameTextField {
            if let _ = string.rangeOfCharacter(from: NSCharacterSet.uppercaseLetters) {
                // Do not allow upper case letters
                return false
            }
        }
        return true
    }
    
    
    func updateButton() {
        if usernameTextField.text != "" {
            searchButton.isEnabled = true
        }
            
        else {
            searchButton.isEnabled = false
        }
    }
    
    
    @IBAction func search() {
        
        errorMessage.isHidden = true
        
        if usernameTextField.text == "" {
            errorMessage.text = "Please enter a username"
            errorMessage.isHidden = false
            return
        }
        
        activityIndicator.center = self.profileView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        profileView.isHidden = true
        let ref = Database.database().reference().child("userPub")
        let username = usernameTextField.text!
        let queryRef = ref.queryOrdered(byChild: "username").queryEqual(toValue: username)
        queryRef.observeSingleEvent(of: .value, with: { snapshot in
            
            
            if snapshot.value is NSNull {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.errorMessage.text = "No user found"
                self.errorMessage.isHidden = false
                return
            }
                
            else {
                
                for snap in snapshot.children {
                    let userSnap = snap as! DataSnapshot
                    self.uid = userSnap.key
                    let userDict = userSnap.value as! [String:AnyObject]
                    self.fullName = userDict["fullName"] as! String
                    self.userImg = userDict["userImg"] as! String
                    self.setUpView(fullName: self.fullName, username: username, userImg: self.userImg)
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                }
                
            }
        })
    }
    
    func setUpView(fullName: String, username: String, userImg: String) {
        profileName.text = fullName
        profileUsername.text = username
        profileView.isHidden = false
        if userImg == "" {
            profileImageView.image = #imageLiteral(resourceName: "defaultPhoto")
        } else {
        let url = NSURL(string: userImg)
        let data = NSData(contentsOf: url! as URL)
        if data != nil{
            profileImageView.image = UIImage(data: data! as Data)
        }
        }
    }
    
    @IBAction func addFriend() {
        errorMessage.isHidden = true
        //Store friendsCount
        
        //check if already friends
        let ref = Database.database().reference().child("userFriends").child(currentUser!).child("friends").child(self.uid!)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull {
                
                let sentFriendsQueue = [
                    "\(self.uid!)": false
                ]
                
                
                var setLocation = Database.database().reference().child("sentFriendsQueue").child(self.currentUser!)
                
                setLocation.updateChildValues(sentFriendsQueue)
                
                
                let recieveFriendsQueue = [
                    "\(self.currentUser!)": false
                ]
                
                setLocation = Database.database().reference().child("recieveFriendsQueue").child(self.uid!)
                setLocation.updateChildValues(recieveFriendsQueue)
                
                self.dismiss(animated: true, completion: nil)
                
            } else {
                self.errorMessage.text = "You are already friends with this user"
                self.errorMessage.isHidden = false
                return
            }
        })
        

    }
    
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
