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
    var tasksInGroups = [[Task]]()
    var taskSelected: Task?
    var taskName = ""
    
    var managedContext:NSManagedObjectContext!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        tasksInGroups = loadHistory()
        
        self.title = "History"
    }
    
    override func viewWillAppear(animated: Bool) {
        tasksInGroups = loadHistory()
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToCalendarHistory" {
            if let destination = segue.destinationViewController as? CalendarViewController {
                destination.task = self.taskSelected
                destination.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tasksInGroups.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksInGroups[section].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath)
        cell.textLabel?.text = tasksInGroups[indexPath.section][indexPath.row].name!
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && tasksInGroups[0].count > 0{
            return "Completed"
        } else if section == 1 && tasksInGroups[1].count > 0{
            return "Failed"
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        taskSelected = tasksInGroups[indexPath.section][indexPath.row]
        performSegueWithIdentifier("ToCalendarHistory", sender: self)
    }
    
    //MARK - Other Functions

    func loadHistory() -> [[Task]]{
        var tasks = [[Task]]()
        tasks.append(Task.getAllTasksWithState(TaskStates.Complete, inManagedObjectContext: managedContext))
        tasks.append(Task.getAllTasksWithState(TaskStates.Failed, inManagedObjectContext: managedContext))
        
        return tasks
    }
    
}
