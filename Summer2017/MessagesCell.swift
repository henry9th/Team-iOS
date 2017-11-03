//
//  MessagesCell.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/30/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class MessagesCell: UITableViewCell {

    @IBOutlet weak var recievedMessageLabel: UILabel!
    @IBOutlet weak var revievedMessageView: UIView!
    @IBOutlet weak var sentMessageLabel: UILabel!
    @IBOutlet weak var sentMessageView: UIView!
    
    var message: Message!
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCell(message: Message) {
        
        self.message = message
        
        print(message.sender)
        print(currentUser)
        
        if message.sender == currentUser {
            
            
            sentMessageView.isHidden = false
            
            sentMessageLabel.text = message.message
            
            recievedMessageLabel.text = ""
            
            revievedMessageView.isHidden = true
            
        } else {
            
            sentMessageView.isHidden = true
            
            sentMessageLabel.text = ""
            
            recievedMessageLabel.text = message.message
            
            revievedMessageView.isHidden = false
        }
}
}
