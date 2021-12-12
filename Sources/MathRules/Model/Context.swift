//
//  Context.swift
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
        
        /// Creates a library with given primitive functions.
        /// Fails if there are duplicate function names.
        public init?() {
            for function in Function<R>.primitiveFunctions() {
                guard functions.updateValue(function, forKey: function.name) == nil else { return nil }
            }
        }

        // MARK: -

        /// Answers the function with given name or nil if none found.
        subscript(name: String) -> Function<R>? {
            functions[name]
        }
        
        /// Registers given function. Fails if its name overrides a predefined function.
       func register(function: Function<R>) throws {
            if let function = functions[function.name], function.isPrimitive {
                throw FunctionError.duplicateFunction(function.name)
            } else {
                functions[function.name] = function
            }
        }
        
    }
    
    // MARK: -

    // Library of functions.
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
