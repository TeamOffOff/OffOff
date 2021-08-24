//
//  WorkRoutine+CoreDataProperties.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/24.
//
//

import Foundation
import CoreData


extension WorkRoutine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkRoutine> {
        return NSFetchRequest<WorkRoutine>(entityName: "WorkRoutine")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?

}
