//
//  BaseCoordinator.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

protocol Coordinator {
    func start()
}

class BaseCoordinator: Coordinator {
    let serviceLocator: ServiceLocator
    let rootViewController: UINavigationController
    
    init(_ rootViewController: UINavigationController, serviceLocator: ServiceLocator) {
        self.rootViewController = rootViewController
        self.serviceLocator = serviceLocator
    }
    
    func start() {
        preconditionFailure("This method need to be overridden")
    }
}
