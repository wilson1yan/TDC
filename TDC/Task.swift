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
    
    class func saveTaskWithName(taskName: String, inManagedObjectContext context: NSManagedObjectContext) -> Task? {
        let task = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: context) as! Task
        task.name = taskName
        task.primaryId = maxPrimaryKey(managedObjectContext: context) + 1
        task.startDate = NSDate()
        task.state = 0
        
        do {
            try context.save()
            return task
        } catch let error {
            print("Core Data Error: \(error)")
        }
        
        return nil
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
