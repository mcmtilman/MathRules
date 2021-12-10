//
//  Function.swift
//  
//  Created by Michel Tilman on 08/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import RealModule

public struct Function<R: Real> {
    
    // MARK: -
    
    let name: String
    
    let type: ([(String, Any.Type)], Any.Type)
    
    let isPrimitive: Bool

    /// An expression maps a list of parameters and a context onto  result.
    /// Expressions for primitive functions typically ignore the context.
    let expression: ([Any], Context<R>) throws -> Any
    
    var parameters: [(String, Any.Type)] {
        type.0
    }
    
    // MARK: -

    public init(name: String, type: ([(String, Any.Type)], Any.Type), isPrimitive: Bool = true, expression: @escaping ([Any], Context<R>) throws -> Any) {
        self.name = name
        self.type = type
        self.isPrimitive = isPrimitive
        self.expression = expression
    }

}

// MARK: - Standard functions -

extension Function {
    
    // MARK: -

    private static func real(_ value: Any) throws -> R {
        switch value {
        case let real as R:
            return real
        default:
            throw EvalError.invalidType
        }
    }
    
    // MARK: -

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

    static func primitiveFunctions() -> [Function] {
        arithmeticFunctions() + booleanFunctions()
    }

}
