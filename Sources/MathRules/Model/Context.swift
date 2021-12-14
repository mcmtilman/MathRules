//
//  Context.swift
//  
//  Created by Michel Tilman on 09/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Evaluation context for functions.
 Contains library of standard and user-defined functions.
 */
public struct Context {
    
    // MARK: -

    /// Function library
    public class Library {
        
        // MARK: -

        /// Maps function names to functions.
        public private (set) var functions = [String: Function]()
        
        // MARK: -
        
        /// Creates a library with given primitive functions.
        /// Fails if there are duplicate function names.
        public init?() {
            for function in Function.primitiveFunctions() {
                guard functions.updateValue(function, forKey: function.name) == nil else { return nil }
            }
        }

        // MARK: -

        /// Registers given function. Fails if its name overrides a predefined function.
       public func register(function: Function) throws {
            if let function = functions[function.name], function.isPredefined {
                throw FunctionError.duplicateFunction(function.name)
            } else {
                functions[function.name] = function
            }
        }
        
        /// Answers the function with given name or nil if none found.
        public subscript(name: String) -> Function? {
            functions[name]
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
    subscript(function name: String) -> Function? {
        library[name]
    }
    
}
