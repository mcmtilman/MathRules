//
//  Function.swift
//  
//  Created by Michel Tilman on 08/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import RealModule

/**
 Represents a primitive or a user-defined function.
 The implementation is encapsulated in a closure.
 */
public struct Function<R: Real> {
    
    // MARK: -
    
    /// The function name must be unique in a given context.
    let name: String
    
    /// Signature of the function. Parameters have a type and a name.
    let type: ([(String, Any.Type)], Any.Type)
    
    /// Flag indicating if this is a primitive functions..
    let isPrimitive: Bool

    /// An expression maps a list of parameters and a context onto a result.
    /// Expressions for primitive functions typically ignore the context.
    let expression: ([Any], Context<R>) throws -> Any
    
    // MARK: -
    
    /// Answers the parameter types,
    var parameters: [(String, Any.Type)] {
        type.0
    }
    
    // MARK: -

    /// Creates a function with given name, type and implementation.
    public init(name: String, type: ([(String, Any.Type)], Any.Type), isPrimitive: Bool = true, expression: @escaping ([Any], Context<R>) throws -> Any) {
        self.name = name
        self.type = type
        self.isPrimitive = isPrimitive
        self.expression = expression
    }

}

// MARK: - Primitive functions -

extension Function {
    
    // MARK: -

    // Casts given value into a Real number.
    // Throws an ``EvalError`` if not possible.
    private static func real(_ value: Any) throws -> R {
        switch value {
        case let real as R:
            return real
        case let integer as Int:
            return R(integer)
        default:
            throw EvalError.invalidType
        }
    }
    
    // MARK: -

    /// Returns a list of primitive arithmetic functions.
    static func arithmeticFunctions() -> [Function] {
        [
            Function(name: "+", type: ([("lhs", R.self), ("rhs", R.self)], R.self)) { params, _ in
                try real(params[0]) + real(params[1])
            },
            Function(name: "-", type: ([("lhs", R.self), ("rhs", R.self)], R.self)) { params, _ in
                try real(params[0]) - real(params[1])
            },
            Function(name: "*", type: ([("lhs", R.self), ("rhs", R.self)], R.self)) { params, _ in
                try real(params[0]) * real(params[1])
            },
            Function(name: "/", type: ([("lhs", R.self), ("rhs", R.self)], R.self)) { params, _ in
                try real(params[0]) / real(params[1])
            },
            Function(name: "sqr", type: ([("value", R.self)], R.self)) { params, _ in
                let value = try real(params[0])
                
                return value * value
            },
            Function(name: "sqrt", type: ([("value", R.self)], R.self)) { params, _ in
                try real(params[0]).squareRoot()
            },
        ]
    }
    
    /// Returns a list of primitive boolean functions.
    static func booleanFunctions() -> [Function] {
        [
            Function(name: "<=", type: ([("lhs", R.self), ("rhs", R.self)], Bool.self)) { params, _ in
                try real(params[0]) <= real(params[1])
            },
            Function(name: "==", type: ([("lhs", R.self), ("rhs", R.self)], Bool.self)) { params, _ in
                try real(params[0]) == real(params[1])
            },
            Function(name: ">=", type: ([("lhs", R.self), ("rhs", R.self)], Bool.self)) { params, _ in
                try real(params[0]) >= real(params[1])
            },
        ]
    }

    /// Returns a list of all primitive functions.
    static func primitiveFunctions() -> [Function] {
        arithmeticFunctions() + booleanFunctions()
    }

}
