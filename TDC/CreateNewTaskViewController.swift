//
//  CreateNewTaskViewController.swift
//  TDC
//
//  Created by Wilson Yan on 8/14/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import UIKit

class CreateNewTaskViewController: UIViewController {
    weak var recentViewController: UIViewController?
    var currentTask: Task?
    
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let task = currentTask{
            taskNameTextField.text = task.name
            durationTextField.text = String(task.duration!)
        }
    }
    
    @IBAction func save() {
        if let tlvc = recentViewController as? TaskListViewController{
            if let duration = Int(durationTextField.text!), let taskName = taskNameTextField.text where duration >= 0{
                if currentTask != nil {
                    Task.updateEditedTask(currentTask!.primaryId! as Int, withTaskName: taskName, withDuration: duration, inManagedObjectContext: tlvc.managedContext)
                    tlvc.loadCurrentTasks()
                } else {
                    let task = Task.saveTask(taskName, duration: duration, inManagedObjectContext: tlvc.managedContext)
                    tlvc.updateListWhenNewTask(task)
                }
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                errorText.text = "Invalid duration. Must be a whole number"
            }
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
