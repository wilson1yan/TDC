//
//  FruitsTableViewController.swift
//  ThirtyDayChallenge
//
//  Created by Wilson Yan on 6/17/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {    
    let ADD_NEW = "Add New"
    
    var tasksInGroups = [[Task]]()
    var taskSelected: Task?
    var taskName = ""
    
    var alertIcon = UIImage(named: "Alert Icon")
    
    var managedContext:NSManagedObjectContext!
    
    @IBAction func addNewTask(sender: AnyObject) {
        showAlert()
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        tasksInGroups = separateTaskListToGroups(Task.getAllTasks(managedContext))
    }
    
    override func viewWillAppear(animated: Bool) {
        tasksInGroups = separateTaskListToGroups(Task.getAllTasks(managedContext))
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToCalendar" {
            if let destination = segue.destinationViewController as? CalendarViewController {
                destination.task = self.taskSelected
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskTableViewCell
        cell.taskTitle.text = tasksInGroups[indexPath.section][indexPath.row].name!
        cell.alertIcon.image = nil
        if indexPath.section == 0 {
            cell.alertIcon.image = alertIcon!
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && tasksInGroups[0].count > 0{
            return "Need to Update"
        } else if section == 1 && tasksInGroups[1].count > 0{
            return "Updated"
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        taskSelected = tasksInGroups[indexPath.section][indexPath.row]
        performSegueWithIdentifier("ToCalendar", sender: self)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let toDelete = tasksInGroups[indexPath.section][indexPath.row]
            managedContext!.deleteObject(toDelete)
            do{
                try managedContext.save()
            } catch let error as NSError {
                print(error)
            }
            
            tasksInGroups[indexPath.section].removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    //MARK - Other Functions
    
    func showAlert(){
        let alertController = UIAlertController(title: "Add New Task", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {
            [unowned self] alert -> Void in
            
            let textField = alertController.textFields![0] as UITextField
            let task = Task.saveTaskWithName(textField.text!, inManagedObjectContext: self.managedContext)
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                if task != nil {
                    self.tasksInGroups[0].append(task!)
                    self.tableView.reloadData()
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter New Task"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func separateTaskListToGroups(taskList: [Task]) -> [[Task]] {
        var tasksInGroups = [[Task](),[Task]()]
        for task in taskList {
            if taskBeenUpdatedToday(task) {
                tasksInGroups[1].append(task)
            } else {
                tasksInGroups[0].append(task)
            }
        }
        
        return tasksInGroups
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
    
}
