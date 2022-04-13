//
//  FoldersCoordinator.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

final class FoldersCoordinator: BaseCoordinator {
    enum Path {
        case notes(folderId: UUID)
    }
    
    override func start() {
        let foldersModel = FoldersModel(serviceLayer: serviceLocator)
        let foldersPresenter = FoldersPresenter(model: foldersModel) { path in
            switch path {
            case .notes(let folderId):
                self.startNotesCoordinator(with: folderId)
            }
        }
        
        let foldersViewController = FoldersViewController(presenter: foldersPresenter)
        foldersPresenter.viewController = foldersViewController
        
        rootViewController.pushViewController(foldersViewController, animated: true)
    }
    
    private func startNotesCoordinator(with folderId: UUID) {
        NotesTableCoordinator(rootViewController, serviceLocator: serviceLocator, folderId: folderId).start()
    }
}
