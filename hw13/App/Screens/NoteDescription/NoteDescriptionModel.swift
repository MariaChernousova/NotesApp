//
//  NoteDescriptionModel.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation
import CoreData

protocol NoteDescriptionModelRepresentable: AnyObject {
    func save()
}

final class NoteDescriptionModel: NoteDescriptionModelRepresentable {
    typealias Context = CoreDataStackHolder
    
    private let coreDataStack: CoreDataStackContext
    
    init(serviceLayer: Context) {
        coreDataStack = serviceLayer.coreDataStack
    }
    
    func save() {
        coreDataStack.saveContext(completionHandler: nil)
    }
}

