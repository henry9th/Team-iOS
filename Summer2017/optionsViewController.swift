//
//  optionsViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/17/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth

class optionsViewController: UIViewController, UITableViewDelegate {

    //MARK: Properties
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet weak var friendRequestCount: UILabel!
    
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")

    func viewDidAppear() {
        if DailySubclassViewController.GlobalVariable.friendRequests.count == 0 {
            friendRequestCount.text = ""

        } else {
        friendRequestCount.text = "\(DailySubclassViewController.GlobalVariable.friendRequests.count)"
        }
    }
    
    
    override func viewDidLoad() {
        
        if DailySubclassViewController.GlobalVariable.friendRequests.count == 0 {
            friendRequestCount.text = ""
            
        } else {
        friendRequestCount.text = "\(DailySubclassViewController.GlobalVariable.friendRequests.count)"
        }
        
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.showAnimate()
        
        optionsView.layer.cornerRadius = 10
        optionsView.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    @IBAction func closePopup(_ sender: AnyObject) {
        self.removeAnimate()
        
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyProfile" {
            print("TEST!!!!")
            let svc = segue.destination as! profileViewController
            svc.showEdit = true
        }
    }
    
    
    @IBAction func logOut() {
        try! Auth.auth().signOut()
        KeychainWrapper.standard.removeObject(forKey: "uid")
        performSegue(withIdentifier: "SignOut", sender: (Any).self)
    }


}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

