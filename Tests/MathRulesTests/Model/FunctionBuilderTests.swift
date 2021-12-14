//
//  FunctionBuilderTests.swift
//  
//  Created by Michel Tilman on 10/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest

#if DEBUG
    @testable import MathRules
#else
    import MathRules
#endif

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
        
        XCTAssertNoThrow(try builder.buildFunction(name: "Function", instructions: [.const(.int(3)), .apply("sqr")], library: library))
    }
    
    // MARK: Custom function evaluation tests
    
    func testConstantFunction() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.const(.int(3))], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: []), .int(3))
    }
    
    func testIdentityFunction() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.param(0)], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: params(4)), .int(4))
    }
    
   func testParameterizedSquare() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.param(0), .apply("sqr")], library: library)
        
       XCTAssertEqual(try function.eval(inContext: context, with: params(3)), .real(9))
    }
    
    func testFixedSquare() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.const(.int(3)), .apply("sqr")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: []), .real(9))
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
        
        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 4)), .real(5))
    }
    
    func testFactorial() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let stub = try builder.buildFunction(name: "fac", instructions: [.param(0)], library: library)
        try library.register(function: stub)
        let instructions: [Instruction] = [
            .param(0),
            .const(.int(0)),
            .apply("<="),
            .const(.int(1)),
            .param(0),
            .const(.int(1)),
            .apply("-"),
            .apply("fac"),
            .param(0),
            .apply("*"),
            .cond
        ]
        let function = try builder.buildFunction(name: "fac", instructions: instructions, library: library)
        try library.register(function: function)
        
        XCTAssertEqual(try function.eval(inContext: context, with: params(5)), .real(120))
    }
    
    func testFibonacci() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let stub = try builder.buildFunction(name: "fib", instructions: [.param(0)], library: library)
        try library.register(function: stub)
        let instructions: [Instruction] = [
            .param(0),
            .const(.int(0)),
            .apply("<="),
            .const(.int(0)),
            .param(0),
            .const(.int(1)),
            .apply("=="),
            .const(.int(1)),
            .param(0),
            .const(.int(1)),
            .apply("-"),
            .apply("fib"),
            .param(0),
            .const(.int(2)),
            .apply("-"),
            .apply("fib"),
            .apply("+"),
            .cond,
            .cond
        ]
        let function = try builder.buildFunction(name: "fib", instructions: instructions, library: library)
        try library.register(function: function)
        
        XCTAssertEqual(try function.eval(inContext: context, with: params(7)), .real(13))
    }
    
    func testMapSquare() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.param(0), .map("sqr")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [list(1, 2, 3, 4, 5)]), list(1.0, 4.0, 9.0, 16.0, 25.0))
    }
    
    func testMapTwice() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.param(0), .map("sqr"), .map("sqrt")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [list(1, 2, 3, 4, 5)]), list(1.0, 2.0, 3.0, 4.0, 5.0))
    }
    
    func testMapFactorial() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let stub = try builder.buildFunction(name: "fac", instructions: [.param(0)], library: library)
        try library.register(function: stub)
        let instructions: [Instruction] = [
            .param(0),
            .const(.int(0)),
            .apply("<="),
            .const(.int(1)),
            .param(0),
            .const(.int(1)),
            .apply("-"),
            .apply("fac"),
            .param(0),
            .apply("*"),
            .cond
        ]
        let factorial = try builder.buildFunction(name: "fac", instructions: instructions, library: library)
        try library.register(function: factorial)

        let function = try builder.buildFunction(name: "Function", instructions: [.param(0), .map("fac")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [list(1, 2, 3, 4)]), list(1.0, 2.0, 6.0, 24.0))
    }
    
    func testReduce() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.const(.int(0)), .param(0), .reduce("+")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [list(1...100)]), .real(5050))
    }
    
    func testMapReduce() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let builder = FunctionBuilder()
        let function = try builder.buildFunction(name: "Function", instructions: [.const(.int(0)), .param(0), .map("sqr"), .reduce("+")], library: library)
        
        XCTAssertEqual(try function.eval(inContext: context, with: [list(1...10)]), .real(385))
    }
    
    // MARK: Debug description tests

#if DEBUG

    func testDebugDescription() throws {
        let library = try XCTUnwrap(Library())
        let builder = FunctionBuilder()
        let stub = try builder.buildFunction(name: "fib", instructions: [.param(0)], library: library)
        try library.register(function: stub)
        let instructions: [Instruction] = [
            .param(0),
            .const(.int(0)),
            .apply("<="),
            .const(.int(0)),
            .param(0),
            .const(.int(1)),
            .apply("=="),
            .const(.int(1)),
            .param(0),
            .const(.int(1)),
            .apply("-"),
            .apply("fib"),
            .param(0),
            .const(.int(2)),
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
        let node = try builder.buildNode(name: "Function", instructions: [.const(.int(0)), .const(list(1, 2, 3, 4, 5)), .reduce("+")], library: library)
        let expected = """
            (reduce "+" 0 [1, 2, 3, 4, 5])
            """
        
        XCTAssertEqual(node.debugDescription, expected)
    }

#endif
    
}
    
extension FunctionBuilderTests {
    
    // Utility functions.
    
    func params(_ elements: Int...) -> [Value] {
        elements.map(Value.int)
    }

    func list(_ elements: Int...) -> Value {
        list(elements)
    }

    func list<T: Sequence>(_ list: T) -> Value where T.Element == Int {
        .list(list.map(Value.int))
    }

    func list(_ elements: Real...) -> Value {
        .list(elements.map(Value.real))
    }

    // Shortcuts for MathRules types.
    
    typealias Library = Context.Library

}
