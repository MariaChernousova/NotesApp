//
//  NotesTableCoordinator.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

final class NotesTableCoordinator: BaseCoordinator {
    enum Path {
        case noteContent(note: Note)
    }
    
    private let folderId: UUID

    init(_ rootViewController: UINavigationController, serviceLocator: ServiceLocator, folderId: UUID) {
        self.folderId = folderId
        super.init(rootViewController, serviceLocator: serviceLocator)
    }
    
    override func start() {
        let notesModel = NotesTableModel(serviceLayer: serviceLocator)
        let notesPresenter = NotesTablePresenter(folderId: folderId, model: notesModel) { path in
            switch path {
            case .noteContent(let note):
                self.startNoteContentCoordinator(with: note)
            }
        }
        
        let notesViewController = NotesTableViewController(presenter: notesPresenter)
        notesPresenter.viewController = notesViewController
        
        rootViewController.pushViewController(notesViewController, animated: true)
    }
    
    private func startNoteContentCoordinator(with note: Note) {
        NoteDescriptionCoordinator(rootViewController, serviceLocator: serviceLocator, note: note).start()
    }
}
