//
//  Date+CoreDataProperties.swift
//  TDC
//
//  Created by Wilson Yan on 8/10/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Date {

    @NSManaged var date: NSDate?
    @NSManaged var task: Task?

}
