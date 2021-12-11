//
//  ContextTests.swift
//  
//  Created by Michel Tilman on 10/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import MathRules

/**
 Tests contexts.
 */
class ContextTests: XCTestCase {
    
    // MARK: Function library tests
    
    func testDefaultLibrary() throws {
        let library = try XCTUnwrap(Library())
        let expected = 9
        
        XCTAssertEqual(library.functions.count, expected)
        XCTAssertEqual(Set(library.functions.values.map(\.name)).count, expected
        )
        for (name, function) in library.functions {
            XCTAssertEqual(name, function.name)
            XCTAssertTrue(function.isPrimitive)
        }
    }
    
    func testAccessDefaultLibrary() throws {
        let library = try XCTUnwrap(Library())

        for function in Function.primitiveFunctions() {
            XCTAssertNotNil(library[function.name])
        }
    }
    
    func testValidRegistration() throws {
        let library = try XCTUnwrap(Library())
        let zork = Function(name: "Zork", type: ([("param", Double.self)], Double.self), isPrimitive: false) { _, _ in 0 }
        
        XCTAssertNil(library["Zork"])
        XCTAssertNoThrow(try library.register(function: zork))
        XCTAssertNotNil(library["Zork"])
    }
    
    func testInvalidDuplicateRegistration() throws {
        let library = try XCTUnwrap(Library())
        let plus = Function(name: "+", type: ([], Double.self)) { _, _ in 0 }
        
        XCTAssertNotNil(library["+"])
        XCTAssertThrowsError(try library.register(function: plus)) { error in
            XCTAssertEqual(error as? FunctionError, .duplicateFunction("+"))
        }
        XCTAssertNotNil(library["+"])
    }
    
    func testValidDuplicateRegistration() throws {
        let library = try XCTUnwrap(Library())
        let zork1 = Function(name: "Zork", type: ([("param1", Double.self)], Double.self), isPrimitive: false) { _, _ in 0 }
        let zork2 = Function(name: "Zork", type: ([("param2", Double.self)], Double.self), isPrimitive: false) { _, _ in 0 }

        XCTAssertNil(library["Zork"])
        XCTAssertNoThrow(try library.register(function: zork1))
        let function1 = try XCTUnwrap(library["Zork"])
        XCTAssertEqual(function1.parameters[0].0, "param1")
        XCTAssertNoThrow(try library.register(function: zork2))
        let function2 = try XCTUnwrap(library["Zork"])
        XCTAssertEqual(function2.parameters[0].0, "param2")
    }
    
    // MARK: Accessing context tests
    
    func testAccessDefaultLibraryContext() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        
        for function in Function.primitiveFunctions() {
            XCTAssertNotNil(context[function: function.name])
        }
    }
    
}


extension ContextTests {
    
    // Shortcuts for MathRules types.
    typealias Context = MathRules.Context<Double>
    typealias Library = Context.Library
    typealias Function = MathRules.Function<Double>
    
}
