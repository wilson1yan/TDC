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
    
    class func getDatesWithId(_ taskId: Int, inManagedObjectContext context: NSManagedObjectContext) -> [Date] {
        if let task = Task.getTaskWithId(taskId, inManagedObjectContext: context) {
            let request = NSFetchRequest(entityName: "Date")
            request.predicate = NSPredicate(format: "task = %@", task)
            if let dates = (try? context.fetch(request)) as? [Date] {
                return dates
            }
        }
        return [Date]()
    }
    
    class func saveDateWithId(_ dateToAdd: Foundation.Date, withTaskId id: Int, inManagedObjectContext context: NSManagedObjectContext) -> Date? {
        let date = NSEntityDescription.insertNewObject(forEntityName: "Date", into: context) as! Date
        date.date = dateToAdd
        date.task = Task.getTaskWithId(id, inManagedObjectContext: context)
        
        do {
            try context.save()
            return date
        } catch let error {
            print("Core Data Error: \(error)")
        }
        
        return nil
    }
    
}
