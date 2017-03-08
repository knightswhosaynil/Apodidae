//
//  Registrar.swift
//  Apodidae
//
//  Created by Johnathan D Raymond on 8/11/15.
//  Copyright © 2015 Knights Who Say Nil. All rights reserved.
//

import Foundation

/// Registrar
///
/// Central registration point for protocol implementations.  Obtain the Singleton
/// via the `instance` property.
public final class Registrar {
    public static let instance = Registrar()
    
    fileprivate var registrations = Dictionary<ObjectIdentifier, Injectable.Type>()
    fileprivate let lock = "Lock"
    
    fileprivate init() {}
    
    public func obtain(_ theProtocol: Any.Type) -> Injectable? {
        var implementation: Injectable?
        if let implementationType = concreteType(theProtocol) {
            implementation = try! implementationType.create()
        }
        return implementation
    }
    
    public func clearRegistrations() -> Void {
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        registrations.removeAll()
    }
    
    public func concreteType(_ theProtocol:Any.Type) -> Injectable.Type? {
        var type: Injectable.Type?
        
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        
        return registrations[ObjectIdentifier(theProtocol)]
    }
    
    public func register(_ aProtocol: Any.Type, implementation: Injectable.Type) -> Void {
        
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        
        let protocolKey = ObjectIdentifier(aProtocol)
        registrations.updateValue(implementation, forKey: protocolKey)
    }
}

