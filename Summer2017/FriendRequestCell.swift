//
//  FriendRequestCell.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 8/20/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit

class FriendRequestCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameMessage: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(fullName: String, img: UIImage) {
        profileImg.image = img
        nameMessage.text = "\(fullName) wants to be your friend"
        
        profileImg.layer.borderWidth = 0
        profileImg.layer.masksToBounds = true
        profileImg.layer.cornerRadius = profileImg.frame.width/2
        profileImg.clipsToBounds = true

        
    }
    
    
    
    
}
