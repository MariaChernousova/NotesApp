//
//  ServiceLocator+Holders.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

extension ServiceLocator {
    private enum Const {
        static let errorMessage = "'%@' cannot be resolved"
    }
    
    var coreDataStack: CoreDataStackContext {
        guard let coreDataStack: CoreDataStack = resolve() else {
            fatalError(.init(format: Const.errorMessage,
                             arguments: [String(describing: CoreDataStack.self)]))
        }
        return coreDataStack
    }
}

// MARK: - Holders Conformance
extension ServiceLocator: CoreDataStackHolder { }
