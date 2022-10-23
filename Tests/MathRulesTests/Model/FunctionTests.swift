//
//  FunctionTests.swift
//  
//  Copyright © 2021 Michel Tilman .
//  Licensed under Apache License v2.0.
//

import XCTest
import MathRules

/**
 Tests functions.
 */
class FunctionTests: XCTestCase {
    
    // MARK: Arithmetic function tests

    func testAddition() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["+"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 4)), .real(7))
    }

    func testSubtraction() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["-"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 4)), .real(-1))
    }

    func testMultiplication() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["*"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 4)), .real(12))
    }

    func testDivision() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["/"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 4)), .real(0.75))
    }

    func testSquare() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["sqr"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(3)), .real(9))
    }

    func testSquareRoot() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["sqrt"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(9)), .real(3))
    }

    func testExponent() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["exp"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(4, 0.5)), .real(2))
    }

    func testPower() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["power"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 2)), .real(9))
    }

    func testRoot() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["root"])

        XCTAssertEqual(try function.eval(inContext: context, with: params(9, 2)), .real(3))
    }

    // MARK: Boolean function tests

    func testLessThanOrEqualTo() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["<="])

        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 4)), .bool(true))
        XCTAssertEqual(try function.eval(inContext: context, with: params(4, 4)), .bool(true))
        XCTAssertEqual(try function.eval(inContext: context, with: params(4, 3)), .bool(false))
    }

    func testEqualTo() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["=="])

        XCTAssertEqual(try function.eval(inContext: context, with: params(4, 4)), .bool(true))
        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 4)), .bool(false))
        XCTAssertEqual(try function.eval(inContext: context, with: params(4, 3)), .bool(false))
    }

    func testGreaterThanOrEqualTo() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library[">="])

        XCTAssertEqual(try function.eval(inContext: context, with: params(4, 3)), .bool(true))
        XCTAssertEqual(try function.eval(inContext: context, with: params(4, 4)), .bool(true))
        XCTAssertEqual(try function.eval(inContext: context, with: params(3, 4)), .bool(false))
    }

    // MARK: Invalid parameter tests

    func testUnaryFunctionInvalidParameterCount() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let names = ["sqr", "sqrt"]

        for name in names {
            let function = try XCTUnwrap(library[name])

            for params in [[], [3, 4]].map(params) {
                XCTAssertThrowsError(try function.eval(inContext: context, with: params)) { error in
                    XCTAssertEqual(error as? EvalError, .invalidParameters)
                }
            }
        }
    }

    func testBinaryFunctionInvalidParameterCount() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let names = ["+", "-", "*", "/", "<=", "==", ">=", "exp", "power", "root"]

        for name in names {
            let function = try XCTUnwrap(library[name])

            for params in [[], [3], [3, 4, 5]].map(params) {
                XCTAssertThrowsError(try function.eval(inContext: context, with: params)) { error in
                    XCTAssertEqual(error as? EvalError, .invalidParameters)
                }
            }
        }
    }
    
}


extension FunctionTests {
    
    // Utility functions.
    
    func params(_ elements: Int...) -> [Value] {
        params(elements)
    }

    func params(_ list: [Int]) -> [Value] {
        list.map(Value.int)
    }
    
    func params(_ elements: Double...) -> [Value] {
        params(elements)
    }
    
    func params(_ list: [Double]) -> [Value] {
        list.map(Value.real)
    }
    
    // Shortcuts for MathRules types.
    typealias Library = Context.Library
    
}
