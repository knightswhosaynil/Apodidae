//
//  Injector.swift
//  Apodidae
//
//  Created by Johnathan D Raymond on 8/10/15.
//  Copyright © 2015 Knights Who Say Nil. All rights reserved.
//

import Foundation

public protocol Injectable {
    static func create() throws -> Self
    static func dependencies() -> [Any]
    static func create(dependencies:[Injectable]) -> Self
    init(dependencies: [Injectable])
}

public extension Injectable {
    public static func create() throws -> Self {
        var dependencyImplementations = [Injectable]()
        for aProtocol in dependencies() {
            if let dependency = Registrar.instance.obtain(aProtocol) {
                dependencyImplementations.append(dependency)
            } else {
                throw InjectionError.UnsatisfiedDependency
            }
        }
        return create(dependencyImplementations)
    }
    
    public static func create(dependencies: [Injectable]) -> Self {
        return Self(dependencies: dependencies)
    }
}

