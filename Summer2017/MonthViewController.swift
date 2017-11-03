//
//  MonthViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 5/30/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit
import JTAppleCalendar

class MonthViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var year: UILabel! 
    
    
    var toDailyDate: Date!
    
    let outsideMonthColor = UIColor(colorWithHexValue: 0x584a66)
    let monthColor = UIColor.white
    let selectedMonthColor = UIColor(colorWithHexValue: 0x3a294b)
    let currentDateSelectedViewColor = UIColor(colorWithHexValue: 0x4e3f5d)
    
    let formatter = DateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        let date = Date()
        self.formatter.dateFormat = "MM"
        let monthString = self.formatter.string(from:date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let someDateTime = formatter.date(from: "2017/\(monthString)/15")
        self.calendarView.scrollToDate(someDateTime!)
    }
    
    
    func setupCalendarView() {

        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //Set up labels
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
            }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? MonthCell  else { return }
        if cellState.isSelected {

            validCell.dateLabel.textColor = selectedMonthColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                    validCell.dateLabel.textColor = monthColor
            } else {
                validCell.dateLabel.textColor = outsideMonthColor
        }
    }
    }

    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? MonthCell else { return }
        if cellState.isSelected {
            // If double selected, then it goes to the daily page
            if (validCell.selectedView.isHidden == false) {
                let pageViewController = self.parent as! PageViewController
                DailySubclassViewController.GlobalVariable.isFromMonth = true
                DailySubclassViewController.GlobalVariable.dateFromMonth = toDailyDate
                pageViewController.toDailyPage()
                
            }
            validCell.selectedView.isHidden = false
            
        } else {
            validCell.selectedView.isHidden = true
        }

    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: Actions 
    @IBAction func showPopup(_ sender: AnyObject) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "optionsViewController") as! optionsViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
}

extension MonthViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "1997 01 01")!
        let endDate = formatter.date(from: "2100 12 01")!
        
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
            return parameters
    }
}

extension MonthViewController: JTAppleCalendarViewDelegate {
    //Display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell{
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "MonthCell", for: indexPath) as! MonthCell
        cell.dateLabel.text = cellState.text

        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        toDailyDate = date
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
         }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "yyyy"
        year.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date)
        

    }

}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((value & 0xff0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00ff00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000ff) / 255.0,
            alpha: alpha
        )
}
}



