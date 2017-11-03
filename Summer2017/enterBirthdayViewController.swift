//
//  enterBirthdayViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 8/14/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class enterBirthdayViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var heyLabel: UILabel!
    
    let datePicker = UIDatePicker()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    
    var birthday: String!
    var ID: String!
    var fullName: String!
    var img: String!
    var email: String!
    var username: String!
    
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == birthdayTextField {
            return false
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
        birthdayTextField.delegate = self
        errorMessage.isHidden = true
        heyLabel.text = "Hey \(fullName!)!"
        usernameTextField.autocapitalizationType = UITextAutocapitalizationType.none

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func upload() {
        
        let birthday = self.birthdayTextField.text
        
        let userPub = [
            "fullName": self.fullName,
            "userImg": self.img,
            "username": self.username,
            ]
        
        
        let userPri = [
            "fullName": self.fullName,
            "userImg": self.img,
            "email": self.email,
            "username": self.username,
            "birthday": birthday!
        ]
        
        
        //STORING FOR userFri
        
        let userFri = [
            "fullName": self.fullName,
            "userImg": self.img,
            "username": self.username
        ]
        
        //STORING FOR userFriends
        
        let userFriends = [
            "friendsCount": 0,
            ] as [String : Any]
        
        
        var setLocation = Database.database().reference().child("userPub").child(self.ID)
        setLocation.setValue(userPub)
        
        setLocation = Database.database().reference().child("userPri").child(self.ID)
        setLocation.setValue(userPri)
        
        setLocation = Database.database().reference().child("userFri").child(self.ID)
        setLocation.setValue(userFri)
        
        setLocation = Database.database().reference().child("userFriends").child(self.ID)
        setLocation.setValue(userFriends)
        
        let sampleRecieveFriends = [
            "test": true
        ]
        
        setLocation = Database.database().reference().child("recieveFriendsQueue").child(self.ID)
        setLocation.updateChildValues(sampleRecieveFriends)
        
        let sampleSentFriends = [
            "test": true
        ]
        
        setLocation = Database.database().reference().child("sentFriendsQueue").child(self.ID)
        setLocation.updateChildValues(sampleSentFriends)


    }
    
    @IBAction func doneButtonPressed() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        errorMessage.isHidden = true
        
        
        if usernameTextField.text == "" {
            errorMessage.text = "Username not entered"
            errorMessage.isHidden = false
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            return
        }
        
        if self.birthdayTextField.text == "" {
            self.errorMessage.text = "Birthday not entered"
            self.errorMessage.isHidden = false
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            return
            
        }
        //MARK: Check if username is taken
        self.username = usernameTextField.text
        let ref = Database.database().reference().child("userPub")
        let queryRef = ref.queryOrdered(byChild: "username").queryEqual(toValue: self.username)
        queryRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull {
                self.birthday = self.birthdayTextField.text
                print(self.birthday)
                self.upload()
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.performSegue(withIdentifier: "SignIn", sender: nil)

            }
            else {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.errorMessage.text = "Username is taken"
                self.errorMessage.isHidden = false
                return
            }
        })
        
     
    }
    

}
