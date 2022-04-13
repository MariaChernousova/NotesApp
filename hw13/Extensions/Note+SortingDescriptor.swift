//
//  Note.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

extension Note: SortingDescriptorProvider {
    static func sortDescriptor(for sortingDescriptor: SortingDescriptor) -> NSSortDescriptor? {
        switch sortingDescriptor {
        case .byName:
            return NSSortDescriptor(keyPath: \Note.name, ascending: true)
        case .byCreationDate:
            return NSSortDescriptor(keyPath: \Note.creationDate, ascending: true)
        case .none:
            return nil
        }
    }
}
