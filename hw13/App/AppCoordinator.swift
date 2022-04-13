//
//  AppCoordinator.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

class AppCoordinator: BaseCoordinator {
    
    override func start() {
        startFoldersCoordinator()
    }
    
    private func startFoldersCoordinator() {
        FoldersCoordinator(rootViewController, serviceLocator: serviceLocator).start()
    }
}
