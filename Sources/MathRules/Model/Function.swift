//
//  Function.swift
//  
//  Created by Michel Tilman on 08/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Represents a primitive or a user-defined function.
 */
public typealias Real = Double


// MARK: -

/**
 Constant value.
 */
public enum Value: Equatable {
    
    /// Boolean value.
    case bool(Bool)

    /// Integer value.
    case int(Int)

    /// Real value.
    case real(Real)

    /// List of Int.
    indirect case list([Value])
    
}


// MARK: -

/**
 Represents a primitive or a user-defined function.
 The implementation is encapsulated in a closure.
 */
public struct Function {
    
    // MARK: -
    
    /// The function name must be unique in a given context.
    public let name: String
    
    /// Signature of the function. Parameters have a type and a name.
    public let type: ([(String, Any.Type)], Any.Type)
    
    /// Flag indicating if this is a predefined function.
    public let isPredefined: Bool

    /// An expression maps a list of parameters and a context onto a result.
    /// Expressions for primitive functions typically ignore the context.
    let expression: ([Value], Context) throws -> Value
    
    // MARK: -
    
    /// Answers the number of parameters,
    public var parameterCount: Int {
        type.0.count
    }
    
    // MARK: -

    /// Creates a function with given name, type and implementation.
    public init(name: String, type: ([(String, Any.Type)], Any.Type), isPredefined: Bool = true, expression: @escaping ([Value], Context) throws -> Value) {
        self.name = name
        self.type = type
        self.isPredefined = isPredefined
        self.expression = expression
    }

}


// MARK: - Primitive functions -

extension Function {
    
    // MARK: -

    /// Returns a list of primitive arithmetic functions.
    static func arithmeticFunctions() -> [Function] {
        [
            Function(name: "+", type: ([("lhs", Real.self), ("rhs", Real.self)], Real.self)) { params, _ in
                try .real(real(params[0]) + real(params[1]))
            },
            Function(name: "-", type: ([("lhs", Real.self), ("rhs", Real.self)], Real.self)) { params, _ in
                try .real(real(params[0]) - real(params[1]))
            },
            Function(name: "*", type: ([("lhs", Real.self), ("rhs", Real.self)], Real.self)) { params, _ in
                try .real(real(params[0]) * real(params[1]))
            },
            Function(name: "/", type: ([("lhs", Real.self), ("rhs", Real.self)], Real.self)) { params, _ in
                try .real(real(params[0]) / real(params[1]))
            },
            Function(name: "sqr", type: ([("value", Real.self)], Real.self)) { params, _ in
                let value = try real(params[0])
                
                return .real(value * value)
            },
            Function(name: "sqrt", type: ([("value", Real.self)], Real.self)) { params, _ in
                try .real(real(params[0]).squareRoot())
            },
        ]
    }
    
    /// Returns a list of primitive boolean functions.
    static func booleanFunctions() -> [Function] {
        [
            Function(name: "<=", type: ([("lhs", Real.self), ("rhs", Real.self)], Bool.self)) { params, _ in
                try .bool(real(params[0]) <= real(params[1]))
            },
            Function(name: "==", type: ([("lhs", Real.self), ("rhs", Real.self)], Bool.self)) { params, _ in
                try .bool(real(params[0]) == real(params[1]))
            },
            Function(name: ">=", type: ([("lhs", Real.self), ("rhs", Real.self)], Bool.self)) { params, _ in
                try .bool(real(params[0]) >= real(params[1]))
            },
        ]
    }

    /// Returns a list of all primitive functions.
    static func primitiveFunctions() -> [Function] {
        arithmeticFunctions() + booleanFunctions()
    }

    // MARK: -

    // Casts given value into a Real number.
    // Throws an ``EvalError`` if not possible.
    private static func real(_ value: Value) throws -> Real {
        switch value {
        case let .real(v):
            return v
        case let .int(i):
            return Real(i)
        default:
            throw EvalError.invalidType
        }
    }
    
}
