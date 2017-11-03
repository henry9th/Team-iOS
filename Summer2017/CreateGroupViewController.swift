//
//  CreateGroupViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 5/30/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper

class CreateGroupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var createGroupImage: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var colorPicker: ChromaColorPicker!
    @IBOutlet weak var membersTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    var groupId: String!
    var group: Group!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    var notDefault = false
    var uid: String!
    var fullName: String!
    var userImg: String!
    var username: String!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var memberString: String!
    var memberName: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        errorMessage.isHidden = true
        
        // Handle the text field's user input through delegate callbacks
        groupNameTextField.delegate = self

        
        //Gives image as circular view
        createGroupImage.layer.borderWidth = 0.0
        createGroupImage.layer.masksToBounds = true
      //createGroupImage.layer.borderColor = UIColor.white as! CGColor
        createGroupImage.layer.cornerRadius = createGroupImage.frame.size.height/2
        createGroupImage.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        
        //SETUP COLOR PICKER
        colorPicker.delegate = self as? ChromaColorPickerDelegate
        
        profileView.isHidden = true
        
        //Gives image as circular view
        profileImageView.layer.borderWidth = 0.0
        profileImageView.layer.masksToBounds = true
        //createGroupImage.layer.borderColor = UIColor.white as! CGColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true

        profileView.isHidden = true
        profileView.layer.cornerRadius = 10
        profileView.layer.masksToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        groupNameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //updateCreateGroupButtonState()

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
                    self.memberName = userDict["fullName"] as! String
                    self.userImg = userDict["userImg"] as! String
                    self.username = userDict["username"] as! String
                    self.setUpView(fullName: self.fullName, username: username, userImg: self.userImg)
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                }
                
            }
        })
    }

    func setUpView(fullName: String, username: String, userImg: String) {
        profileName.text = fullName
        profileView.isHidden = false
        
        let url = NSURL(string: userImg)
        let data = NSData(contentsOf: url! as URL)
        if data != nil{
            profileImageView.image = UIImage(data: data! as Data)
        }
    }

    
    private func saveGroup(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(groups, toFile: Group.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Group successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save group...", log: OSLog.default, type: .error)
        }
        
    }
    
    
    @IBAction func addMember() {
        if membersTextField.text == "" {
            membersTextField.text = self.username
            memberString = self.fullName
        }
        
        else {
            membersTextField.text = membersTextField.text! + ", " + self.username
            memberString = memberString + ", " + self.fullName
            
        }
        self.usernameTextField.text = ""
        profileView.isHidden = true
    }
  
    //MARK: Actions
    @IBAction func selectPhotoLibrary(_ sender: UITapGestureRecognizer) {
    
        print("image selected")
        notDefault = true
        // Hide the keyboard.
        groupNameTextField.resignFirstResponder()
  
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        createGroupImage.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
         }

    

    private func updateCreateGroupButtonState() {
        // Disable the Save button if the text field is empty.
        let text = groupNameTextField.text ?? ""
        createGroupButton.isEnabled = !text.isEmpty
    }

    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIButton, button === createGroupButton else {
            os_log("The Create Group button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
    }
    

    
    func setUpGroup(imgURL: String) {
        let name = groupNameTextField.text ?? ""
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let dataDate = formatter.string(from: date)
        let color = colorPicker.currentColor
        let colorInt = color.toHex()
        let colorString = color.toHexString()
        
        print(colorString)
        
        let ref = Database.database().reference().child("userPub").child(currentUser!)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                print("can't find current user")
                return
            }
                
            else {
                let dict = snapshot.value as! NSDictionary
                let username = dict["username"] as! String
                let fullName = dict["fullName"] as! String
                self.memberString = "\(fullName), " + self.memberString
                var members = [String]()
                let allMembersString = self.membersTextField.text!
                members = allMembersString.components(separatedBy: ", ")
                members.append(username)
                let memberCount = members.count
                
                
                //Generate random group key
                let groupId = UUID().uuidString
                
                let groupsMemCount = [
                    "memCount": memberCount
                ]
                
                var setLocation = Database.database().reference().child("groupsMem").child(groupId)
                setLocation.setValue(groupsMemCount)
                
                for member in members {
                    let ref = Database.database().reference().child("userPub")
                    let queryRef = ref.queryOrdered(byChild: "username").queryEqual(toValue: member)
                    queryRef.observeSingleEvent(of: .value, with: { snapshot in
                        
                        if snapshot.value is NSNull {
                            self.errorMessage.text = "No user found"
                            self.errorMessage.isHidden = false
                            return
                        }
                            
                        else {
                            for snap in snapshot.children {
                                let userSnap = snap as! DataSnapshot
                                let uid = userSnap.key
                                let userDict = userSnap.value as! [String:AnyObject]
                                let fullName = userDict["fullName"] as! String
                                let userImg = userDict["userImg"] as! String
                                
                                let groupsMem = [
                                    "fullName": fullName,
                                    "msgMissCount": 0,
                                    "userImg": userImg
                                    ] as [String : Any]
                                
                                var setLocation = Database.database().reference().child("groupsMem").child(groupId).child(uid)
                                setLocation.setValue(groupsMem)
                                
                                let userGroups = [
                                    "color": colorInt,
                                    "groupName": name,
                                    "groupImg": imgURL,
                                    "memCount": memberCount,
                                    "memberString": self.memberString
                                    ] as [String : Any]
                                
                                //Storage for userGroups
                                setLocation = Database.database().reference().child("userGroups").child(uid).child(groupId)
                                setLocation.setValue(userGroups)
                                
                                let groupsQuery = [
                                    "\(uid)": true
                                ]
                                
                                setLocation = Database.database().reference().child("groupsQuery").child(groupId).child("member")
                                setLocation.updateChildValues(groupsQuery)
                                
                            }
                            
                        }
                    })
                    
                    
                }
                
                
                let groupsStat = [
                    "groupName": name,
                    "groupImg": imgURL,
                    "memCount": memberCount,
                    "created_at": dataDate,
                    "private": false,
                    "memberString": self.memberString
                    ] as [String : Any]
                
                
                //STORING FOR groupsStat
                setLocation = Database.database().reference().child("groupsStat").child(groupId)
                setLocation.setValue(groupsStat)
                
                //Set global variables for GroupViewController
                GroupViewController.GlobalVariables.recentName = name
                GroupViewController.GlobalVariables.recentImg = imgURL
                GroupViewController.GlobalVariables.recentMemCount = memberCount
                GroupViewController.GlobalVariables.recentColor = colorInt
                GroupViewController.GlobalVariables.recentMemberString = self.memberString
                self.dismiss(animated: true, completion: nil)

            }
        })
        
        
    }
    
    @IBAction func createGroup(_ sender: Any) {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()

        errorMessage.isHidden = true
        
        if groupNameTextField.text == "" {
            errorMessage.text = "Group name is required"
            errorMessage.isHidden = false
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            return
        }
        
        if membersTextField.text == "" {
            errorMessage.text = "No members added"
            errorMessage.isHidden = false
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            return
        }
        
        guard let img = createGroupImage.image else {
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            return
        }

        
        if notDefault == false {
            self.setUpGroup(imgURL: "")
            GroupViewController.GlobalVariables.shouldUpdate = true
           // dismiss(animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            return
        }
        print("REACHED1")

        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            print("REACHED2")
            let groupImgId = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            Storage.storage().reference().child("GroupPictures").child(groupImgId).putData(imgData, metadata: metadata) {
                (metadata,error) in
                print("REACHED3")

                if error != nil {
                    print("did not upload img: ", error!)
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents() 
                } else {
                    print("img uploaded")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        print("REACHED4")
                        self.setUpGroup(imgURL: url)
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        GroupViewController.GlobalVariables.shouldUpdate = true
                        return
                    }
                }
    }
    }
}
}
