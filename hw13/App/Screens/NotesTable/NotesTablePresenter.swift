//
//  NotesTablePresenter.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

protocol NotesPresentable: AnyObject {
    func load()
    func sortByName()
    func sortByDate()
    func insertNote(with title: String)
    func selectNote(at indexPath: IndexPath)
    func deleteNote(at indexPath: IndexPath)
}

final class NotesTablePresenter {
    typealias PathAction = (NotesTableCoordinator.Path) -> Void
    
    weak var viewController: NotesViewControllerRepresentable?
    
    private var isLoading = false {
        didSet {
            if !isLoading {
                viewController?.endRefreshing()
            }
        }
    }
    
    private var notes: [Note] = [] {
        didSet {
            let noteAdapters = notes.map { NoteAdapter($0) }
            viewController?.apply(notes: noteAdapters)
        }
    }
    
    private let folderId: UUID
    private let model: NotesTableModel
    private let pathAction: PathAction
    
    init(folderId: UUID,
         model: NotesTableModel,
         pathAction: @escaping PathAction) {
        self.folderId = folderId
        self.model = model
        self.pathAction = pathAction
    }
    
    private func load(with sortingDescriptor: SortingDescriptor) {
        guard !isLoading else { return }
        isLoading = true
        
        model.fetchNotes(from: folderId,
                         with: sortingDescriptor) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let notes):
                self.notes = notes
            case .failure(let error):
                self.viewController?
                    .handleError(title: GlobalConstants.errorTitle,
                                 message: error.localizedDescription)
            }
        }
    }
}

extension NotesTablePresenter: NotesPresentable {

    func load() {
        load(with: .none)
    }
    
    func sortByName() {
        load(with: .byName)
    }
    
    func sortByDate() {
        load(with: .byCreationDate)
    }
    
    func insertNote(with title: String) {
        model.insertNote(with: title, to: folderId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.load()
            case .failure(let error):
                self.viewController?
                    .handleError(title: GlobalConstants.errorTitle,
                                 message: error.localizedDescription)
            }
        }
    }
    
    func selectNote(at indexPath: IndexPath) {
        pathAction(.noteContent(note: notes[indexPath.row]))
    }
    
    func deleteNote(at indexPath: IndexPath) {
        guard indexPath.row < notes.endIndex else { return }
        model.delete(noteId: notes.remove(at: indexPath.row).id, from: folderId) { [weak self] result in
            guard let self = self else { return }
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
}

