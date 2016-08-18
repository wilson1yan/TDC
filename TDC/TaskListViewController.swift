//
//  FruitsTableViewController.swift
//  ThirtyDayChallenge
//
//  Created by Wilson Yan on 6/17/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit
import CoreData

struct TaskStates {
    static let Current = 0
    static let Failed = 1
    static let Complete = 2
}

struct DefaultsKeys {
    static let SortMethodKey = "Sort Method"
}

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let ADD_NEW = "Add New"
    
    @IBOutlet weak var tableView: UITableView!
    
    var taskList = [TaskWithStreak]() {
        didSet {
            self.reloadDataAsync()
        }
    }
    var taskSelected: Task?
    var taskToEdit: Task?
    var taskName = ""
    
    var alertIcon = UIImage(named: "Alert Icon")
    
    var managedContext:NSManagedObjectContext!
    @IBAction func addNewTask(sender: AnyObject) {
        performSegueWithIdentifier("Create New Task", sender: self)
    }
    
    struct TaskWithStreak {
        var task: Task
        var streak: Int
        
        init(task:Task, streak: Int) {
            self.task = task
            self.streak = streak
        }
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    struct SortByMethods {
        static let Alphabetical = "A-Z"
        static let Time = "Time"
        static let Streak = "Streak Length"
        static let ToUpdate = "Need To Update"
    }
    
    @IBAction func sortByTapped() {
        let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .ActionSheet)
        
        let alphabetical = UIAlertAction(title: "A-Z", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethods.Alphabetical, forKey: DefaultsKeys.SortMethodKey)
            self.taskList.sortInPlace {$0.task.name! < $1.task.name!}
        }
        let time = UIAlertAction(title: "Time", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethods.Time, forKey: DefaultsKeys.SortMethodKey)
            self.taskList.sortInPlace {$0.task.startDate! < $1.task.startDate!}
        }
        let streak = UIAlertAction(title: "Streak Length", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethods.Streak, forKey: DefaultsKeys.SortMethodKey)
            self.taskList.sortInPlace {$0.streak > $1.streak}
        }
        let needToUpdate = UIAlertAction(title: "Need To Update", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethods.ToUpdate, forKey: DefaultsKeys.SortMethodKey)
            var toUpdate = [TaskWithStreak]()
            var updated = [TaskWithStreak]()
            
            self.taskList.forEach({ (tws) in
                if self.taskBeenUpdatedToday(tws.task) {
                    updated.append(tws)
                } else {
                    toUpdate.append(tws)
                }
            })
            
            self.taskList = toUpdate + updated
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler:  nil)
        
        alertController.addAction(alphabetical)
        alertController.addAction(time)
        alertController.addAction(streak)
        alertController.addAction(needToUpdate)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func reloadDataAsync() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        
        managedContext = appDelegate.managedObjectContext
//        taskList = loadCurrentTasks()
//        sortByCurrentMethod()
        
        self.title = "Current Tasks"
    }
    
    override func viewWillAppear(animated: Bool) {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red:0.00, green:0.60, blue:1.00, alpha:1.0)
            navigationBar.tintColor = UIColor.whiteColor()
        }
        
        taskList = loadCurrentTasks()
        sortByCurrentMethod()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToCalendar" {
            if let destination = segue.destinationViewController as? CalendarViewController {
                destination.task = self.taskSelected
                destination.hidesBottomBarWhenPushed = true
            }
        } else if segue.identifier == "Create New Task" {
            if let destination = segue.destinationViewController as? CreateNewTaskViewController {
                destination.recentViewController = self
            }
        } else if segue.identifier == "Edit Task" {
            if let destination = segue.destinationViewController as? CreateNewTaskViewController {
                destination.recentViewController = self
                destination.currentTask = taskToEdit
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskTableViewCell
        cell.taskTitle.text = taskList[indexPath.row].task.name!
        cell.alertIcon.checked = taskBeenUpdatedToday(taskList[indexPath.row].task)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        taskSelected = taskList[indexPath.row].task
        performSegueWithIdentifier("ToCalendar", sender: self)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit") { [unowned self] (rowAction, indexPath) in
            self.taskToEdit = self.taskList[indexPath.row].task
            self.performSegueWithIdentifier("Edit Task", sender: self)
        }
        editAction.backgroundColor = UIColor.blueColor()
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { [unowned self] (rowAction, indexPath) in
            let toDelete = self.taskList[indexPath.row].task
            Task.deleteTask(toDelete, inManagedObjectContext: self.managedContext)
            
            self.taskList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

        }
        deleteAction.backgroundColor = UIColor.redColor()
        return [editAction, deleteAction]
    }
    
    //MARK - Other Functions
    
    func loadCurrentTasks() -> [TaskWithStreak]{
        let tasks = Task.getAllTasksWithState(TaskStates.Current, inManagedObjectContext: managedContext)
        var taskStreakList = [TaskWithStreak]()
        for task in tasks {
            taskStreakList.append(TaskWithStreak(task: task, streak: getStreak(task)))
        }
        
        return taskStreakList
    }
    
    func sortByCurrentMethod() {
        if let method = defaults.valueForKey(DefaultsKeys.SortMethodKey) as? String {
            switch method {
            case SortByMethods.Alphabetical: taskList.sortInPlace {$0.task.name! < $1.task.name!}
            case SortByMethods.Time: taskList.sortInPlace {$0.task.startDate! < $1.task.startDate!}
            case SortByMethods.Streak: taskList.sortInPlace {$0.streak > $1.streak}
            case SortByMethods.ToUpdate:
                var toUpdate = [TaskWithStreak]()
                var updated = [TaskWithStreak]()
                
                taskList.forEach({ (tws) in
                    if self.taskBeenUpdatedToday(tws.task) {
                        updated.append(tws)
                    } else {
                        toUpdate.append(tws)
                    }
                })
                
                taskList = toUpdate + updated
                
            default: break
            }
        }

    }
    
    func updateListWhenNewTask(task: Task?) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            if task != nil {
                self.taskList.append(TaskWithStreak(task: task!,streak: 0))
                self.sortByCurrentMethod()
            }
        }
    }

    let calendar = NSCalendar.currentCalendar()
    
    func taskBeenUpdatedToday(task: Task) -> Bool {
        let today = NSDate()
        let datesUpdated = Date.getDatesWithId(task.primaryId as! Int, inManagedObjectContext: managedContext)
        
        for storedDate in datesUpdated {
            if let date = storedDate.date {
                if calendar.compareDate(date, toDate: today, toUnitGranularity: .Day) == .OrderedSame {
                    return true
                }
            }
        }
        return false
    }
    
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
    
}
