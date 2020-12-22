//
//  ExpressionsTests.swift
//  MathRulesTests
//
//  Created by Michel Tilman on 22/12/2020.
//  Copyright © 2020 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import MathRules

/**
 Tests core expressions.
 */
class ExpressionTests: XCTestCase {
    
    // MARK: Testing context library
    
    // Test accessing an empty library.
    func testEmptyLibrary() {
        guard let library = Library<()>(functions: []) else { return XCTFail("Nil function library") }
        
        XCTAssertEqual(library.functions.count, 0)
        XCTAssertNil(library["test"])
    }
    
    // Test creating an invalid library with duplicate functions.
    func testInvalidLibrary() {
        let function1 = Function<Int>(name: "test", parameters: [], expression: Operation.Literal(42))
        let function2 = Function<Int>(name: "test", parameters: [], expression: Operation.Literal(42))
        let library = Library(functions: [function1, function2])
        
        XCTAssertNil(library)
    }
    
    // Test creating an valid library with multiple functions.
    func testValidLibrary() {
        let function1 = Function<Int>(name: "test1", parameters: [], expression: Operation.Literal(42))
        let function2 = Function<Int>(name: "test2", parameters: [], expression: Operation.Literal(42))
        let library = Library(functions: [function1, function2])
        
        XCTAssertNotNil(library)
        XCTAssertEqual(library?.functions.count, 2)
    }
    
    // Test retrieving an invalid function from a non-empty library.
    func testInvalidLibraryFunction() {
        let function = Function<Int>(name: "test", parameters: [], expression: Operation.Literal(42))
        guard let library = Library(functions: [function]) else { return XCTFail("Nil function library") }

        XCTAssertNil(library["zork"])
    }
    
    // Test retrieving an valid function from a non-empty library.
    func testValidLibraryFunction() {
        let function = Function<Int>(name: "test", parameters: [], expression: Operation.Literal(42))
        guard let library = Library(functions: [function]) else { return XCTFail("Nil function library") }

        XCTAssertNotNil(library["test"])
        XCTAssertEqual(library["test"]?.name, "test")
    }
    
    // MARK: Testing context
    
    // Test accessing an empty context.
    func testEmptyContext() {
        guard let library = Library<()>(functions: []) else { return XCTFail("Nil function library") }
        let context = Context(library: library, parameters: [])
        
        XCTAssertEqual(library.functions.count, 0)
        XCTAssertNil(context[function: "test"])
        XCTAssertEqual(context.parameters.count, 0)
        XCTAssertNil(context[parameter: 0])
    }

    // Test retrieving an invalid function from a non-empty (function) context.
    func testInvalidContextFunction() {
        let function = Function<Int>(name: "test", parameters: [], expression: Operation.Literal(42))
        guard let library = Library(functions: [function]) else { return XCTFail("Nil function library") }
        let context = Context(library: library, parameters: [])
        
        XCTAssertNil(context[function: "zork"])
    }

    // Test retrieving an valid function from a non-empty (function) context.
    func testValidContextFunction() {
        let function = Function<Int>(name: "test", parameters: [], expression: Operation.Literal(42))
        guard let library = Library(functions: [function]) else { return XCTFail("Nil function library") }
        let context = Context(library: library, parameters: [])
        
        XCTAssertNotNil(context[function: "test"])
        XCTAssertEqual(context[function: "test"]?.name, "test")
    }

    // Test retrieving an invalid parameter from a non-empty (parameter) context.
    func testInvalidContextParameter() {
        guard let library = Library<Int>(functions: []) else { return XCTFail("Nil function library") }
        let context = Context(library: library, parameters: [42])
        
        XCTAssertNil(context[parameter: -1])
        XCTAssertNil(context[parameter: 1])
    }

    // Test retrieving an valid parameter from a non-empty (parameter) context.
    func testValidContextParameter() {
        guard let library = Library<Int>(functions: []) else { return XCTFail("Nil function library") }
        let context = Context(library: library, parameters: [42])

        XCTAssertEqual(context[parameter: 0], 42)
    }

}


extension ExpressionTests {
    
    // Shortcut for library type.
    typealias Library<T> = Context<T>.Library

}
