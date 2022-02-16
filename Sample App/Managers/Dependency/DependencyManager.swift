//
//  DependencyManager.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import Resolver
protocol DependencyManagerProtocol {
    func inject<T>() -> T
}

class DependencyManager: DependencyManagerProtocol {
    // MARK: Singleton Access
    static var dependencyManager: DependencyManager {
        let dependencyManager = DependencyManager()
        dependencyManager.start()
        return dependencyManager
    }

    class func shared() -> DependencyManager {
        return dependencyManager
    }

    private func start() {
        Resolver.main.registerServices()
    }

    func inject<T>() -> T {
        return Resolver.resolve() as T
    }
}

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register(KeychainManagerProtocol.self) { _ in KeychainManager() as KeychainManagerProtocol }
        register(AuthorizationManagerProtocol.self) { _ in AuthorizationManager(keychainManagerProtocol: resolve()) as AuthorizationManagerProtocol }
        register(AuthenticationManagerProtocol.self) { _ in AuthenticationManager(keychainManagerProtocol: resolve()) as AuthenticationManagerProtocol }
        register(CommentsManagerProtocol.self) { _ in CommentsManager(keychainManagerProtocol: resolve(), authorizationManagerProtocol: resolve()) as CommentsManagerProtocol }
    }
}
