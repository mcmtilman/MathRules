//
//  ContextTests.swift
//  
//  Copyright © 2021 by Michel Tilman.
//  Licensed under Apache License v2.0.
//

import XCTest

#if DEBUG
    @testable import MathRules
#else
    import MathRules
#endif

/**
 Tests contexts.
 */
class ContextTests: XCTestCase {
    
    // MARK: Function library tests
    
    func testDefaultLibrary() throws {
        let library = try XCTUnwrap(Library())
        let expected = 19
        
        XCTAssertEqual(library.functions.count, expected)
        for (name, overloadedFunctions) in library.functions {
            for function in overloadedFunctions {
                XCTAssertEqual(name, function.name)
                XCTAssertTrue(function.isPredefined)
            }
        }
    }

#if DEBUG
    
    func testAccessDefaultLibrary() throws {
        let library = try XCTUnwrap(Library())

        for function in Function.primitiveFunctions() {
            XCTAssertNotNil(library[function.name])
        }
    }
    
#endif

    func testValidRegistration() throws {
        let library = try XCTUnwrap(Library())
        let zork = Function(name: "Zork", type: ([("param", Real.self)], Double.self), isPredefined: false) { _, _ in .real(0) }
        
        XCTAssertNil(library["Zork"])
        XCTAssertNoThrow(try library.register(function: zork))
        XCTAssertNotNil(library["Zork"])
    }
    
    func testInvalidDuplicateRegistration() throws {
        let library = try XCTUnwrap(Library())
        let plus = Function(name: "+", type: ([("lhs", Real.self), ("rhs", Real.self)], Real.self)) { _, _ in .real(0) }
        
        XCTAssertNotNil(library["+"])
        XCTAssertThrowsError(try library.register(function: plus)) { error in
            XCTAssertEqual(error as? FunctionError, .duplicateFunction("+"))
        }
        XCTAssertNotNil(library["+"])
    }
    
    func testValidDuplicateRegistration() throws {
        let library = try XCTUnwrap(Library())
        let zork1 = Function(name: "Zork", type: ([("param1", Real.self)], Double.self), isPredefined: false) { _, _ in .real(0) }
        let zork2 = Function(name: "Zork", type: ([("param2", Real.self)], Double.self), isPredefined: false) { _, _ in .real(0) }

        XCTAssertNil(library["Zork"])
        XCTAssertNoThrow(try library.register(function: zork1))
        let function1 = try XCTUnwrap(library["Zork"])
        XCTAssertEqual(function1.type.0[0].0, "param1")
        XCTAssertNoThrow(try library.register(function: zork2))
        let function2 = try XCTUnwrap(library["Zork"])
        XCTAssertEqual(function2.type.0[0].0, "param2")
    }
    
    // MARK: Accessing context tests
    
#if DEBUG

    func testAccessDefaultLibraryContext() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        
        for function in Function.primitiveFunctions() {
            XCTAssertNotNil(context[function: function.name])
        }
    }

#endif
    
}


extension ContextTests {
    
    // Shortcuts for MathRules types.
    typealias Library = Context.Library
    
}
