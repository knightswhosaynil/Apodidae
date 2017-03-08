//
//  DependencyContainer.swift
//  Pods
//
//  Created by Raymond, Johnathan (ETW - FLEX Resource) on 3/7/17.
//
//

import Foundation

public struct DependencyContainer {
    
    fileprivate let dependencies: Dictionary<ObjectIdentifier, Injectable>
    
    internal init(dependencies: Dictionary<ObjectIdentifier, Injectable>) {
        self.dependencies = dependencies
    }
    
    public func extract<T>(_ aProtocol: T.Type) -> T? {
    
        let dependency = dependencies[ObjectIdentifier(aProtocol)]
        return dependency as? T
    }
}
