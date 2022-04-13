//
//  FoldersPresenter.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation
import CoreData

protocol FoldersPresentable: AnyObject {
    func didLoad()
    func sortByName()
    func sortByDate()
    
    func numberOfRows() -> Int
    func folder(for indexPath: IndexPath) -> FolderAdapter
    
    func insertFolder(with title: String)
    func deleteFolder(at indexPath: IndexPath)
    func updateFolder(at indexPath: IndexPath, with newTitle: String)
    func selectFolder(at indexPath: IndexPath)
}

final class FoldersPresenter: NSObject {
    typealias PathAction = (FoldersCoordinator.Path) -> Void
    
    weak var viewController: FoldersViewControllerRepresentable?
    
    private var isLoading = false {
        didSet {
            if !isLoading {
                viewController?.endRefreshing()
            }
        }
    }
    
    private var sortingDescriptor: SortingDescriptor = .none {
        didSet {
            load()
        }
    }

    var fetchedResultController: NSFetchedResultsController<Folder> {
        let controller = model.fetchedResultController(for: sortingDescriptor)
        controller.delegate = self
        return controller
    }
    
    private let model: FoldersModelRepresentable
    private let pathAction: PathAction
    
    init(model: FoldersModelRepresentable,
         pathAction: @escaping PathAction) {
        self.model = model
        self.pathAction = pathAction
    }
    
    private func load() {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            viewController?.handleError(title: GlobalConstants.errorTitle,
                                       message: error.localizedDescription)
        }
    }
}

extension FoldersPresenter: FoldersPresentable {

    func didLoad() {
        load()
        isLoading = false
    }
    
    func sortByName() {
        sortingDescriptor = .byName
    }
    
    func sortByDate() {
        sortingDescriptor = .byCreationDate
    }
    
    func insertFolder(with title: String) {
        model.insertFolder(with: title) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success:
                break
            case .failure(let error):
                self.viewController?
                    .handleError(title: GlobalConstants.errorTitle,
                                 message: error.localizedDescription)
            }
        }
    }
    
    func deleteFolder(at indexPath: IndexPath) {
        let folder = fetchedResultController.object(at: indexPath)
        
        model.delete(folder: folder, completionHandler: { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success:
                break
            case .failure(let error):
                self.viewController?
                    .handleError(title: GlobalConstants.errorTitle,
                                 message: error.localizedDescription)
            }
        })
    }
    
    func updateFolder(at indexPath: IndexPath, with title: String) {
        let folder = fetchedResultController.object(at: indexPath)
        model.updateFolder(folder: folder,
                           with: title) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success:
                break
            case .failure(let error):
                self.viewController?
                    .handleError(title: GlobalConstants.errorTitle,
                                 message: error.localizedDescription)
            }
        }
    }
    
    func selectFolder(at indexPath: IndexPath) {
        let folder = fetchedResultController.object(at: indexPath)
        pathAction(.notes(folderId: folder.id))
    }
    
    func numberOfRows() -> Int {
        fetchedResultController.fetchedObjects?.count ?? .zero
    }
    
    func folder(for indexPath: IndexPath) -> FolderAdapter {
        FolderAdapter(fetchedResultController.object(at: indexPath))
    }
}

extension FoldersPresenter: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        viewController?.prepareForChanges()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                viewController?.insert(at: [newIndexPath])
            }
        case .delete:
            // TODO: Find out
            if let indexPath = indexPath {
                viewController?.delete(at: [indexPath])
            }
        case .update:
            if let indexPath = indexPath {
                viewController?.update(at: [indexPath])
            }
        case .move:
            break
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        viewController?.completeChanges()
    }
}
