//
//  MathRulesTests.swift
//  
//  Created by Michel Tilman on 05/11/2022.
//  Copyright © 2022 Michel Tilman.
//  Licensed under Apache License v2.0.
//

import XCTest

import MathRules

/**
 Common utility functions for tests.
 */
class MathRulesTests: XCTestCase {

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
    
    func list(_ elements: Int...) -> Value {
        list(elements)
    }

    func list<S: Sequence>(_ list: S) -> Value where S.Element == Int {
        .list(list.map(Value.int))
    }

    func list(_ elements: Real...) -> Value {
        .list(elements.map(Value.real))
    }

    // Shortcuts for MathRules types.
    typealias Library = Context.Library
    
}
