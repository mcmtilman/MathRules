//
//  FunctionTests.swift
//  
//  Created by Michel Tilman on 10/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import MathRules

/**
 Tests functions.
 */
class FunctionTests: XCTestCase {
    
    // MARK: Testing arithmetic functions
    
    func testAddition() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["+"])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0, 4.0]) as? Double, 7)
    }
    
    func testSubtraction() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["-"])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0, 4.0]) as? Double, -1)
    }
    
    func testMultiplication() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["*"])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0, 4.0]) as? Double, 12)
    }
    
    func testDivision() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["/"])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0, 4.0]) as? Double, 0.75)
    }
    
    func testSquare() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["sqr"])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0]) as? Double, 9)
    }
    
    func testSquareRoot() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["sqrt"])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [9.0]) as? Double, 3)
    }
    
    // MARK: Testing boolean functions
    
    func testLessThanOrEqualTo() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["<="])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0, 4.0]) as? Bool, true)
        XCTAssertEqual(try function.eval(inContext: context, with: [4.0, 4.0]) as? Bool, true)
        XCTAssertEqual(try function.eval(inContext: context, with: [4.0, 3.0]) as? Bool, false)
    }
    
    func testEqualTo() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library["=="])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [4.0, 4.0]) as? Bool, true)
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0, 4.0]) as? Bool, false)
    }
    
    func testGreaterThanOrEqualTo() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let function = try XCTUnwrap(library[">="])
        
        XCTAssertEqual(try function.eval(inContext: context, with: [4.0, 3.0]) as? Bool, true)
        XCTAssertEqual(try function.eval(inContext: context, with: [4.0, 4.0]) as? Bool, true)
        XCTAssertEqual(try function.eval(inContext: context, with: [3.0, 4.0]) as? Bool, false)
    }
    
    // MARK: Testing invalid parameter counts
    
    func testUnaryFunctionInvalidParameterCount() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let names = ["sqr", "sqrt"]
        
        for name in names {
            let function = try XCTUnwrap(library[name])

            for params in [[], [3.0, 4.0]] {
                XCTAssertThrowsError(try function.eval(inContext: context, with: params)) { error in
                    XCTAssertEqual(error as? EvalError, .invalidParameters)
                }
            }
        }
    }
    
    func testBinaryFunctionInvalidParameterCount() throws {
        let library = try XCTUnwrap(Library())
        let context = Context(library: library)
        let names = ["+", "-", "*", "/", "<=", "==", ">="]
        
        for name in names {
            let function = try XCTUnwrap(library[name])

            for params in [[], [3.0], [3.0, 4.0, 5.0]] {
                XCTAssertThrowsError(try function.eval(inContext: context, with: params)) { error in
                    XCTAssertEqual(error as? EvalError, .invalidParameters)
                }
            }
        }
    }
    
}


extension FunctionTests {
    
    // Shortcuts for MathRules types.
    typealias Context = MathRules.Context<Double>
    typealias Library = Context.Library
    typealias Function = MathRules.Function<Double>
    
}
