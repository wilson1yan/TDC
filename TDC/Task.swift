//
//  Task.swift
//  TDC-iOS
//
//  Created by Wilson Yan on 8/4/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import Foundation
import CoreData


class Task: NSManagedObject {
    
    class func saveTask(taskName: String, duration: Int, inManagedObjectContext context: NSManagedObjectContext) -> Task? {
        let task = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: context) as! Task
        task.name = taskName
        task.primaryId = maxPrimaryKey(managedObjectContext: context) + 1
        task.startDate = NSDate()
        task.state = 0
        task.duration = duration
        
        do {
            try context.save()
            return task
        } catch let error {
            print("Core Data Error: \(error)")
        }
        
        return nil
    }
    
    class func deleteTask(task: Task, inManagedObjectContext context: NSManagedObjectContext) {
        context.deleteObject(task)
        do{
            try context.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
    class func updateEditedTask(primaryId: Int, withTaskName taskName: String, withDuration duration: Int, inManagedObjectContext context: NSManagedObjectContext) {
        let task = getTaskWithId(primaryId, inManagedObjectContext: context)
        if let t = task {
            t.name = taskName
            t.duration = duration
            do{
                try context.save()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    class func getAllTasksWithState(state: Int, inManagedObjectContext context: NSManagedObjectContext) -> [Task]{
        let request = NSFetchRequest(entityName: "Task")
        request.predicate = NSPredicate(format: "state = %d", state)
        if let tasks = (try? context.executeFetchRequest(request)) as? [Task] {
            return tasks
        } else {
            return [Task]()
        }
    }
    
    class func getTaskWithId(primaryId: Int, inManagedObjectContext context: NSManagedObjectContext) -> Task? {
        let request = NSFetchRequest(entityName: "Task")
        request.predicate = NSPredicate(format: "primaryId = %d", primaryId)
        return (try? context.executeFetchRequest(request))?.first as? Task
    }
    
    class func maxPrimaryKey(managedObjectContext context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest(entityName: "Task")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "primaryId", ascending: false)]
        if let task = (try? context.executeFetchRequest(request))?.first as? Task {
            return task.primaryId! as Int
        } else {
            return 0
        }
    }
    
}
