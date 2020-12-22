//
//  Expressions.swift
//  MathRules
//
//  Created by Michel Tilman on 19/12/2020.
//  Copyright © 2020 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 'Abstract' superclass representing expressions consisting of elementary operations.
 These building blocks may be combined in more complex structures.
 Would have preferred protocol and structs / recursive enumes, but both have some restrictions
 needlessly complicating the code.
 */
public class Expression<T> {
    
    // MARK: Evaluating

    /// Evaluates the receiver in given context and answers the result.
    /// Should be abstract method.
    public func eval(in context: Context<T>) -> T {
        fatalError("Subclass responsibility")
    }
    
}


/**
 Evaluation context for expressions.
 Contains dictionary of user-defined functions and parameters for the current expression
 to be evaluated.
 */
public struct Context<T> {
    
    /// Function library
    public struct Library {
        
        // MARK: Stored properties

        /// Maps function names to functions.
        public let functions: [String: Function<T>]
        
        // MARK: Initializing
        
        /// Creates a library with given functions.
        /// Fails if duplicate function names exist.
        public init?(functions: [Function<T>]) {
            self.functions = Dictionary(functions.map { f in (f.name, f) }) { (first, _) in first }
            
            guard self.functions.count == functions.count else { return nil }
        }

        // MARK: Subscripting

        // Answers the function with given name or nil if none found.
        subscript(name: String) -> Function<T>? {
            functions[name]
        }
        
    }
    
    // MARK: Stored properties

    // Library of user-defined functions.
    let library: Library
    
    // Parameters needed by expression to be evaluated.
    let parameters: [T]
    
    // MARK: Initializing
    
    /// Creates a context with given function library and actual parameters.
    public init(library: Library, parameters: [T]) {
        self.library = library
        self.parameters = parameters
    }

    // MARK: Subscripting

    // Answers the function with given name or nil if none found.
    subscript(function name: String) -> Function<T>? {
        library[name]
    }
    
    // Answers the parameter at given index or nil if out of range.
    subscript(parameter index: Int) -> T? {
        index >= 0 && index < parameters.count ? parameters[index] : nil
    }
    
    // MARK: Copying

    // Answers a copy of the context with the parameters replaced by given list.
    func withParameters(_ parameters: [T]) -> Self {
        Self(library: library, parameters: parameters)
    }
    
}


/**
 Represents user-defined functions.
 */
public struct Function<T> {
    
    // MARK: Stored properties

    /// Non-empty function name.
    public let name: String
    
    /// List of parameter names.
    /// Each name should appear only once in the list.
    public let parameters: [String]
    
    // Body of the function.
    let expression: Expression<T>
    
    // MARK: Initializing

    // Create a function with given name, parameter names and expression.
    public init(name: String, parameters: [String], expression: Expression<T>) {
        self.name = name
        self.parameters = parameters
        self.expression = expression
    }
    
    // MARK: Evaluating

    // Evaluates the receiver in given context and answers the result.
    func eval(in context: Context<T>) -> T {
        expression.eval(in: context)
    }
    
}
