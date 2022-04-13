//
//  CoreDataStack.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation
import CoreData

protocol CoreDataStackContext {
    var managedContext: NSManagedObjectContext { get }
    
    func fetch<T: NSFetchRequestResult>(fetchRequest: NSFetchRequest<T>,
                                        completionHandler: @escaping (Result<[T], CoreDataStackError>) -> Void)
    func delete(managedObject: NSManagedObject,
                completionHandler: @escaping (Result<Bool, CoreDataStackError>) -> Void)
    func delete(fetchRequest: NSFetchRequest<NSFetchRequestResult>,
                predicate: NSPredicate,
                completionHandler: @escaping (Result<Int, CoreDataStackError>) -> Void)
    func update(entity: NSEntityDescription,
                predicate: NSPredicate,
                propertiesToUpdate: [String: String],
                completionHandler: @escaping (Result<Bool, CoreDataStackError>) -> Void)
    func saveContext(completionHandler: ((Result<Bool, CoreDataStackError>) -> Void)?)
}

enum CoreDataStackError: Error {
    case unknown
    case error(NSError)
}

final class CoreDataStack: CoreDataStackContext {
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var managedContext = storeContainer.viewContext
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func fetch<T: NSFetchRequestResult>(fetchRequest: NSFetchRequest<T>,
                                        completionHandler: @escaping (Result<[T], CoreDataStackError>) -> Void) {
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { fetchRequest in
                DispatchQueue.main.async {
                if let finalResult = fetchRequest.finalResult {
                    completionHandler(.success(finalResult))
                } else {
                    completionHandler(.failure(.unknown))
                }
            }
        }
        
        do {
            try managedContext.execute(asynchronousFetchRequest)
        } catch let error as NSError {
            completionHandler(.failure(.error(error)))
        }
    }
    
    func delete(managedObject: NSManagedObject,
                completionHandler: @escaping (Result<Bool, CoreDataStackError>) -> Void) {
        managedContext.delete(managedObject)
        saveContext(completionHandler: completionHandler)
    }
    
    func delete(fetchRequest: NSFetchRequest<NSFetchRequestResult>,
                predicate: NSPredicate,
                completionHandler: @escaping (Result<Int, CoreDataStackError>) -> Void) {
        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeCount
        
        do {
            let deletedCount = try managedContext.execute(batchDeleteRequest) as! NSBatchDeleteResult
            completionHandler(.success(deletedCount.result as! Int))
        } catch let error as NSError {
            completionHandler(.failure(.error(error)))
        }
    }
    
    func update(entity: NSEntityDescription,
                predicate: NSPredicate,
                propertiesToUpdate: [String: String],
                completionHandler: @escaping (Result<Bool, CoreDataStackError>) -> Void) {
        let batchUpdateRequest = NSBatchUpdateRequest(entity: entity)
        batchUpdateRequest.predicate = predicate
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        do {
            let batchUpdateResult = try managedContext
                .execute(batchUpdateRequest) as? NSBatchUpdateResult
            
            let managedObjectIDs = batchUpdateResult?.result as? [NSManagedObjectID]
            
            if let firstManagedObjectId = managedObjectIDs?.first {
                let object = try managedContext
                    .existingObject(with: firstManagedObjectId)
                managedContext.refresh(object, mergeChanges: true)
            }
            completionHandler(.success(true))
        } catch let error as NSError {
            completionHandler(.failure(.error(error)))
        }
    }
    
    func saveContext(completionHandler: ((Result<Bool, CoreDataStackError>) -> Void)?) {
        guard managedContext.hasChanges else { return }
        
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = managedContext
        
        do {
            try privateManagedObjectContext.save()
            managedContext.performAndWait {
                do {
                    try self.managedContext.save()
                    DispatchQueue.main.async {
                        completionHandler?(.success(true))
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        completionHandler?(.failure(.error(error)))
                    }
                }
            }
        } catch let error as NSError {
            completionHandler?(.failure(.error(error)))
        }
    }
}


