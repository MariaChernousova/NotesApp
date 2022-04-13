//
//  NoteDescriptionPresenter .swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

protocol NoteContentPresentable: AnyObject {
    func load()
    func save()
    func update(title: String)
    func update(content: String)
}

final class NoteDescriptionPresenter {

    weak var viewController: NoteDescriptionViewControllerRepresentable?
    
    private let note: Note
    private let model: NoteDescriptionModel
    
    init(note: Note,
         model: NoteDescriptionModel) {
        self.note = note
        self.model = model
    }
}

extension NoteDescriptionPresenter: NoteContentPresentable {
    func load() {
        viewController?.update(name: note.name)
        viewController?.update(content: note.content)
    }
    
    func save() {
        model.save()
    }
    
    func update(title: String) {
        note.name = title
    }
    
    func update(content: String) {
        note.content = content
    }
}

