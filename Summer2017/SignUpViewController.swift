//
//  SignUpViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/14/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftKeychainWrapper

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var userUid: String!
    var emailField: String!
    var passwordField: String!
    var imagePickerController: UIImagePickerController!
    var fullName: String!
    var imageSelected = false
    var username: String!
    var birthday: String!
    
    let datePicker = UIDatePicker()
    
    
    func createDatePicker() {
        
        // format for picker
        datePicker.datePickerMode = .date
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // bar button item
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        birthdayTextField.inputAccessoryView = toolbar
        
        // assigning date picker to text field
        birthdayTextField.inputView = datePicker
        
        
    }
    
    // prevent text editing of textfield 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == birthdayTextField {
            return false
        }
        
        if textField == usernameTextField {
            if let _ = string.rangeOfCharacter(from: NSCharacterSet.uppercaseLetters) {
            // Do not allow upper case letters
            return false
        }
        }
        
        return true
    }
    
    func donePressed() {
            
            // format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none

        birthdayTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        signUpButton.isEnabled = false
        firstNameTextField.delegate = self
        secondNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        birthdayTextField.delegate = self
        errorLabel.isHidden = true
        usernameTextField.autocapitalizationType = UITextAutocapitalizationType.none

        //Gives image as circular view
        userImage.layer.borderWidth = 0.0
        userImage.layer.masksToBounds = true
        //createGroupImage.layer.borderColor = UIColor.white as! CGColor
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        userImage.clipsToBounds = true

        
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
        updateButton()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButton()
    }
    
    func updateButton() {
        if (emailTextField.text != "" && passwordTextField.text != "" && firstNameTextField.text != "" && secondNameTextField.text != "" && usernameTextField.text != "" && birthdayTextField.text != "") {
            signUpButton.isEnabled = true
        }
        else {
            signUpButton.isEnabled = false
        }
    }
    
    
    @IBAction func selectPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        print("image selected")
        
        // Hide the keyboard.
        self.resignFirstResponder()
        
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            userImage.image = image
            imageSelected = true
            
        } else {
            print("image wasn't selected")
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func keychain() {
        KeychainWrapper.standard.set(userUid, forKey: "uid")
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setUpUser(img: String) {
        
        //STORING FOR userPub
        let userPub = [
            "fullName": fullName,
            "userImg": img,
            "username": username,
        ]
        
        
        let userEmail: String!
        userEmail = emailTextField.text
        
        let userPri = [
            "fullName": fullName,
            "userImg": img,
            "email": userEmail,
            "username": username,
            "birthday": birthday!
        ]

        
        //STORING FOR userFri
        
        let userFri = [
            "fullName": fullName,
            "userImg": img,
            "username": username
            ]
        
        //STORING FOR userFriends
        
        let userFriends = [
            "friendsCount": 0,
        ] as [String : Any]
    
        
        
        keychain()
        
        var setLocation = Database.database().reference().child("userPub").child(userUid)
        setLocation.setValue(userPub)
        
        setLocation = Database.database().reference().child("userPri").child(userUid)
        setLocation.setValue(userPri)
        
        setLocation = Database.database().reference().child("userFri").child(userUid)
        setLocation.setValue(userFri)
        
        setLocation = Database.database().reference().child("userFriends").child(userUid)
        setLocation.setValue(userFriends)
        
        //loads sample recieve friends query
        let sampleRecieveFriends = [
            "test": true
        ]
        setLocation = Database.database().reference().child("recieveFriendsQueue").child(userUid)
        setLocation.updateChildValues(sampleRecieveFriends)
        
        
        let sampleSentFriends = [
            "test": true
        ]
        
        setLocation = Database.database().reference().child("sentFriendsQueue").child(userUid)
        setLocation.updateChildValues(sampleSentFriends)

        
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        self.performSegue(withIdentifier: "SignIn", sender: self)

    }

    
    func setUserInfo() {
        //CHECK FOR EMAIL
        if emailTextField.text == nil {
            print("Must have email")
            signUpButton.isEnabled = false
        } else {
            emailField = emailTextField.text
        }
        
        
        //CHECK FOR PASSWORD
        if passwordTextField.text == nil {
            print("Must have password")
            signUpButton.isEnabled = false
        } else {
            passwordField = passwordTextField.text
        }
       
        //CHECK FOR FULL NAME
        if firstNameTextField.text == nil || secondNameTextField.text == nil {
            print("Must have full name")
            signUpButton.isEnabled = false
        } else {
            fullName = firstNameTextField.text! + " " + secondNameTextField.text!
        }
        
        //CHECK FOR USERNAME
        if usernameTextField.text == nil  {
            print("Must have username")
            signUpButton.isEnabled = false
        } else {
            username = usernameTextField.text!
        }
        
        //CHECK FOR BIRTHDAY
        if birthdayTextField.text == nil {
            print("Must have birthday")
            signUpButton.isEnabled = false
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            birthday = formatter.string(from: datePicker.date)
        }
        
        
        
        
    }
    
    func uploadImg() {
        //CHECK FOR full name
        
        guard let img = userImage.image, imageSelected == true else {
            print ("image not selected")
            self.setUpUser(img: "")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            Storage.storage().reference().child("ProfilePictures").child(imgUid).putData(imgData, metadata: metadata) { (metadata,error) in
                if error != nil {
                    print("did not upload img")
                } else {
                    print("img uploaded")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.setUpUser(img: url)
                }
        }
                
    }
        }
    }
    
    
    @IBAction func completeAccount(_ sender: Any) {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        setUserInfo()
        
        self.errorLabel.isHidden = true
        
        //Check if username is taken
        let ref = Database.database().reference().child("userPub")
        let username = usernameTextField.text!
        if username.contains(" ") {
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.errorLabel.text = "Username cannot contain a space"
            self.errorLabel.isHidden = false
            return
        }
        let queryRef = ref.queryOrdered(byChild: "username").queryEqual(toValue: username)
        queryRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull {
                Auth.auth().createUser(withEmail: self.emailField, password: self.passwordField, completion: { (user, error) in
                    if error != nil {
                        print("EMAIL ERROR")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.errorLabel.text = "Email is invalid or already taken"
                        self.errorLabel.isHidden = false
                        print("Can't create user \(String(describing: error))")
                        return
                    } else {
                        print("LOGGED IN")

                        if let user = user {
                            self.userUid = user.uid
                            self.uploadImg()
                        }
                    }
                })
            }
                
            else {
                print("USERNAME ERROR")

                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.errorLabel.text = "Username is taken"
                self.errorLabel.isHidden = false
                return
            }
        })

    }
}
