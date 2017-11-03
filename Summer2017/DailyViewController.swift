//
//  DailyViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 6/29/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit

var monthString: String?
var yearString: String?

class DailyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {

    //MARK: Properties 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UINavigationItem!
    //@IBOutlet weak var tabBar: UITabBar!
 
    
    let rowToHour = ["12AM", "1AM", "2AM", "3AM", "4AM", "5AM", "6AM", "7AM", "8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM"]
    
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // SET ROW HEIGHT HERE
        self.tableView.rowHeight = 60 
        
        
        // Get current date
        let date = Date()
        let calendar = Calendar.current
        //let hour = calendar.component(.hour, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        
        // Convert month int to month string
        let months = ["January", "February", "March", "April", "May"
            , "June", "July", "August", "September", "October"
            , "November", "December"]
        
        
        monthString = months[month - 1]
        yearString = String(year)
        
        dateLabel.title = monthString! + " " + String(day)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let hour = Calendar.current.component(.hour, from: Date())
        var currentHour = Int(hour)
        currentHour = currentHour - 1
        //        print (indexPath.row)
        //        print(currentHour)
        let indexPath = NSIndexPath(row: currentHour, section: 0)
        if indexPath.row == currentHour {
            tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
                   }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowToHour.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "HourTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HourTableViewCell  else {
            fatalError("The dequeued cell is not an instance of HourTableViewCell.")
        }
        
        cell.hourLabel.text = rowToHour[indexPath.row]
        
        let hour = Calendar.current.component(.hour, from: Date())
        var currentHour = Int(hour)
        if (indexPath.row == currentHour) {
            cell.lineView.isHidden = false
        } else {
            cell.lineView.isHidden = true
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let row = indexPath.row
        print(rowToHour[row])
    }
    
    
    @IBAction func showPopup(_ sender: AnyObject) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "optionsViewController") as! optionsViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }

    
    
}
