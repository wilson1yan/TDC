//
//  Task+CoreDataProperties.swift
//  TDC
//
//  Created by Wilson Yan on 10/21/16.
//  Copyright © 2016 Wilson Yan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Task {

    @NSManaged var duration: NSNumber?
    @NSManaged var name: String?
    @NSManaged var primaryId: NSNumber?
    @NSManaged var startDate: Foundation.Date?
    @NSManaged var state: NSNumber?
    @NSManaged var endDate: Foundation.Date?
    @NSManaged var numStrikes: NSNumber?
    @NSManaged var didAlreadyDisplayMissingToday: NSNumber?
    @NSManaged var dates: NSSet?

}
