//
//  ApodidaeTests.swift
//  ApodidaeTests
//
//  Created by Johnathan D Raymond on 8/13/15.
//  Copyright © 2015 Knights Who Say Nil. All rights reserved.
//

import XCTest
import Apodidae

class ApodidaeTests: XCTestCase {
    
    let registrar = Registrar.instance
    
    override func setUp() {
        super.setUp()
        registrar.clearRegistrations()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyRegistration() {
        if let _ = registrar.obtain(ProtoA) {
            XCTFail("Non registered object returned")
        }
    }
    
    func testRegistration() {
        let impl = ImplementationA.self
        registrar.register(ProtoA.self, implementation: impl)
        XCTAssert(impl == registrar.concreteType(ProtoA.self), "Concrete type implementation mismatch")
    }
    
    func testSimpleInjection() {
        registrar.register(ProtoA.self, implementation: ImplementationA.self)
        if let proto = registrar.obtain(ProtoA.self) as? ProtoA {
            XCTAssertEqual(ImplementationA.NAME, proto.hello(), "Invalid implementation obtained")
        } else {
            XCTFail("No implementation obtained for protocol ProtoA")
        }
    }
    
    func testChainedInjection() {
        registrar.register(ProtoA.self, implementation: ImplementationA.self)
        registrar.register(ProtoB.self, implementation: ImplementationB.self)
        
        if let proto = registrar.obtain(ProtoB.self) as? ProtoB {
            if let implB = proto as? ImplementationB {
                XCTAssertEqual(ImplementationA.NAME, implB.protoA.hello(), "Chained dependency not found")
            } else {
                XCTFail("Incorrect implementation provided")
            }
        } else {
            XCTFail("No implementation found for protocol ProtoB")
        }
    }
    
    func testThirdPartyProtocolInjection() {
        registrar.register(ProtoC.self, implementation: ImplementationC.self)
        
        if let proto = registrar.obtain(ProtoC) as? ProtoC {
            XCTAssertEqual(ImplementationC.NAME, proto.hello(), "Invalid implementation found")
        } else {
            XCTFail("Failed to obtain third party protocol dependency")
        }
    }
    
    func testRegistrationChanged() {
        testThirdPartyProtocolInjection()
        
        registrar.register(ProtoC.self, implementation: OtherImplementationC.self)
        if let proto = registrar.obtain(ProtoC) as? ProtoC {
            XCTAssertEqual(OtherImplementationC.NAME, proto.hello(), "Failed to overwrite existing registration")
        } else {
            XCTFail("Failed to obtain third party protocol dependency")
        }
        
    }
}

public protocol ProtoA: Injectable {
    func hello() -> String
}

public final class ImplementationA : ProtoA {
    public static let NAME = "ImplementationA"
    public static func dependencies() -> [Any] {
        return [Any]()
    }
    
    required public init(dependencies: [Injectable]) {
        
    }
    
    public func hello() -> String {
        return ImplementationA.NAME
    }
}

public protocol ProtoB : Injectable {}

public final class ImplementationB : ProtoB {
    public static func dependencies() -> [Any] {
        return [
            ProtoA.self
        ]
    }
    
    public let protoA: ProtoA
    
    required public init(dependencies: [Injectable]) {
        protoA = dependencies[0] as! ProtoA
    }
}

public protocol ProtoC {
    func hello() -> String
}

public final class ImplementationC : ProtoC, Injectable {
    public static let NAME = "ImplementationC"

    public static func dependencies() -> [Any] {
        return []
    }
    
    public func hello() -> String {
        return ImplementationC.NAME
    }
    
    required public init(dependencies: [Injectable]) {
    }
}

public final class OtherImplementationC: ProtoC, Injectable {
    public static let NAME = "OtherImplementationC"
    
    public static func dependencies() -> [Any] {
        return []
    }
    
    public func hello() -> String {
        return OtherImplementationC.NAME
    }
    
    required public init(dependencies: [Injectable]) {
    }
}

