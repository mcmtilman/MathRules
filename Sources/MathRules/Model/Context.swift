//
//  File.swift
//  
//  Created by Michel Tilman on 09/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import RealModule

/**
 Evaluation context for functions.
 Contains library of standard and user-defined functions.
 */
public struct Context<R: Real> {
    
    // MARK: -

    /// Function library
    public class Library {
        
        // MARK: -

        /// Maps function names to functions.
        public private (set) var functions = [String: Function<R>]()
        
        // MARK: -
        
        /// Creates a library with given functions and variables.
        /// Fails if there are duplicate function names.
        public init?() {
            for function in Function<R>.primitiveFunctions() {
                guard functions.updateValue(function, forKey: function.name) == nil else { return nil }
            }
        }

        // MARK: -

        // Answers the function with given name or nil if none found.
        subscript(name: String) -> Function<R>? {
            functions[name]
        }
        
        func register(function: Function<R>) throws {
            if let function = functions[function.name], function.isPrimitive {
                throw FunctionError.duplicateFunction(function.name)
            } else {
                functions[function.name] = function
            }
        }
        
    }
    
    // MARK: -

    // Library of user-defined functions.
    let library: Library
    
    // MARK: -
    
    /// Creates a context with given function library.
    public init(library: Library) {
        self.library = library
    }

    // MARK: -

    // Answers the function with given name or nil if none found.
    subscript(function name: String) -> Function<R>? {
        library[name]
    }
    
}

// MARK: - Evaluating -

public extension Function {
    
    func eval(inContext context: Context<R>, with parameters: [Any]) throws -> Any {
        guard parameters.count == self.parameters.count else { throw EvalError.invalidParameters }
        
        return try expression(parameters, context)
    }

}

// MARK: -

extension FunctionBuilder.Node {
    
    private func bool(_ value: Any) throws -> Bool {
        switch value {
        case let boolean as Bool:
            return boolean
        default:
            throw EvalError.invalidType
        }
    }
    
    func eval(inContext context: Context<R>, with parameters: [Any]) throws -> Any {
        switch instruction {
        case let .const(c):
            return c
        case let .param(p):
            return parameters[p]
        case .cond:
            guard let nodes = children, nodes.count == 3 else { throw EvalError.invalidParameters }
            
            let path = try bool(nodes[0].eval(inContext: context, with: parameters)) ? 1 : 2
            return try nodes[path].eval(inContext: context, with: parameters)
        case let .apply(name):
            guard let function = context[function: name] else { throw EvalError.unknownFunction(name) }
            let params = try children?.map { try $0.eval(inContext: context, with: parameters) } ?? []

            return try function.eval(inContext: context, with: params)
        }
    }
    
}
