//
//  recoverPasswordViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/16/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth



class recoverPasswordViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties     
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var recoverPasswordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        recoverPasswordButton.isEnabled = false
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
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButton()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    
    func updateButton() {
        if emailTextField.text != "" {
            recoverPasswordButton.isEnabled = true
        }
        else {
        recoverPasswordButton.isEnabled = false
    }
    }
    
    
    @IBAction func recoverPassword(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!)
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
