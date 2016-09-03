//
//  ViewController.swift
//  TDC-iOS
//
//  Created by Wilson Yan on 8/2/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData

class CalendarViewController: UIViewController,JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    
    // IBOutlets
    @IBOutlet weak var daysLeftView: DaysLeftView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    // Core Data
    var appDelegate:AppDelegate!
    var managedContext:NSManagedObjectContext!
    
    // API
    var tws: TaskWithStreak!
    var dates: [Date]!
    var streak: Int?
    var isPresentingHistory: Bool = true
    
    var fs: CGFloat = 5
    var text: NSString { return NSString(string: tws.task.name!) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Core Data - load data
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        dates = Date.getDatesWithId(tws.task.primaryId as! Int, inManagedObjectContext: managedContext)
        
        self.title = tws.task.name!
        
        // Set/Fit title text label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = tws.task.name!
        label.textColor = UIColor.blackColor()
        label.shadowOffset = CGSize(width: 5, height: 5)
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.font = UIFont(name: "Arial", size: 30)
        label.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = label
        
        // Configure CalendarView
        edgesForExtendedLayout = UIRectEdge.None
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(fileName: "CalendarDayCellView")
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        
        calendarView.scrollToDate(NSDate())
        setupViewsOfCalendar(NSDate())
        
        // Initialize values
        
        streak = tws.streak
        daysLeftView.duration = Double(tws.task.duration!)
    }
    
    private func setupViewsOfCalendar(startDate: NSDate) {
        let month = cal.component(NSCalendarUnit.Month, fromDate: calendarView.currentCalendarDateSegment().startDate)
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12]
        monthLabel.text = monthName
        
    }
    
// MARK - Calendar View DataSource and Delegate
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        let firstDate = tws.task.startDate
        let secondDate = NSDate()
        let numberOfRows = 6
        let aCalendar = NSCalendar.currentCalendar()
        
        return (startDate: firstDate!, endDate: secondDate, numberOfRows: numberOfRows, calendar: aCalendar)
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        if let cellView = cell as? CalendarDayCellView {
            cellView.setupCellBeforeDisplay(cellState, date: date, cal: cal, dates: dates, task: tws.task, isHistory: isPresentingHistory)
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, canSelectDate date: NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        return false
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        print(date)
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        setupViewsOfCalendar(startDate)
    }
    
}
