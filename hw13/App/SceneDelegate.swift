//
//  SceneDelegate.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private(set) var appCoordinator: AppCoordinator?
    
    private lazy var serviceLocator = ServiceLocator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let navigationController = UINavigationController()
        
        configureCoreDataStack()
        
        appCoordinator = AppCoordinator(navigationController, serviceLocator: serviceLocator)
        appCoordinator?.start()
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {

        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

extension SceneDelegate {
    private func configureCoreDataStack() {
        let hw13CoreDataStack = CoreDataStack(modelName: "hw13")
        serviceLocator.register(hw13CoreDataStack)
    }
}
