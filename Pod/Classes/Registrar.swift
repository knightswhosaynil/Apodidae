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
    
    private var registrations: Array<Registration>! = Array<Registration>()
    private let lock = "Lock"
    
    private init() {}
    
    public func obtain(theProtocol: Any) -> Injectable? {
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
    
    public func concreteType(theProtocol:Any) -> Injectable.Type? {
        var type: Injectable.Type?
        
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        
        if let registrationIndex = findRegistration(theProtocol) {
            type = registrations[registrationIndex].implementation
        }
        return type
    }
    
    public func register(aProtocol: Any, implementation: Injectable.Type) -> Void {
        aProtocol
        
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        
        if let oldRegistration = findRegistration(aProtocol) {
            registrations.removeAtIndex(oldRegistration)
        }
        let newRegistration = Registration(aProtocol: aProtocol, implementation: implementation)
        registrations.append(newRegistration)
    }
    
    private func findRegistration(aProtocol: Any) ->  Int? {
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        
        return registrations.indexOf() {
            if let p1 = $0.aProtocol as? Any.Type, p2 = aProtocol as? Any.Type {
                return p1 == p2
            }
            return false
        }
    }
}

private struct Registration: Equatable {
    var aProtocol: Any
    var implementation: Injectable.Type

    init(aProtocol: Any, implementation: Injectable.Type) {
        self.aProtocol = aProtocol
        self.implementation = implementation
    }
}

private func ==(lhs: Registration, rhs: Registration) -> Bool {
    var equal = false
    if let leftType = lhs.aProtocol as? Any.Type, rightType = rhs.aProtocol as? Any.Type {
        equal = (leftType == rightType)
    }
    return equal
}