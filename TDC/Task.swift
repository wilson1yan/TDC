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
    
    class func saveTaskWithName(taskName: String, inManagedObjectContext context: NSManagedObjectContext) -> Task {
        let task = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: context) as! Task
        task.name = taskName
        task.primaryId = maxPrimaryKey(managedObjectContext: context) + 1
        task.startDate = NSDate()
        return task
    }
    
    class func getAllTasks(context: NSManagedObjectContext) -> [Task]{
        let request = NSFetchRequest(entityName: "Task")
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
