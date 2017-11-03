//
//  messageDetailCell.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/28/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper



class messageDetailCell: UITableViewCell {

    @IBOutlet weak var recipientImg: UIImageView!
    @IBOutlet weak var recipientName: UILabel!
    @IBOutlet weak var chatPrview: UILabel!
    
    var messageDetail: MessageDetail!
    
    var userPostKey: DatabaseReference!
    
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(messageDetail: MessageDetail) {
        
        self.messageDetail = messageDetail
        
        let recipientData = Database.database().reference().child("users").child(messageDetail.recipient)
        
        recipientData.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as! Dictionary<String, AnyObject>
            
            let fullName = data["fullName"]
            
            let userImg = data["userImg"]
            
            self.recipientName.text = fullName as? String
            
            let ref = Storage.storage().reference(forURL: userImg! as! String)
            
            ref.getData(maxSize: 100000, completion: { (data, error) in
                
                if error != nil {
                    print("could not load image")
                } else {
                    
                    if let imgData = data {
                        
                        if let img = UIImage(data: imgData) {
                            
                            self.recipientImg.image = img
                        }
                    }
                }
            })
        })
    }
}
