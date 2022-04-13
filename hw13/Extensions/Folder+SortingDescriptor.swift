//
//  Folder+SortingDescriptor.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

extension Folder: SortingDescriptorProvider {
    static func sortDescriptor(for sortingDescriptor: SortingDescriptor) -> NSSortDescriptor? {
        switch sortingDescriptor {
        case .byName:
            return NSSortDescriptor(keyPath: \Folder.title, ascending: true)
        case .byCreationDate:
            return NSSortDescriptor(keyPath: \Folder.creationDate, ascending: true)
        case .none:
            return nil
        }
    }
}
