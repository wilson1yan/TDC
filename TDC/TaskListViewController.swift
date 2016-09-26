//
//  FruitsTableViewController.swift
//  ThirtyDayChallenge
//
//  Created by Wilson Yan on 6/17/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


struct TaskStates {
    static let Current = 0
    static let Failed = 1
    static let Complete = 2
}

struct DefaultsKeys {
    static let SortMethodKey = "Sort Method"
    static let SortMethodHistoryKey = "Sort Method History"
}

struct TaskWithStreak {
    var task: Task
    var streak: Int
    
    init(task:Task, streak: Int) {
        self.task = task
        self.streak = streak
    }
}


class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let ADD_NEW = "Add New"
    
    @IBOutlet weak var tableView: UITableView!
    
    var taskList = [TaskWithStreak]() {
        didSet {
            self.reloadDataAsync()
        }
    }
    var taskSelected: TaskWithStreak?
    var taskToEdit: Task?
    var taskName = ""
    
    var alertIcon = UIImage(named: "Alert Icon")
    
    var managedContext:NSManagedObjectContext!
    @IBAction func addNewTask(_ sender: AnyObject) {
        performSegue(withIdentifier: "Create New Task", sender: self)
    }
    
    
    let defaults = UserDefaults.standard
    
    struct SortByMethods {
        static let Alphabetical = "A-Z"
        static let Time = "Time"
        static let Streak = "Streak Length"
        static let ToUpdate = "Need To Update"
    }
    
    @IBAction func sortByTapped() {
        let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        
        let alphabetical = UIAlertAction(title: "A-Z", style: .default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethods.Alphabetical, forKey: DefaultsKeys.SortMethodKey)
            self.taskList.sort {$0.task.name!.localizedCompare($1.task.name!) == ComparisonResult.orderedAscending}
        }
        let time = UIAlertAction(title: "Time", style: .default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethods.Time, forKey: DefaultsKeys.SortMethodKey)
            self.taskList.sort {$0.task.startDate! < $1.task.startDate!}
        }
        let streak = UIAlertAction(title: "Streak Length", style: .default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethods.Streak, forKey: DefaultsKeys.SortMethodKey)
            self.taskList.sort {$0.streak > $1.streak}
        }
        let needToUpdate = UIAlertAction(title: "Need To Update", style: .default) { [unowned self] (action: UIAlertAction) in
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
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:  nil)
        
        alertController.addAction(alphabetical)
        alertController.addAction(time)
        alertController.addAction(streak)
        alertController.addAction(needToUpdate)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func reloadDataAsync() {
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        managedContext = appDelegate.managedObjectContext
        
        self.navigationItem.titleView = UILabel.getFittedLabelWithTitle("Current Tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red:0.00, green:0.60, blue:1.00, alpha:1.0)
            navigationBar.tintColor = UIColor.white
        }
        
        taskList = loadCurrentTasks()
        sortByCurrentMethod()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToCalendar" {
            if let destination = segue.destination as? AdjustableCalendarViewController {
                destination.tws = taskSelected
                destination.hidesBottomBarWhenPushed = true
                destination.isPresentingHistory = false
                
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        } else if segue.identifier == "Create New Task" {
            if let destination = segue.destination as? CreateNewTaskViewController {
                destination.recentViewController = self
            }
        }
//        else if segue.identifier == "Edit Task" {
//            if let destination = segue.destinationViewController as? CreateNewTaskViewController {
//                destination.recentViewController = self
//                destination.currentTask = taskToEdit
//            }
//        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        cell.taskTitle.text = taskList[(indexPath as NSIndexPath).row].task.name!
        cell.taskTitle.numberOfLines = 0
        cell.taskTitle.font = UIFont(name: "Arial", size: 25)
        cell.alertIcon.checked = taskBeenUpdatedToday(taskList[(indexPath as NSIndexPath).row].task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        taskSelected = taskList[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "ToCalendar", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let editAction = UITableViewRowAction(style: .Normal, title: "Edit") { [unowned self] (rowAction, indexPath) in
//            self.taskToEdit = self.taskList[indexPath.row].task
//            self.performSegueWithIdentifier("Edit Task", sender: self)
//        }
//        editAction.backgroundColor = UIColor.blueColor()
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { [unowned self] (rowAction, indexPath) in
            let toDelete = self.taskList[(indexPath as NSIndexPath).row].task
            Task.deleteTask(toDelete, inManagedObjectContext: self.managedContext)
            
            self.taskList.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)

        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
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
        if let method = defaults.value(forKey: DefaultsKeys.SortMethodKey) as? String {
            switch method {
            case SortByMethods.Alphabetical: taskList.sort {$0.task.name! < $1.task.name!}
            case SortByMethods.Time: taskList.sort {$0.task.startDate! < $1.task.startDate!}
            case SortByMethods.Streak: taskList.sort {$0.streak > $1.streak}
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
    
    func updateListWhenNewTask(_ task: Task?) {
        DispatchQueue.main.async { [unowned self] in
            if task != nil {
                self.taskList.append(TaskWithStreak(task: task!,streak: 0))
                self.sortByCurrentMethod()
            }
        }
    }

    let calendar = Calendar.current
    
    func taskBeenUpdatedToday(_ task: Task) -> Bool {
        let today = Foundation.Date()
        let datesUpdated = Date.getDatesWithId(task.primaryId as! Int, inManagedObjectContext: managedContext)
        
        for storedDate in datesUpdated {
            if let date = storedDate.date {
                if (calendar as NSCalendar).compare(date, to: today, toUnitGranularity: .day) == .orderedSame {
                    return true
                }
            }
        }
        return false
    }
    
    func getStreak(_ task: Task) -> Int {
        var taskDates = Date.getDatesWithId(task.primaryId as! Int, inManagedObjectContext: managedContext)
        taskDates.sort {$0.date! > $1.date!}
        var currentDate: Foundation.Date?
        
        var dayComponents = DateComponents()
        dayComponents.day = -1
        let dayBeforeToday = (calendar as NSCalendar).date(byAdding: dayComponents, to: Foundation.Date(), options: [])
        
        if taskDates.count > 0 && (calendar as NSCalendar).compare(taskDates[0].date!, to: Foundation.Date(), toUnitGranularity: .day) == .orderedSame {
            currentDate = Foundation.Date()
        } else if taskDates.count > 0 && (calendar as NSCalendar).compare(taskDates[0].date!, to: dayBeforeToday!, toUnitGranularity: .day) == .orderedSame {
            currentDate = dayBeforeToday
        } else {
            return 0
        }
        
        var streak = 0
        for date in taskDates {
            if (calendar as NSCalendar).compare(date.date!, to: currentDate!, toUnitGranularity: .day) == .orderedSame {
                streak += 1
                currentDate = (calendar as NSCalendar).date(byAdding: dayComponents, to: currentDate!, options: [])
            } else {
                break
            }
        }
        return streak
    }
    
}
