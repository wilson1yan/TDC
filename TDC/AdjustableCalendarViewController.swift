//
//  InteractiveCalendarViewController.swift
//  TDC
//
//  Created by Wilson Yan on 8/31/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar

class AdjustableCalendarViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // IBOutlets
    @IBOutlet weak var daysLeftView: DaysLeftView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var updateButton: UIBarButtonItem!

    fileprivate let cal = Calendar(identifier: Calendar.Identifier.gregorian)
    
    // Core Data
    fileprivate var appDelegate:AppDelegate!
    fileprivate var managedContext:NSManagedObjectContext!
    
    // API
    var tws: TaskWithStreak!
    var isPresentingHistory: Bool = false

    fileprivate var dates: [Date]!
    fileprivate var streak: Int!
    
    fileprivate var fs: CGFloat = 5
    fileprivate var text: NSString { return NSString(string: tws.task.name!) }
    fileprivate var calendarCellViewDict: Dictionary<Foundation.Date,CalendarDayCellView> = [:]

    // MARK - View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        // Core Data - load data
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        dates = Date.getDatesWithId(tws.task.primaryId as! Int, inManagedObjectContext: managedContext)
        
        // Set/Fit title text label
        self.navigationItem.titleView = UILabel.getFittedLabelWithTitle(tws.task.name!)
        
        // Configure CalendarView
        edgesForExtendedLayout = UIRectEdge()
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(fileName: "CalendarDayCellView")
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        
        calendarView.scrollToDate(Foundation.Date())
        setupViewsOfCalendar(Foundation.Date())
        
        // Initialize values
        
        streak = tws.streak
        daysLeftView.duration = Double(tws.task.duration!)
        
        updateButton.isEnabled = !isPresentingHistory
        daysLeftView.createGradient()
        if !isPresentingHistory {
            configueViewsIfMissedDates()
        } else {
            updateButton.tintColor = UIColor.clear
            daysLeftView.days = Double(tws.streak)
        }
    }
    
    
    // MARK - IBAction
    @IBAction func moreOptions(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        let editTask = UIAlertAction(title: "Edit Task", style: .default) { [unowned self] (alertAction) in
            let editController = UIAlertController(title: "New Task Name", message: nil, preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                let textField = editController.textFields![0] as UITextField
                let newTaskName = textField.text != nil ? textField.text! : ""
//                Task.updateEditedTask(self.tws.task.primaryId as! Int, withName: newTaskName, inManagedObjectContext: self.managedContext)
                Task.updateTask(self.tws.task.primaryId as! Int, withInfo: [TaskAttributes.Name:newTaskName], inManagedObjectContext: self.managedContext)
                self.navigationItem.titleView = UILabel.getFittedLabelWithTitle(newTaskName)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
            
            editController.addTextField { [unowned self] (textField : UITextField!) -> Void in
                textField.text = self.tws.task.name!
                textField.placeholder = "New Task Name"
            }
            
            editController.addAction(saveAction)
            editController.addAction(cancelAction)
            
            self.present(editController, animated: true, completion: nil)
        }
        //        let endTask = UIAlertAction(title: "End Task", style: .Destructive) { [unowned self] (alertAction) in
        //            let state = self.streak == self.tws.task.duration ? TaskStates.Complete : TaskStates.Failed
        //            Task.updateTaskState(self.tws.task.primaryId as! Int, withState: state, inManagedObjectContext: self.managedContext)
        //        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(editTask)
        //alertController.addAction(endTask)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK - Custom API
    fileprivate func configueViewsIfMissedDates() {
        if tws.task.didAlreadyDisplayMissingToday! == DidDisplayMissingTodayStates.NO {
            let missedDates = getMissedDates()
            if missedDates > 0 && !Foundation.Date().isInDateList(dates, calendar: cal){
                var canDismissWithTap = true
                let consecDays = getConsecutiveDaysStartingFrom(Foundation.Date().getDaysBefore(2, calendar:cal))
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                if missedDates == 1 && consecDays >= 5{
                    alertController.title = "You've missed a day after \(consecDays) consecutive days. I'll trust it was just an honest mistake."
                    let fix = UIAlertAction(title: "Fix It", style: .default, handler: { [unowned self](alertAction) in
                        self.streak = consecDays
                        let day = Foundation.Date().getDaysBefore(1, calendar: self.cal)
                        self.setDatetoCheck(day)
                        self.calendarCellViewDict[Foundation.Date.toMidnight(day, calendar: self.cal)]?.selectedDate()
                    })
                    let startOver = UIAlertAction(title: "Start Over", style: .default, handler: { [unowned self] (alertAction) in
                        self.daysLeftView.days = Double(self.streak)
                    })
                    
                    alertController.addAction(fix)
                    alertController.addAction(startOver)
                    
                    daysLeftView.days = Double(getConsecutiveDaysStartingFrom(Foundation.Date().getDaysBefore(2,calendar:cal)))
                    canDismissWithTap = false
                } else {
                    alertController.title = "You've missed \(missedDates) " + (missedDates == 1 ? "day":"days") + " . Try again!"
                    daysLeftView.days = Double(getConsecutiveDaysStartingFrom(Foundation.Date().getDaysBefore(2, calendar: cal)))
                }
                
                present(alertController, animated: true) { [unowned self] in
                    if canDismissWithTap {
                        alertController.view.superview?.isUserInteractionEnabled = true
                        alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
                    }
                }
            } else {
                daysLeftView.days = Double(streak)
            }
            
        } else {
            daysLeftView.days = Double(streak)
        }

    }
    
    @objc
    fileprivate func alertClose(_ recongizer: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        daysLeftView.days = Double(streak)
    }
    
    fileprivate func checkIfTaskCompleted() -> Bool {
        return tws.task.duration! != 0 && streak == tws.task.duration!
    }
    
    fileprivate func addAndSaveDate(_ dateToSave: Foundation.Date) {
        let date = Date.saveDateWithId(dateToSave, withTaskId: tws.task.primaryId as! Int, inManagedObjectContext: managedContext)
        if date != nil {
            dates?.append(date!)
        }
    }
    
    fileprivate func getMissedDates() -> Int {
        // Case 1 today/yesterday -> no missed dates
        // Case 2 yesterday no updaes -> check all
        // Case 3 empty -> no missed dates
        var dayComp = DateComponents()
        dayComp.day = -1
        let yesterday = (cal as NSCalendar).date(byAdding: dayComp, to: Foundation.Date(), options: [])!
        
        if dates.count == 0 || yesterday.isInDateList(dates, calendar: cal){
            return 0
        } else {
            var n = 0
            var dayBefore = yesterday
            //cal.dateByAddingComponents(dayComp, toDate: yesterday, options: [])!
            while !dayBefore.isInDateList(dates, calendar: cal) && ((cal as NSCalendar).compare(dayBefore, to: tws.task.startDate!, toUnitGranularity: .day) == .orderedDescending || (cal as NSCalendar).compare(dayBefore, to: tws.task.startDate!, toUnitGranularity: .day) == .orderedSame){
                dayBefore = (cal as NSCalendar).date(byAdding: dayComp, to: dayBefore, options: [])!
                n += 1
            }
            return n
        }
    }
    
    fileprivate func getConsecutiveDaysStartingFrom(_ start: Foundation.Date) -> Int {
        var n = 0
        var dayBefore = start
        while dayBefore.isInDateList(dates, calendar: cal) {
            dayBefore = dayBefore.getDaysBefore(1, calendar:cal)
            n += 1
        }
        
        return n
    }
    
    fileprivate func setupViewsOfCalendar(_ startDate: Foundation.Date) {
        let month = (cal as NSCalendar).component(NSCalendar.Unit.month, from: calendarView.currentCalendarDateSegment().startDate)
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        monthLabel.text = monthName
        
    }
    
    fileprivate func setDatetoCheck(_ date: Foundation.Date) {
        addAndSaveDate(date)
        streak  = streak + 1
        daysLeftView.days = Double(streak)
        
        if streak >= tws.task.duration as! Int {
            let alertController = UIAlertController(title: "Congratulations! You've done your task for " + String(describing: tws.task.duration!) + " consecutive days!", message: nil, preferredStyle: .alert)
            let extend = UIAlertAction(title: "Extend " + String(describing: tws.task.duration!) + " days", style: .default, handler: { [unowned self] (alertAction) in
//                Task.extendTaskDuration(self.tws.task.primaryId as! Int, withDuration: self.tws.task.duration as! Int, inMananagedObjectContext: self.managedContext)
                let extendedDuration = self.tws.task.duration as! Int * 2
                Task.updateTask(self.tws.task.primaryId as! Int, withInfo: [TaskAttributes.Duration:extendedDuration], inManagedObjectContext: self.managedContext)
                self.tws.task = Task.getTaskWithId(self.tws.task.primaryId as! Int, inManagedObjectContext: self.managedContext)!
                self.daysLeftView.duration = Double(self.tws.task.duration!)
            })
            let endTask = UIAlertAction(title: "End Task", style: .default, handler: { [unowned self] (alertAction) in
                let state = TaskStates.Complete
//                Task.updateTaskState(self.tws.task.primaryId as! Int, withState: state, inManagedObjectContext: self.managedContext)
                Task.updateTask(self.tws.task.primaryId as! Int, withInfo: [TaskAttributes.State:state], inManagedObjectContext: self.managedContext)
                if self.navigationController != nil {
                    self.navigationController!.popViewController(animated: true)
                }
                })
            
            alertController.addAction(extend)
            alertController.addAction(endTask)
            
            present(alertController, animated: true, completion: nil)
        }

    }
}

extension AdjustableCalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    // MARK - Overriden CalendarView delegate function
    func calendar(_ calendar: JTAppleCalendarView, canSelectDate date: Foundation.Date, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        return isPresentingHistory ? false : (cal as NSCalendar).compare(date, to: Foundation.Date(), toUnitGranularity: .day) == .orderedSame
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Foundation.Date, cell: JTAppleDayCellView?, cellState: CellState) {
        if !date.isInDateList(dates!, calendar: cal) {
            //(cell as! CalendarDayCellView).selectedDate()
            calendarCellViewDict[Foundation.Date.toMidnight(date, calendar: cal)]?.selectedDate()
            setDatetoCheck(date)
        }
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> (startDate: Foundation.Date, endDate: Foundation.Date, numberOfRows: Int, calendar: Calendar) {
        let firstDate = tws.task.startDate
        let secondDate = Foundation.Date()
        let numberOfRows = 6
        let aCalendar = Calendar.current
        
        return (startDate: firstDate!, endDate: secondDate, numberOfRows: numberOfRows, calendar: aCalendar)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: Foundation.Date, cellState: CellState) {
        if let cellView = cell as? CalendarDayCellView {
            cellView.setupCellBeforeDisplay(cellState, date: date, cal: cal, dates: dates, task: tws.task, isHistory: isPresentingHistory)
            calendarCellViewDict[Foundation.Date.toMidnight(date, calendar: cal)] = cell as? CalendarDayCellView
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: Foundation.Date, endingWithDate endDate: Foundation.Date) {
        setupViewsOfCalendar(startDate)
    }

}


