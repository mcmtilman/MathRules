//
//  FunctionBuilderTests.swift
//  
//  Created by Michel Tilman on 10/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import MathRules

/**
 Tests building and evaluating functions.
 */
class FunctionBuilderTests: XCTestCase {
    
    // MARK: Custom function builder tests

    func testEmptyInstructions() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        
        XCTAssertThrowsError(try builder.buildFunction(name: "Function", instructions: [], library: library)) { error in
            XCTAssertEqual(error as? FunctionError, .invalidInstructions)
        }
    }
    
    func testInvalidParameterIndex() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        
        XCTAssertThrowsError(try builder.buildFunction(name: "Function", instructions: [.param(1)], library: library)) { error in
            XCTAssertEqual(error as? FunctionError, .invalidParameterIndex(1))
        }
    }

    func testValidParameterIndex() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        
        XCTAssertNoThrow(try builder.buildFunction(name: "Function", instructions: [.param(0)], library: library))
    }

    func testApplyUnknownFunction() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        
        XCTAssertThrowsError(try builder.buildFunction(name: "Function", instructions: [.apply("Zork")], library: library)) { error in
            XCTAssertEqual(error as? FunctionError, .unknownFunction("Zork"))
        }
    }

    func testApplyKnownFunction() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        
        XCTAssertNoThrow(try builder.buildFunction(name: "Function", instructions: [.const(3), .apply("sqr")], library: library))
    }
    
    // MARK: Custom function evaluation tests
    
    func testConstantFunction() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.const(3)], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: []) as? Int, 3)
    }
    
    func testIdentityFunction() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.param(0)], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [4.0]) as? Double, 4)
    }
    
   func testParameterizedSquare() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.param(0), .apply("sqr")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0]) as? Double, 9)
    }
    
    func testFixedSquare() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.const(3), .apply("sqr")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: []) as? Double, 9)
    }
    
    func testHypotenuse() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let instructions: [Instruction] = [
            .param(0),
            .apply("sqr"),
            .param(1),
            .apply("sqr"),
            .apply("+"),
            .apply("sqrt")
        ]
        let function = try builder.buildFunction(name: "Function", instructions: instructions, library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [3, 4]) as? Double, 5)
    }
    
    func testFactorial() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let stub = try builder.buildFunction(name: "fac", instructions: [.param(0)], library: library)
        try library.register(function: stub)
        let instructions: [Instruction] = [
            .param(0),
            .const(0),
            .apply("<="),
            .const(1),
            .param(0),
            .const(1),
            .apply("-"),
            .apply("fac"),
            .param(0),
            .apply("*"),
            .cond
        ]
        let function = try builder.buildFunction(name: "fac", instructions: instructions, library: library)
        try library.register(function: function)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [5]) as? Double, 120)
    }
    
    func testFibonacci() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let stub = try builder.buildFunction(name: "fib", instructions: [.param(0)], library: library)
        try library.register(function: stub)
        let instructions: [Instruction] = [
            .param(0),
            .const(0),
            .apply("<="),
            .const(0),
            .param(0),
            .const(1),
            .apply("=="),
            .const(1),
            .param(0),
            .const(1),
            .apply("-"),
            .apply("fib"),
            .param(0),
            .const(2),
            .apply("-"),
            .apply("fib"),
            .apply("+"),
            .cond,
            .cond
        ]
        let function = try builder.buildFunction(name: "fib", instructions: instructions, library: library)
        try library.register(function: function)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [7]) as? Double, 13)
    }
    
    func testMapSquare() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.param(0), .map("sqr")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [[1, 2, 3, 4, 5]]) as? [Double], [1, 4, 9, 16, 25])
    }
    
    func testMapTwice() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.param(0), .map("sqr"), .map("sqrt")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [[1, 2, 3, 4, 5]]) as? [Double], [1, 2, 3, 4, 5])
    }
    
    func testMapFactorial() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let stub = try builder.buildFunction(name: "fac", instructions: [.param(0)], library: library)
        try library.register(function: stub)
        let instructions: [Instruction] = [
            .param(0),
            .const(0),
            .apply("<="),
            .const(1),
            .param(0),
            .const(1),
            .apply("-"),
            .apply("fac"),
            .param(0),
            .apply("*"),
            .cond
        ]
        let factorial = try builder.buildFunction(name: "fac", instructions: instructions, library: library)
        try library.register(function: factorial)

        let function = try builder.buildFunction(name: "Function", instructions: [.param(0), .map("fac")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [[1, 2, 3, 4]]) as? [Double], [1, 2, 6, 24])
    }
    
    func testReduce() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.const(0), .param(0), .reduce("+")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [Array(1...100)]) as? Double, 5050)
    }
    
    func testMapReduce() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.const(0), .param(0), .map("sqr"), .reduce("+")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [Array(1...10)]) as? Double, 385)
    }
    
    // MARK: Debug description tests

    func testDebugDescription() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        let stub = try builder.buildFunction(name: "fib", instructions: [.param(0)], library: library)
        try library.register(function: stub)
        let instructions: [Instruction] = [
            .param(0),
            .const(0),
            .apply("<="),
            .const(0),
            .param(0),
            .const(1),
            .apply("=="),
            .const(1),
            .param(0),
            .const(1),
            .apply("-"),
            .apply("fib"),
            .param(0),
            .const(2),
            .apply("-"),
            .apply("fib"),
            .apply("+"),
            .cond,
            .cond
        ]
        let node = try builder.buildNode(name: "fib", instructions: instructions, library: library)
        let expected = """
            (cond (<= $0 0) 0 (cond (== $0 1) 1 (+ (fib (- $0 1)) (fib (- $0 2)))))
            """
        
        XCTAssertEqual(node.debugDescription, expected)
    }
    
    func testMapTwiceDebugDescription() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        let node = try builder.buildNode(name: "Function", instructions: [.param(0), .map("sqr"), .map("sqrt")], library: library)
        let expected = """
            (map "sqrt" (map "sqr" $0))
            """
        
        XCTAssertEqual(node.debugDescription, expected)
    }

    func testReduceDebugDescription() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        let node = try builder.buildNode(name: "Function", instructions: [.const(0), .const([1, 2, 3, 4, 5]), .reduce("+")], library: library)
        let expected = """
            (reduce "+" 0 [1, 2, 3, 4, 5])
            """
        
        XCTAssertEqual(node.debugDescription, expected)
    }

}
    
extension FunctionBuilderTests {
    
    // Shortcuts for MathRules types.
    typealias Context = MathRules.Context<Double>
    typealias Library = Context.Library
    typealias Function = MathRules.Function<Double>
    typealias FunctionBuilder = MathRules.FunctionBuilder<Double>

}
