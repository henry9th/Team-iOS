//
//  createEventViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/18/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SwiftKeychainWrapper

class createEventViewController: UIViewController {

 
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: Actions
    
    @IBAction func cancelEvent(_ sender: Any) {
        dismiss(animated: true)
    }

    

}
