//
//  TaskHistoryTableViewController.swift
//  TDC
//
//  Created by Wilson Yan on 8/13/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit
import CoreData

class TaskHistoryTableViewController: UITableViewController {
    var taskList = [TaskWithStreak]() { didSet { reloadDataAsync() } }
    var taskSelected: Task?
    var taskName = ""
    
    var managedContext:NSManagedObjectContext!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        taskList = loadHistory()
        
        self.title = "History"
    }
    
    override func viewWillAppear(animated: Bool) {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red:0.00, green:0.60, blue:1.00, alpha:1.0)
            navigationBar.tintColor = UIColor.whiteColor()
        }
        
        taskList = loadHistory()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToCalendarHistory" {
            if let destination = segue.destinationViewController as? CalendarViewController {
                destination.task = self.taskSelected
                destination.hidesBottomBarWhenPushed = true
                destination.isPresentingHistory = true
            }
        }
    }
    
    // MARK: - IBAction
    
    struct SortByMethodsHistory {
        static let Alphabetical = "A-Z"
        static let Time = "Time"
        static let Streak = "Streak Length"
        static let Completed = "Completed"
    }
    
    @IBAction func sortByTapped(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .ActionSheet)
        
        let alphabetical = UIAlertAction(title: "A-Z", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethodsHistory.Alphabetical, forKey: DefaultsKeys.SortMethodHistoryKey)
            self.taskList.sortInPlace {$0.task.name! < $1.task.name!}
        }
        let time = UIAlertAction(title: "Time", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethodsHistory.Time, forKey: DefaultsKeys.SortMethodHistoryKey)
            self.taskList.sortInPlace {$0.task.startDate! < $1.task.startDate!}
        }
        let streak = UIAlertAction(title: "Streak Length", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethodsHistory.Streak, forKey: DefaultsKeys.SortMethodHistoryKey)
            self.taskList.sortInPlace {$0.streak > $1.streak}
        }
        let completed = UIAlertAction(title: "Completed", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethodsHistory.Completed, forKey: DefaultsKeys.SortMethodHistoryKey)
            var completed = [TaskWithStreak]()
            var failed = [TaskWithStreak]()
            
            self.taskList.forEach({ (tws) in
                if tws.task.state! == TaskStates.Complete {
                    completed.append(tws)
                } else {
                    failed.append(tws)
                }
            })
            
            self.taskList = completed + failed
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler:  nil)
        
        alertController.addAction(alphabetical)
        alertController.addAction(time)
        alertController.addAction(streak)
        alertController.addAction(completed)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true, completion: nil)

    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath)
        if let historyCell = cell as? HistoryTaskTableViewCell {
            let task = taskList[indexPath.row].task
            historyCell.taskLabel.text = taskList[indexPath.row].task.name!
            historyCell.isComplete = task.state == TaskStates.Complete
            return historyCell
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        taskSelected = taskList[indexPath.row].task
        performSegueWithIdentifier("ToCalendarHistory", sender: self)
    }
    
    //MARK - Other Functions

    func loadHistory() -> [TaskWithStreak]{
        let completed = Task.getAllTasksWithState(TaskStates.Complete, inManagedObjectContext: managedContext)
        let failed = Task.getAllTasksWithState(TaskStates.Failed, inManagedObjectContext: managedContext)
        
        var taskStreakList = [TaskWithStreak]()
        for task in completed + failed {
            taskStreakList.append(TaskWithStreak(task: task, streak: getStreak(task)))
        }

        
        return taskStreakList
    }
    
    let calendar = NSCalendar.currentCalendar()
    
    func getStreak(task: Task) -> Int {
        var taskDates = Date.getDatesWithId(task.primaryId as! Int, inManagedObjectContext: managedContext)
        taskDates.sortInPlace {$0.date! > $1.date!}
        var currentDate: NSDate?
        
        let dayComponents = NSDateComponents()
        dayComponents.day = -1
        let dayBeforeToday = calendar.dateByAddingComponents(dayComponents, toDate: NSDate(), options: [])
        
        if taskDates.count > 0 && calendar.compareDate(taskDates[0].date!, toDate: NSDate(), toUnitGranularity: .Day) == .OrderedSame {
            currentDate = NSDate()
        } else if taskDates.count > 0 && calendar.compareDate(taskDates[0].date!, toDate: dayBeforeToday!, toUnitGranularity: .Day) == .OrderedSame {
            currentDate = dayBeforeToday
        } else {
            return 0
        }
        
        var streak = 0
        for date in taskDates {
            if calendar.compareDate(date.date!, toDate: currentDate!, toUnitGranularity: .Day) == .OrderedSame {
                streak += 1
                currentDate = calendar.dateByAddingComponents(dayComponents, toDate: currentDate!, options: [])
            } else {
                break
            }
        }
        return streak
    }

    func reloadDataAsync() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
}
