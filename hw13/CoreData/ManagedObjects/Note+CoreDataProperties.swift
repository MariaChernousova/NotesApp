//
//  Note+CoreDataProperties.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String
    @NSManaged public var creationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var parentFolder: Folder?

}

extension Note : Identifiable {
}
