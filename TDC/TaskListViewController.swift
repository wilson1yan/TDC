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
    
    var tasks = [Task]()
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
        tasks = Task.getAllTasks(managedContext)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToCalendar" {
            if let destination = segue.destinationViewController as? CalendarViewController {
                destination.task = self.taskSelected
            }
        }
    }
    
    // MARK: - Table view data source
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskTableViewCell
        cell.taskTitle.text = tasks[indexPath.row].name!
        cell.alertIcon.image = alertIcon!
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        taskSelected = tasks[indexPath.row]
        performSegueWithIdentifier("ToCalendar", sender: self)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let toDelete = tasks[indexPath.row]
            managedContext!.deleteObject(toDelete)
            do{
                try managedContext.save()
            } catch let error as NSError {
                print(error)
            }
            
            tasks.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func showAlert(){
        let alertController = UIAlertController(title: "Add New Task", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {
            alert -> Void in
            
            let textField = alertController.textFields![0] as UITextField
            self.saveTaskName(textField.text!)
            self.tableView.reloadData()
            
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
    
    func saveTaskName(name: String){
        let t = Task.saveTaskWithName(name, inManagedObjectContext: managedContext)
        do {
            try self.managedContext?.save()
            tasks.append(t)
        } catch let error {
            print("Core Data Error: \(error)")
        }
    }
    
}
