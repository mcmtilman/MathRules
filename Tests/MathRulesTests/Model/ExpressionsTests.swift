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
    
    // MARK: Testing accessing context functions
    
    // Test retrieving a function from an empty context.
    func testEmptyFunctionsContext() {
        let context = Context<Double>(functions: [], parameters: [])
        
        XCTAssertNil(context[function: "test"])
    }

    // MARK: Testing accessing context parameters
    
    // Test retrieving a parameter from an empty context.
    func testEmptyParametersContext() {
        let context = Context<Double>(functions: [], parameters: [])
        
        XCTAssertNil(context[parameter: 0])
    }

    // Test retrieving an invalid parameter from a non-empty context.
    func testInvalidParameterContext() {
        let context = Context<Double>(functions: [], parameters: [42])
        
        XCTAssertNil(context[parameter: -1])
        XCTAssertNil(context[parameter: 1])
    }

    // Test retrieving an valid parameter from a non-empty context.
    func testValidParameterContext() {
        let context = Context<Double>(functions: [], parameters: [42])
        
        XCTAssertEqual(context[parameter: 0], 42)
    }

}
