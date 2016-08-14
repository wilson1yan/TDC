//
//  Task+CoreDataProperties.swift
//  TDC
//
//  Created by Wilson Yan on 8/13/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Task {

    @NSManaged var name: String?
    @NSManaged var primaryId: NSNumber?
    @NSManaged var startDate: NSDate?
    @NSManaged var state: NSNumber?
    @NSManaged var dates: NSSet?

}
