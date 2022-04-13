//
//  SortingDescriptor.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

protocol SortingDescriptorProvider {
    static func sortDescriptor(for sortingDescriptor: SortingDescriptor) -> NSSortDescriptor?
}

enum SortingDescriptor {
    case byName
    case byCreationDate
    case none
}
