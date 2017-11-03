//
//  groupHomeViewController.swift
//  
//
//  Created by Hyunrae Kim on 7/1/17.
//
//

import UIKit

class groupHomeViewController: UIViewController {
    
    struct GlobalVariable{
         static var groupIndex: Int = 0
    }
    
    var groupName: String!
    var groupImg: UIImage!
    var memberString: String!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        
        // Sets the navigation title as the name of the group
        //navigationItem.title = groups[GlobalVariable.groupIndex].name
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGroupProfile" {
            let svc = segue.destination as! groupProfileViewController
            svc.groupName = groupName
            svc.groupImage = groupImg
            svc.members = memberString
        }
    }

    @IBAction func back() {
        dismiss(animated: true, completion: nil)
        
    }

}
