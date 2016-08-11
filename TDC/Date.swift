//
//  Date.swift
//  TDC-iOS
//
//  Created by Wilson Yan on 8/4/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//

import Foundation
import CoreData


class Date: NSManagedObject {
    
    class func getDatesWithId(taskId: Int, inManagedObjectContext context: NSManagedObjectContext) -> [Date] {
        if let task = Task.getTaskWithId(taskId, inManagedObjectContext: context) {
            let request = NSFetchRequest(entityName: "Date")
            request.predicate = NSPredicate(format: "task = %@", task)
            if let dates = (try? context.executeFetchRequest(request)) as? [Date] {
                return dates
            }
        }
        return [Date]()
    }
    
    class func saveDateWithId(dateToAdd: NSDate, withTaskId id: Int, inManagedObjectContext context: NSManagedObjectContext) -> Date{
        let date = NSEntityDescription.insertNewObjectForEntityForName("Date", inManagedObjectContext: context) as! Date
        date.date = dateToAdd
        date.task = Task.getTaskWithId(id, inManagedObjectContext: context)
        
        return date
    }
    
}
