//
//  Injector.swift
//  Apodidae
//
//  Created by Johnathan D Raymond on 8/10/15.
//  Copyright © 2015 KnightsWhoSayNil. All rights reserved.
//

import Foundation

public protocol Injectable {
    static func create() throws -> Self
    static func dependencies() -> [Any.Type]
    static func create(_ dependencies:DependencyContainer) -> Self
    init(dependencies: DependencyContainer)
}

public extension Injectable {
    public static func create() throws -> Self {
        var dependencyImplementations = [ObjectIdentifier: Injectable]()
        for aProtocol in dependencies() {
            if let dependency = Registrar.instance.obtain(aProtocol) {
                dependencyImplementations.updateValue(dependency, forKey: ObjectIdentifier(aProtocol))
            } else {
                throw InjectionError.unsatisfiedDependency
            }
        }
        return create(DependencyContainer(dependencies: dependencyImplementations))
    }
    
    public static func create(_ dependencies: DependencyContainer) -> Self {
        return Self(dependencies: dependencies)
    }
}

