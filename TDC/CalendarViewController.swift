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

@IBDesignable
class CalendarViewController: UIViewController{
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    var appDelegate:AppDelegate!
    var managedContext:NSManagedObjectContext!
    
    var task: Task!
    var dates: [Date]!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        dates = Date.getDatesWithId(task?.primaryId as! Int, inManagedObjectContext: managedContext)
        
        edgesForExtendedLayout = UIRectEdge.None
        title = task?.name
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(fileName: "CellView")
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        
        calendarView.scrollToDate(NSDate())
        setupViewsOfCalendar(NSDate())
    }
    
    func checkIfTaskCompleted() -> Bool {
        return counter == task.primaryId!
    }
    
    func taskCompleted() {
        Task.updateTaskState(task.primaryId as! Int, withState: TaskStates.Complete, inManagedObjectContext: managedContext)
        
    }
    
    @IBAction func moreOptions(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .ActionSheet)
        
        let editTask = UIAlertAction(title: "Edit Task", style: .Default) { [unowned self] (alertAction) in
            let editController = UIAlertController(title: "New Task Name", message: nil, preferredStyle: .Alert)
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {
                alert -> Void in
                let textField = editController.textFields![0] as UITextField
                let newTaskName = textField.text != nil ? textField.text! : ""
                Task.updateEditedTask(self.task!.primaryId as! Int, withName: newTaskName, inManagedObjectContext: self.managedContext)
                self.title = newTaskName
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            
            editController.addTextFieldWithConfigurationHandler { [unowned self] (textField : UITextField!) -> Void in
                textField.text = self.task.name!
                textField.placeholder = "New Task Name"
            }
            
            editController.addAction(saveAction)
            editController.addAction(cancelAction)
            
            self.presentViewController(editController, animated: true, completion: nil)
        }
        let endTask = UIAlertAction(title: "End Task", style: .Destructive) { [unowned self] (alertAction) in
            let state = self.counter == self.task.duration ? TaskStates.Complete : TaskStates.Failed
            Task.updateTaskState(self.task.primaryId as! Int, withState: state, inManagedObjectContext: self.managedContext)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(editTask)
        alertController.addAction(endTask)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setupViewsOfCalendar(startDate: NSDate) {
        let month = cal.component(NSCalendarUnit.Month, fromDate: calendarView.currentCalendarDateSegment().startDate)
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12]
        monthLabel.text = monthName
        
    }
    
    func addAndSaveDate(dateToSave: NSDate) {
        let date = Date.saveDateWithId(dateToSave, withTaskId: task?.primaryId as! Int, inManagedObjectContext: managedContext)
        if date != nil {
            dates?.append(date!)
        }
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        let firstDate = task?.startDate
        let secondDate = NSDate()
        let numberOfRows = 6
        let aCalendar = NSCalendar.currentCalendar()
        
        return (startDate: firstDate!, endDate: secondDate, numberOfRows: numberOfRows, calendar: aCalendar)
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        if let cellView = cell as? CellView {
            cellView.setupCellBeforeDisplay(cellState, date: date, cal: cal, dates: dates, task: task)
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, canSelectDate date: NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        return cal.compareDate(date, toDate: NSDate(), toUnitGranularity: .Day) == .OrderedSame
        //return true
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        if !date.isInDateList(dates!, calendar: cal) {
            print("selected")
            (cell as! CellView).selectedDate()
            addAndSaveDate(date)
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        setupViewsOfCalendar(startDate)
    }
    
}

extension NSDate {
    func isInDateList(dates: [Date], calendar: NSCalendar) -> Bool {
        for date in dates {
            if let d = date.date {
                if calendar.compareDate(d, toDate: self, toUnitGranularity: .Day) == .OrderedSame {
                    return true
                }
            }
        }
        return false
    }
}

