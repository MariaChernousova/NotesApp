//
//  FolderAdapter.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

struct FolderAdapter: Hashable {
    
    var title: String
    var creationDate: Date
    var totalNotesCount: Int
    var id: UUID
    
    init(_ folder: Folder) {
        title = folder.title
        creationDate = folder.creationDate
        totalNotesCount = Int(folder.notes.count)
        id = folder.id
    }
}
