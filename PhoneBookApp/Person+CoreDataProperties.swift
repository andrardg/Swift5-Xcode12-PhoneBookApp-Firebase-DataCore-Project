//
//  Person+CoreDataProperties.swift
//  
//
//  Created by user192493 on 6/12/21.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: Int32
    @NSManaged public var uid: String?

}
