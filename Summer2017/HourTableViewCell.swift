//
//  HourTableViewCell.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 6/1/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit

class HourTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var lineView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
//        let linePosition = tableView.rectForRow(at: indexPath as IndexPath)
//
//        let screenSize = UIScreen.main.bounds
//        let screenWidth = screenSize.width
//        let screenHeight = screenSize.height
//        lineView.center = CGPoint(x: screenWidth/2, y: linePosition.midY)
//        print("TEST")

    
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
