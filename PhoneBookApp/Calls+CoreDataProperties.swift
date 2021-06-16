//
//  Calls+CoreDataProperties.swift
//  
//
//  Created by user192493 on 6/12/21.
//
//

import Foundation
import CoreData


extension Calls {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Calls> {
        return NSFetchRequest<Calls>(entityName: "Calls")
    }

    @NSManaged public var date: String?
    @NSManaged public var idCall: Int32
    @NSManaged public var idCaller: String?
    @NSManaged public var namePerson: String?

}
