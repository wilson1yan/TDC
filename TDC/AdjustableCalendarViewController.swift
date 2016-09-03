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

class AdjustableCalendarViewController: CalendarViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var updateButton: UIBarButtonItem!

    // MARK - View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButton.enabled = !isPresentingHistory
        if isPresentingHistory {
            updateButton.tintColor = UIColor.clearColor()
            configueViewsIfMissedDates()
        } else {
            daysLeftView.days = Double(tws.streak)
        }
    }
    
    
    // MARK - IBAction
    @IBAction func moreOptions(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .ActionSheet)
        
        let editTask = UIAlertAction(title: "Edit Task", style: .Default) { [unowned self] (alertAction) in
            let editController = UIAlertController(title: "New Task Name", message: nil, preferredStyle: .Alert)
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {
                alert -> Void in
                let textField = editController.textFields![0] as UITextField
                let newTaskName = textField.text != nil ? textField.text! : ""
                Task.updateEditedTask(self.tws.task.primaryId as! Int, withName: newTaskName, inManagedObjectContext: self.managedContext)
                self.title = newTaskName
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            
            editController.addTextFieldWithConfigurationHandler { [unowned self] (textField : UITextField!) -> Void in
                textField.text = self.tws.task.name!
                textField.placeholder = "New Task Name"
            }
            
            editController.addAction(saveAction)
            editController.addAction(cancelAction)
            
            self.presentViewController(editController, animated: true, completion: nil)
        }
        //        let endTask = UIAlertAction(title: "End Task", style: .Destructive) { [unowned self] (alertAction) in
        //            let state = self.streak == self.tws.task.duration ? TaskStates.Complete : TaskStates.Failed
        //            Task.updateTaskState(self.tws.task.primaryId as! Int, withState: state, inManagedObjectContext: self.managedContext)
        //        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(editTask)
        //alertController.addAction(endTask)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK - Custom API
    private func configueViewsIfMissedDates() {
        let missedDates = getMissedDates()
        if missedDates > 0 {
            let consecDays = getConsecutiveDaysStartingFrom(NSDate().getDaysBefore(2, calendar:cal))
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
            if missedDates == 1 && consecDays >= 5{
                alertController.title = "You've missed a day. I'll trust it's just an honest mistake."
                let fix = UIAlertAction(title: "Fix It", style: .Default, handler: { [unowned self](alertAction) in
                    //update stuff
                    })
                let startOver = UIAlertAction(title: "Start Over", style: .Default, handler: { [unowned self] (alertAction) in
                    self.daysLeftView.days = Double(self.streak!)
                    })
                
                alertController.addAction(fix)
                alertController.addAction(startOver)
                
                daysLeftView.days = Double(getConsecutiveDaysStartingFrom(NSDate().getDaysBefore(2,calendar:cal)))
            } else {
                alertController.title = "You've missed \(missedDates) " + (missedDates == 1 ? "day":"days") + " . Try again!"
                daysLeftView.days = Double(streak!)
            }
            
            presentViewController(alertController, animated: true, completion: { [unowned self] in
                alertController.view.superview?.userInteractionEnabled = true
                alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
                })
        } else {
            daysLeftView.days = Double(streak!)
        }

    }
    
    @objc
    private func alertClose(recongizer: UIGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func checkIfTaskCompleted() -> Bool {
        return tws.task.duration! != 0 && streak == tws.task.duration!
    }
    
    private func addAndSaveDate(dateToSave: NSDate) {
        let date = Date.saveDateWithId(dateToSave, withTaskId: tws.task.primaryId as! Int, inManagedObjectContext: managedContext)
        if date != nil {
            dates?.append(date!)
        }
    }
    
    private func getMissedDates() -> Int {
        // Case 1 today/yesterday -> no missed dates
        // Case 2 yesterday no updaes -> check all
        // Case 3 empty -> no missed dates
        let dayComp = NSDateComponents()
        dayComp.day = -1
        let yesterday = cal.dateByAddingComponents(dayComp, toDate: NSDate(), options: [])!
        
        if dates.count == 0 || yesterday.isInDateList(dates, calendar: cal){
            return 0
        } else {
            var n = 0
            var dayBefore = yesterday
            //cal.dateByAddingComponents(dayComp, toDate: yesterday, options: [])!
            while !dayBefore.isInDateList(dates, calendar: cal) && (cal.compareDate(dayBefore, toDate: tws.task.startDate!, toUnitGranularity: .Day) == .OrderedDescending || cal.compareDate(dayBefore, toDate: tws.task.startDate!, toUnitGranularity: .Day) == .OrderedSame){
                dayBefore = cal.dateByAddingComponents(dayComp, toDate: dayBefore, options: [])!
                n += 1
            }
            return n
        }
    }
    
    private func getConsecutiveDaysStartingFrom(start: NSDate) -> Int {
        var n = 0
        var dayBefore = start
        while dayBefore.isInDateList(dates, calendar: cal) {
            dayBefore = dayBefore.getDaysBefore(1, calendar:cal)
            n += 1
        }
        
        return n
    }

    
    // MARK - Overriden CalendarView delegate function
    override func calendar(calendar: JTAppleCalendarView, canSelectDate date: NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        return isPresentingHistory ? false : cal.compareDate(date, toDate: NSDate(), toUnitGranularity: .Day) == .OrderedSame
    }
    
    override func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        if !date.isInDateList(dates!, calendar: cal) {
            (cell as! CalendarDayCellView).selectedDate()
            addAndSaveDate(date)
            streak = streak! + 1
            daysLeftView.days = Double(streak!)
            daysLeftView.createAnimatedCircleMask()
            
            if streak! == tws.task.duration! {
                let alertController = UIAlertController(title: "Congratulations! You've done your task for " + String(tws.task.duration!) + " consecutive days!", message: nil, preferredStyle: .Alert)
                let extend = UIAlertAction(title: "Extend " + String(tws.task.duration!) + " days", style: .Default, handler: { [unowned self] (alertAction) in
                    Task.extendTaskDuration(self.tws.task.primaryId as! Int, withDuration: self.tws.task.duration as! Int, inMananagedObjectContext: self.managedContext)
                    self.tws.task = Task.getTaskWithId(self.tws.task.primaryId as! Int, inManagedObjectContext: self.managedContext)!
                    self.daysLeftView.duration = Double(self.tws.task.duration!)
                    
                    self.daysLeftView.createAnimatedCircleMask()
                    })
                let endTask = UIAlertAction(title: "End Task", style: .Default, handler: { [unowned self] (alertAction) in
                    let state = TaskStates.Complete
                    Task.updateTaskState(self.tws.task.primaryId as! Int, withState: state, inManagedObjectContext: self.managedContext)
                    if self.navigationController != nil {
                        self.navigationController!.popViewControllerAnimated(true)
                    }
                    })
                
                alertController.addAction(extend)
                alertController.addAction(endTask)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
        }

    }
}


