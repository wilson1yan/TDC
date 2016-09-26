//
//  Task.swift
//  TDC-iOS
//
//  Created by Wilson Yan on 8/4/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import Foundation
import CoreData

struct DidDisplayMissingTodayStates {
    static let YES = 1
    static let NO = 0
}

struct TaskAttributes {
    static let Name = "name"
    static let State = "state"
    static let Duration = "duration"
    static let DidAlreadyDisplayMissingToday = "didAlready"
    static let NumStrikes = "numStrikes"
}

class Task: NSManagedObject {
    
    class func saveTask(_ taskName: String, duration: Int, inManagedObjectContext context: NSManagedObjectContext) -> Task? {
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context) as! Task
        task.name = taskName
        task.primaryId = (maxPrimaryKey(managedObjectContext: context) + 1) as NSNumber
        task.startDate = Foundation.Date()
        task.state = 0
        task.duration = duration as NSNumber?
        task.didAlreadyDisplayMissingToday = DidDisplayMissingTodayStates.NO as NSNumber?
        task.numStrikes = 0
        
        do {
            try context.save()
            return task
        } catch let error {
            print("Core Data Error: \(error)")
        }
        
        return nil
    }
    
    class func deleteTask(_ task: Task, inManagedObjectContext context: NSManagedObjectContext) {
        context.delete(task)
        do{
            try context.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
//    class func updateEditedTask(primaryId: Int, withName taskName: String, inManagedObjectContext context: NSManagedObjectContext) {
//        let task = getTaskWithId(primaryId, inManagedObjectContext: context)
//        if let t = task {
//            t.name = taskName
//            do{ try context.save() } catch _ as NSError {}
//        }
//    }
//    
//    class func updateTaskState(primaryId: Int, withState state: Int, inManagedObjectContext context: NSManagedObjectContext) {
//        let task = getTaskWithId(primaryId, inManagedObjectContext: context)
//        if let t = task {
//            t.state = state
//            do{ try context.save() } catch _ as NSError {}
//        }
//    }
//    
//    class func extendTaskDuration(primaryId: Int, withDuration duration: Int, inMananagedObjectContext context: NSManagedObjectContext) {
//        let task = getTaskWithId(primaryId, inManagedObjectContext: context)
//        if let t = task {
//            t.duration = t.duration as! Int + duration
//            do{ try context.save() } catch _ as NSError {}
//        }
//    }
    
    class func updateTask(_ primaryId: Int, withInfo info: Dictionary<String, AnyObject>, inManagedObjectContext context: NSManagedObjectContext) {
        let task = getTaskWithId(primaryId, inManagedObjectContext: context)
        if task != nil {
            for (key,value) in info {
                switch key {
                case TaskAttributes.Name: task!.name = (value as! String); print(value)
                case TaskAttributes.Duration: task!.duration = (value as! NSNumber); print(value)
                case TaskAttributes.State: task!.state = (value as! NSNumber); print(value)
                case TaskAttributes.DidAlreadyDisplayMissingToday: task!.didAlreadyDisplayMissingToday = (value as! NSNumber); print(value)
                case TaskAttributes.NumStrikes: task!.numStrikes = (value as! NSNumber); print(value)
                default: break
                }
            }
            do { try context.save() } catch _ as NSError {}
        }
    }
    
    class func getAllTasksWithState(_ state: Int, inManagedObjectContext context: NSManagedObjectContext) -> [Task]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "state = %d", state)
        if let tasks = (try? context.fetch(request)) as? [Task] {
            return tasks
        } else {
            return [Task]()
        }
    }
    
    class func getTaskWithId(_ primaryId: Int, inManagedObjectContext context: NSManagedObjectContext) -> Task? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "primaryId = %d", primaryId)
        return (try? context.fetch(request))?.first as? Task
    }
    
    class func maxPrimaryKey(managedObjectContext context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "primaryId", ascending: false)]
        if let task = (try? context.fetch(request))?.first as? Task {
            return task.primaryId! as Int
        } else {
            return 0
        }
    }
    
}
