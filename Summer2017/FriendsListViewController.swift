//
//  FriendsListViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/24/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var searchDetail = [Search]()
    var filteredData = [Search]()
    var isSearching = false
    var detail: Search!
    
    var profileFullName: String!
    var profileImage: String!
    var profileUsername: String!
    
    var recipient: String!
    var messageId: String!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")

    var indexPathofSelectedRow: IndexPath!
    
    override func viewDidLoad() {
        print("LOADED")
        super.viewDidLoad()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        }

    override func viewDidAppear(_ animated: Bool) {
        if indexPathofSelectedRow != nil{
        tableView.deselectRow(at: indexPathofSelectedRow, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MessageViewController {
            destinationViewController.recipient = recipient
            destinationViewController.messageId = messageId
        }
        
        if let destinationViewController = segue.destination as? profileViewController {
            destinationViewController.fullName = self.profileFullName
            destinationViewController.profileImgString = self.profileImage
            destinationViewController.username = self.profileUsername
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        } else {
            return searchDetail.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchData: Search!
        if isSearching {
            searchData = filteredData[indexPath.row]
            
        } else {
            searchData = searchDetail[indexPath.row]
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? SearchCell {
            cell.configCell(searchDetail: searchData)
            return cell
        } else {
            return SearchCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathofSelectedRow = indexPath
        if isSearching {
            self.profileFullName = filteredData[indexPath.row].fullName
            self.profileImage = filteredData[indexPath.row].userImg
            self.profileUsername = filteredData[indexPath.row].username
            
            
        } else {
            self.profileFullName = searchDetail[indexPath.row].fullName
            self.profileImage = searchDetail[indexPath.row].userImg
            self.profileUsername = searchDetail[indexPath.row].username
        }
        
        performSegue(withIdentifier: "toProfile", sender: nil)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredData = searchDetail.filter({ $0.fullName == searchBar.text! })
            tableView.reloadData()
        }
    }
    
    
    
    
    func loadData() {
        let ref = Database.database().reference().child("userFriends").child(currentUser!).child("friends")
        ref.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.searchDetail.removeAll()
                for data in snapshot {
                    if let postDict = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        print("key", key)
                        print("postdict",postDict)
                        let post = Search(userKey: key, postData: postDict)
                        self.searchDetail.append(post)
                        print(self.searchDetail)
                    }
                }
            }
            self.tableView.reloadData()
        })

    }
    
    @IBAction func toMessages(_ sender: Any) {
        
        
        
    }
    
    @IBAction func back(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

