//
//  FoldersModel.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation
import CoreData

protocol FoldersModelRepresentable: AnyObject {
    func fetchedResultController(for sortingDescriptor: SortingDescriptor) -> NSFetchedResultsController<Folder>
    func insertFolder(with title: String,
                      completionHandler: @escaping ((Result<Bool, CoreDataStackError>) -> Void))
    func delete(folder: Folder,
                completionHandler: @escaping (Result<Bool, CoreDataStackError>) -> Void)
    func updateFolder(folder: Folder,
                      with newTitle: String,
                      completionHandler: @escaping ((Result<Bool, CoreDataStackError>) -> Void))
}

final class FoldersModel: FoldersModelRepresentable {
    typealias Context = CoreDataStackHolder
    
    private let coreDataStack: CoreDataStackContext
    
    private lazy var fetchedResultController: NSFetchedResultsController<Folder> = {
        let fetchRequest = Folder.fetchRequest()
        if let sortDescriptor = Folder.sortDescriptor(for: .byName) {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        let fetchedResultController =
        NSFetchedResultsController<Folder>(fetchRequest: fetchRequest,
                                           managedObjectContext: coreDataStack.managedContext,
                                           sectionNameKeyPath: nil,
                                           cacheName: nil)
        return fetchedResultController
    }()
    
    init(serviceLayer: Context) {
        coreDataStack = serviceLayer.coreDataStack
    }
    
    func fetchedResultController(for sortingDescriptor: SortingDescriptor) -> NSFetchedResultsController<Folder> {
        if let sortDescriptor = Folder.sortDescriptor(for: sortingDescriptor) {
            fetchedResultController.fetchRequest.sortDescriptors = [sortDescriptor]
        }
        return fetchedResultController
    }
    
    func insertFolder(with title: String,
                      completionHandler: @escaping ((Result<Bool, CoreDataStackError>) -> Void)) {
        let folder = Folder(context: coreDataStack.managedContext)
        folder.title = title
        folder.creationDate = Date()
        folder.id = UUID()
        
        coreDataStack.saveContext(completionHandler: completionHandler)
    }
    
    func delete(folder: Folder,
                completionHandler: @escaping (Result<Bool, CoreDataStackError>) -> Void) {
        coreDataStack.delete(managedObject: folder,
                             completionHandler: completionHandler)
    }
    
    func deleteFolder(with id: UUID,
                      completionHandler: @escaping ((Result<Int, CoreDataStackError>) -> Void)) {
        coreDataStack.delete(fetchRequest: Folder.fetchRequest(),
                             predicate: NSPredicate(format: "id == %@", id.uuidString),
                             completionHandler: completionHandler)
    }
    
    func updateFolder(folder: Folder,
                      with newTitle: String,
                      completionHandler: @escaping ((Result<Bool, CoreDataStackError>) -> Void)) {
        folder.title = newTitle
        coreDataStack.saveContext(completionHandler: completionHandler)
    }
}
