//
//  customSegue.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 7/1/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit

class customSegue: UIStoryboardSegue {
    
    struct GlobalVariable {
        //true for right and false for left
        static var direction: Bool = false
    }
    
    override func perform() {
        
        let animationDuration = 0.00
        let  firstVCView = self.source.view as UIView!
        let  secondVCView = self.destination.view as UIView!
        
        //get the screen width and height 
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        if GlobalVariable.direction {
        
            print("TEST")
        secondVCView?.frame = CGRect(x: screenWidth, y: 0.0, width: screenWidth, height: screenHeight)
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            firstVCView?.frame = (firstVCView?.frame.offsetBy(dx: -screenWidth, dy: 0.0))!
            secondVCView?.frame = (secondVCView?.frame.offsetBy(dx: -screenWidth, dy: 0.0))!
            
        }) { (Finished) -> Void in
            self.source.present(self.destination as UIViewController, animated: false, completion: nil)
            
        }
            
    }
        
        else {
            secondVCView?.frame = CGRect(x: -screenWidth, y: 0.0, width: screenWidth, height: screenHeight)
            
            let window = UIApplication.shared.keyWindow
            window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
            
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                firstVCView?.frame = (firstVCView?.frame.offsetBy(dx: screenWidth, dy: 0.0))!
                secondVCView?.frame = (secondVCView?.frame.offsetBy(dx: screenWidth, dy: 0.0))!
                
            }) { (Finished) -> Void in
                self.source.present(self.destination as UIViewController, animated: false, completion: nil)
                
            }

            
        }
        
    }
    
}
