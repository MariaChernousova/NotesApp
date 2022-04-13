//
//  ServiceLocator.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

protocol Locator {
    func register<T: AnyObject>(_ service: T)
    func resolve<T: AnyObject>() -> T?
}

final class ServiceLocator: Locator {
    private var services = [ObjectIdentifier: Any]()
    
    func register<T>(_ service: T) {
        services[key(for: T.self)] = service
    }
    
    func resolve<T>() -> T? {
        return services[key(for: T.self)] as? T
    }
    
    private func key<T>(for type: T.Type) -> ObjectIdentifier {
        return ObjectIdentifier(T.self)
    }
}
