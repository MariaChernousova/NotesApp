//
//  NotesTableModel.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation
import CoreData

protocol NotesModelRepresentable: AnyObject {
    func fetchNotes(from folderId: UUID,
                    with sortingDescriptor: SortingDescriptor,
                    completionHandler: @escaping (Result<[Note], CoreDataStackError>) -> Void)
    func insertNote(with name: String,
                    to folderId: UUID,
                    completionHandler: @escaping ((Result<Bool, CoreDataStackError>) -> Void))
    func delete(noteId: UUID,
                from folderId: UUID,
                completionHandler: @escaping ((Result<Bool, CoreDataStackError>) -> Void))
}

final class NotesTableModel: NotesModelRepresentable {
    typealias Context = CoreDataStackHolder
    
    private let coreDataStack: CoreDataStackContext
    
    init(serviceLayer: Context) {
        coreDataStack = serviceLayer.coreDataStack
    }
    
    func fetchNotes(from folderId: UUID,
                    with sortingDescriptor: SortingDescriptor,
                    completionHandler: @escaping (Result<[Note], CoreDataStackError>) -> Void) {
        let fetchRequest = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentFolder.id == %@",
                                             folderId.uuidString)
        if let sortDescriptor = Note.sortDescriptor(for: sortingDescriptor) {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        coreDataStack.fetch(fetchRequest: fetchRequest,
                            completionHandler: completionHandler)
    }
    
    func insertNote(with name: String,
                    to folderId: UUID,
                    completionHandler: @escaping ((Result<Bool, CoreDataStackError>) -> Void)) {
        let fetchRequest = Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@",
                                             folderId.uuidString)
        coreDataStack.fetch(fetchRequest: fetchRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let folders):
                if let firstFolder = folders.first {
                    let note = Note(context: self.coreDataStack.managedContext)
                    note.name = name
                    note.creationDate = Date()
                    note.id = UUID()
                    note.content = ""
                    note.parentFolder = firstFolder
                    self.coreDataStack.saveContext(completionHandler: completionHandler)
                } else {
                    completionHandler(.failure(.unknown))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func delete(noteId: UUID,
                from folderId: UUID,
                completionHandler: @escaping ((Result<Bool, CoreDataStackError>) -> Void)) {
        let fetchRequest = Folder.fetchRequest()
        fetchRequest.predicate =  NSPredicate(format: "id == %@",
                                    folderId.uuidString)
        coreDataStack.fetch(fetchRequest: fetchRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let folders):
                if let firstFolder = folders.first,
                   let notes = firstFolder.notes.array as? [Note],
                   let noteIndex = notes.firstIndex(where: { $0.id == noteId }) {
                    firstFolder.removeFromNotes(at: noteIndex)
                    self.coreDataStack.saveContext(completionHandler: completionHandler)
                } else {
                    completionHandler(.failure(.unknown))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
