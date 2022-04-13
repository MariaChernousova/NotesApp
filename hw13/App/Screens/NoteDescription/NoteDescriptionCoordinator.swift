//
//  NoteDescriptionCoordinator .swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

final class NoteDescriptionCoordinator: BaseCoordinator {
    private let note: Note
    
    init(_ rootViewController: UINavigationController, serviceLocator: ServiceLocator, note: Note) {
        self.note = note
        super.init(rootViewController, serviceLocator: serviceLocator)
    }
    
    override func start() {
        let noteDescriptionModel = NoteDescriptionModel(serviceLayer: serviceLocator)
        let noteDescriptionPresenter = NoteDescriptionPresenter(note: note, model: noteDescriptionModel)
        let noteDescriptionViewController = NoteDescriptionViewController(presenter: noteDescriptionPresenter)
        noteDescriptionPresenter.viewController = noteDescriptionViewController
        
        rootViewController.pushViewController(noteDescriptionViewController, animated: true)
    }
    
}
