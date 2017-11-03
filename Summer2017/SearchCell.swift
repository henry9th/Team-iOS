//
//  SearchCell.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/31/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper


class SearchCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var searchDetail: Search!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(searchDetail: Search!) {
        userImage.layer.borderWidth = 0.0
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.clipsToBounds = true

        
        self.searchDetail = searchDetail
        nameLabel.text = searchDetail.fullName
        if searchDetail.userImg == "" {
            self.userImage.image = #imageLiteral(resourceName: "defaultPhoto")
            
        }
        
        else {
        let ref = Storage.storage().reference(forURL: searchDetail.userImg)
        ref.getData(maxSize: 1000000, completion: { (data, error) in
            
            if error != nil {
                
                print(" we couldnt upload the img")
                
            } else {
                
                if let imgData = data {
                    
                    if let img = UIImage(data: imgData) {
                        
                        self.userImage.image = img
                    }
                }
            }
            
        })
    }
}
    
}
