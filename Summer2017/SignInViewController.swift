//
//  SignInViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/14/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SwiftKeychainWrapper
import FBSDKLoginKit
import GoogleSignIn

class SignInViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    //MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    //@IBOutlet weak var facebookLogIn: FBSDKLoginButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    var userUid: String!
    
    //FACEBOOK Variables
    var fbID: String!
    var fbFullName: String!
    var fbImg: String!
    var fbEmail: String!
    
    //GOOGLE Signin Variables
    var googleID: String!
    var googleFullName: String!
    var googleImg: String!
    var googleEmail: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.isHidden = true
        signInButton.layer.cornerRadius = 5
        //signInButton.layer.borderWidth = 1
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        facebookButton.isEnabled = false
        facebookButton.isHidden = true
        
        //Setup for Facebook Button
        let facebookLogIn = FBSDKLoginButton()
        facebookLogIn.readPermissions = ["public_profile", "email", "user_friends"]
        let buttonWidth = signInButton.frame.width
        let buttonHeight = signInButton.frame.height
        let screenDimensions = UIScreen.main.bounds.width
        let fbPositionX = screenDimensions/2 - buttonWidth/2
        let fbPositionY = facebookButton.frame.minY
        facebookLogIn.frame = CGRect(x: fbPositionX, y: fbPositionY, width: buttonWidth, height: buttonHeight)
        view.addSubview(facebookLogIn)
        facebookLogIn.delegate = self
        
        //Setup for Google Signin Button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: fbPositionX, y: fbPositionY + buttonHeight, width: buttonWidth, height: buttonHeight)
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout of Facebook")
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("error: ", error!)
                return
            }
            print("successfully logged in")
            self.userUid = user?.uid
            print("UID: \(self.userUid)")
            KeychainWrapper.standard.set(self.userUid, forKey: "uid")
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start {
                (connection, result, err) in
                
                if err != nil {
                    print("Failed to start graph request:", err!)
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                }
                
                let dict = result as! NSDictionary
                //self.fbID = dict["id"] as! String
                self.fbFullName = dict["name"] as! String
                self.fbEmail = dict["email"] as! String
                
                let pictureDict = dict["picture"] as! NSDictionary
                let pictureDataDict = pictureDict["data"] as! NSDictionary
                self.fbImg = pictureDataDict["url"] as! String
                print("UID2: \(self.userUid)")
                let ref = Database.database().reference().child("userPub").child(self.userUid)
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.value is NSNull {
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "enterBirthdayFromFB", sender: nil)
                        return
                    } else {
                        //KeychainWrapper.standard.set(self.fbID, forKey: "uid")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "SignIn", sender: nil)
                    }
                })
            }
        })
        

        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {

            googleID = user.userID// For client-side use only!
            
            //let idToken = user.authentication.idToken // Safe to send to the server
            googleFullName = user.profile.name
            googleEmail = user.profile.email
            let googleImgURL = user.profile.imageURL(withDimension: 50)
            googleImg = googleImgURL?.absoluteString

            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if error != nil {
                    print("error in signing in: ", error!)
                    return
                }
                self.userUid = user?.uid
                KeychainWrapper.standard.set(self.userUid, forKey: "uid")
                
                let ref = Database.database().reference().child("userPub").child(self.userUid)
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.value is NSNull {
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "enterBirthdayFromGoogle", sender: nil)
                        return
                    } else {
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "SignIn", sender: nil)
                    }
                })
            }
            
            
            
        } else {
            print("\(error.localizedDescription)")
            return
        }
        
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //updateButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            goToMainPage()
        }
    }
    
    func updateButton() {
        if emailTextField.text != "" && passwordTextField.text != ""{
            signInButton.isEnabled = true
        }
        else {
            signInButton.isEnabled = false
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        if segue.identifier == "enterBirthdayFromFB" {
            let svc = segue.destination as! enterBirthdayViewController;
            svc.ID = self.userUid
            svc.fullName = self.fbFullName
            svc.img = self.fbImg
        }
        if segue.identifier == "enterBirthdayFromGoogle" {
            let svc = segue.destination as! enterBirthdayViewController;
            svc.ID = self.userUid
            svc.fullName = self.googleFullName
            svc.img = self.googleImg
        }
    }
    
    
    func goToMainPage() {
        performSegue(withIdentifier: "SignIn", sender: nil)
    }
    
    @IBAction func signIn(_ sender: Any){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        messageLabel.isHidden = true
        if let email = emailTextField.text, let password = passwordTextField.text   {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                
                if error == nil {
                    if let user = user {
                        self.userUid = user.uid
                        KeychainWrapper.standard.set(self.userUid, forKey: "uid")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.goToMainPage()
                    }
                } else {
                    self.messageLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                }
            }
            );
        }
        
    }
    
}
