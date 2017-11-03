//
//  GroupViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 6/29/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseDatabase
import FirebaseStorage


var groups = [Group]()

class GroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITabBarDelegate {
    
    struct GlobalVariables {
        static var shouldUpdate = false
        static var recentName: String!
        static var recentImg: String!
        static var recentColor: UInt32!
        static var recentMemCount: Int!
        static var recentMemberString: String!
    }

    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    
    //var collectionView: UICollectionView?
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    @IBOutlet weak var groupCollectionView: UICollectionView!
    //@IBOutlet weak var navigationBar: UINavigationBar!
    //@IBOutlet weak var tabBar: UITabBar!
   
    var groupId: String!
    var group: String!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    var groupImage: UIImage!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidAppear(_ animated: Bool) {
        if GlobalVariables.shouldUpdate == true {
            GlobalVariables.shouldUpdate = false
            print("ADDONE")
            addOne()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        //navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Gets the dimension of the screen
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        // Configures the dimensions of the cells
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth/2, height: screenWidth/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        groupCollectionView?.collectionViewLayout = layout
        
        //tabBar.delegate = self
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("1: \(groups.count)")
        return groups.count + 1
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
            
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! groupCollectionViewCell
        
        
        // IF last cell, then make that cell the add group cell
        if indexPath.item == groups.count {
            cell.groupName.text = ""
            //cell.backgroundColor = UIColor.white
            cell.groupCollectionImageView.image = #imageLiteral(resourceName: "addSign")
            cell.groupCollectionImageView.borderColor = UIColor.white
        }
            
        else{
            cell.groupName.text = groups[indexPath.item].name
            cell.groupName.textColor = UIColor.white
            cell.groupCollectionImageView.image = groups[indexPath.item].groupImage
            cell.backgroundColor = groupCollectionView.backgroundColor
            cell.groupCollectionImageView.layer.borderColor = groups[indexPath.item].color.cgColor

            
            
            // Configuring the imageView within the cell
            
            //Gives image as circular view
            cell.groupCollectionImageView.layer.borderWidth = 3.0
            cell.groupCollectionImageView.layer.masksToBounds = true
            cell.groupCollectionImageView.layer.cornerRadius = 49.5
            //cell.groupCollectionImageView.layer.cornerRadius = cell.groupCollectionImageView.frame.width/2
            print("corner radius: ", cell.groupCollectionImageView.frame.width/2)
            cell.groupCollectionImageView.clipsToBounds = true
            
            
        }
       
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        
        if indexPath.item == groups.count{
            performSegue(withIdentifier: "createGroupSegue", sender: nil)
        }
        
        else {
            performSegue(withIdentifier: "groupHomeSegue", sender: nil)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupHomeSegue" {
            if let indexPath = groupCollectionView.indexPathsForSelectedItems {
                let index = indexPath[0][1]
                groupHomeViewController.GlobalVariable.groupIndex = index
                let svc = segue.destination as! groupHomeViewController
                svc.groupName = groups[index].name
                svc.groupImg = groups[index].groupImage
                svc.memberString = groups[index].memberString
                
            }
        }
    }
    
    
    func addOne() {
        let color = UIColor(colorWithHexValue: Int(GlobalVariables.recentColor))

        var image: UIImage!
        
        if GlobalVariables.recentImg == "" {
            image = #imageLiteral(resourceName: "defaultPhoto")
        } else {
        let url = NSURL(string: GlobalVariables.recentImg)
        let data = NSData(contentsOf: url! as URL)
            image = UIImage(data: data! as Data)
        }
        
        let group = Group(name: GlobalVariables.recentName, color: color, groupImage: image, memCount: GlobalVariables.recentMemCount, memberString: GlobalVariables.recentMemberString)
        groups.append(group!)
        groupCollectionView.reloadData()
        print("ADD")
    }
    
    func loadData() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //UIApplication.shared.beginIgnoringInteractionEvents()

        groups.removeAll()
        
        guard let currentUser = currentUser else {
            return
        }
        
         let ref = Database.database().reference().child("userGroups").child(currentUser)
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            groups.removeAll()
            print("2: \(groups.count)")
            
            for snap in snapshot.children {
                let childSnap = snap as! DataSnapshot
                let childDict = childSnap.value as! NSDictionary
                let name = childDict["groupName"] as! String
                let colorInt = childDict["color"] as! UInt32
                let groupImg = childDict["groupImg"] as! String
                let memCount = childDict["memCount"] as! Int
                let memberString = childDict["memberString"] as! String
                
                //let colorInt = colorString.replacingOccurrences(of: "#", with: "")
                
                
                let color = UIColor(colorWithHexValue: Int(colorInt))
                
                if groupImg == "" {
                    self.groupImage = #imageLiteral(resourceName: "defaultPhoto")
                } else{
                    
                    let url = NSURL(string: groupImg)
                    let data = NSData(contentsOf: url! as URL)
                    self.groupImage = UIImage(data: data! as Data)
                }

                let group = Group(name: name, color: color, groupImage: self.self.groupImage, memCount: memCount, memberString: memberString)
                
                groups.append(group!)
                //groups.append((snap as! DataSnapshot).key)
//                print((snap as! DataSnapshot).key)
//                print(groups.count)
            
            }
            print("3: \(groups.count)")
            self.activityIndicator.stopAnimating()
            //UIApplication.shared.endIgnoringInteractionEvents()

            self.groupCollectionView.reloadData()

        })
        }

    
    
    //MARK: Action
    
    @IBAction func showPopup(_ sender: AnyObject) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "optionsViewController") as! optionsViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    
//    @IBAction func unwindToGroupCollectionView(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.source as?
//            CreateGroupViewController, let group = sourceViewController.group {
//            
//            let newIndexPath = IndexPath(item: groups.count, section: 0)
//            groups.append(group)
//            groupCollectionView.insertItems(at: [newIndexPath])
//            
//        }
//    }
}



