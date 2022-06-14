//
//  ToDoListItem+CoreDataProperties.swift
//  ToDoList
//
//  Created by Deka Primatio on 30/05/22.
//
//

import Foundation
import CoreData

// Fetch Attribute dari Core Data
extension ToDoListItem {
    // FetchRequest dari CoreData
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }
    
    // Atrribute Core Data
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
}

extension ToDoListItem : Identifiable {

}
