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
        guard let library = Library<()>() else { return XCTFail("Nil function library") }
        
        XCTAssertEqual(library.functions.count, 0)
        XCTAssertNil(library["test"])
    }
    
    // Test creating an invalid library with duplicate functions.
    func testInvalidLibrary() {
        let functions = ["test", "test"].compactMap { Function<()>(name: $0, expression: Literal(())) }
        guard functions.count == 2 else { return XCTFail("Nil function") }
        let library = Library(functions: functions)
        
        XCTAssertNil(library)
    }
    
    // Test creating an valid library with multiple functions.
    func testValidLibrary() {
        let functions = ["test1", "test2"].compactMap { Function<()>(name: $0, expression: Literal(())) }
        guard functions.count == 2 else { return XCTFail("Nil function") }
        let library = Library(functions: functions)
        
        XCTAssertNotNil(library)
        XCTAssertEqual(library?.functions.count, 2)
    }
    
    // Test retrieving an known function from a non-empty library.
    func testKnownLibraryFunction() {
        let functions = ["test"].compactMap { Function<Int>(name: $0, expression: Literal(42)) }
        guard functions.count == 1 else { return XCTFail("Nil function") }
        guard let library = Library(functions: functions) else { return XCTFail("Nil function library") }

        XCTAssertNotNil(library["test"])
        XCTAssertEqual(library["test"]?.name, "test")
    }
    
    // Test retrieving an unknown function from a non-empty library.
    func testUnknownLibraryFunction() {
        let functions = ["test"].compactMap { Function<Int>(name: $0, expression: Literal(42)) }
        guard functions.count == 1 else { return XCTFail("Nil function") }
        guard let library = Library(functions: functions) else { return XCTFail("Nil function library") }

        XCTAssertNil(library["zork"])
    }
    
    // MARK: Testing context
    
    // Test accessing an empty context.
    func testEmptyContext() {
        guard let library = Library<()>() else { return XCTFail("Nil function library") }
        let context = Context(library: library)
        
        XCTAssertEqual(library.functions.count, 0)
        XCTAssertNil(context[function: "test"])
    }

    // Test retrieving an known function from a non-empty (function) context.
    func testKnownContextFunction() {
        let functions = ["test"].compactMap { Function<Int>(name: $0, expression: Literal(42)) }
        guard functions.count == 1 else { return XCTFail("Nil function") }
        guard let library = Library(functions: functions) else { return XCTFail("Nil function library") }
        let context = Context(library: library)
        
        XCTAssertNotNil(context[function: "test"])
        XCTAssertEqual(context[function: "test"]?.name, "test")
    }

    // Test retrieving an unknown function from a non-empty (function) context.
    func testUnknownContextFunction() {
        let functions = ["test"].compactMap { Function<Int>(name: $0, expression: Literal(42)) }
        guard functions.count == 1 else { return XCTFail("Nil function") }
        guard let library = Library(functions: functions) else { return XCTFail("Nil function library") }
        let context = Context(library: library)
        
        XCTAssertNil(context[function: "zork"])
    }

    // MARK: Testing functions
    
    // Test evaluating a function in a context.
    func testEvalFunction() {
        guard let library = Library<Int>() else { return XCTFail("Nil function library") }
        let context = Context(library: library)
        guard let function = Function<Int>(name: "test", parameters: ["a"], expression: Parameter(0)) else { return XCTFail("Nil function") }

        XCTAssertEqual(function.eval(in: context, parameters: [42]), 42)
    }

}


extension ExpressionTests {
    
    // Shortcuts for expression types.
    typealias Library<T> = Context<T>.Library
    typealias Literal<T> = MathRules.Operation<T>.Literal
    typealias Parameter<T> = MathRules.Operation<T>.Parameter
}
