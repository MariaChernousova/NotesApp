//
//  NoteAdapter.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

struct NoteAdapter: Hashable {
    
    var name: String
    var id: UUID
    
    init(_ note: Note) {
        name = note.name
        id = note.id
    }
}
