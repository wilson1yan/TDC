//
//  TaskHistoryTableViewController.swift
//  TDC
//
//  Created by Wilson Yan on 8/13/16.
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


class TaskHistoryTableViewController: UITableViewController {
    var taskList = [TaskWithStreak]() { didSet { reloadDataAsync() } }
    var taskSelected: TaskWithStreak?
    var taskName = ""
    
    var managedContext:NSManagedObjectContext!
    let defaults = UserDefaults.standard
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        taskList = loadHistory()
        
        self.navigationItem.titleView = UILabel.getFittedLabelWithTitle("History")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(red:0.00, green:0.60, blue:1.00, alpha:1.0)
            navigationBar.tintColor = UIColor.white
        }
        
        taskList = loadHistory()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToCalendarHistory" {
            if let destination = segue.destination as? AdjustableCalendarViewController {
                destination.tws = self.taskSelected
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
    
    @IBAction func sortByTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        
        let alphabetical = UIAlertAction(title: "A-Z", style: .default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethodsHistory.Alphabetical, forKey: DefaultsKeys.SortMethodHistoryKey)
            self.taskList.sort {$0.task.name! < $1.task.name!}
        }
        let time = UIAlertAction(title: "Time", style: .default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethodsHistory.Time, forKey: DefaultsKeys.SortMethodHistoryKey)
            self.taskList.sort {$0.task.startDate! < $1.task.startDate!}
        }
        let streak = UIAlertAction(title: "Streak Length", style: .default) { [unowned self] (action: UIAlertAction) in
            self.defaults.setValue(SortByMethodsHistory.Streak, forKey: DefaultsKeys.SortMethodHistoryKey)
            self.taskList.sort {$0.streak > $1.streak}
        }
        let completed = UIAlertAction(title: "Completed", style: .default) { [unowned self] (action: UIAlertAction) in
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
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:  nil)
        
        alertController.addAction(alphabetical)
        alertController.addAction(time)
        alertController.addAction(streak)
        alertController.addAction(completed)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)

    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        if let historyCell = cell as? HistoryTaskTableViewCell {
            let task = taskList[(indexPath as NSIndexPath).row].task
            historyCell.taskLabel.text = taskList[(indexPath as NSIndexPath).row].task.name!
            historyCell.isComplete = task.state == TaskStates.Complete
            return historyCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        taskSelected = taskList[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "ToCalendarHistory", sender: self)
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
    
    let calendar = Calendar.current
    
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

    func reloadDataAsync() {
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
}
