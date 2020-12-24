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

    /// Evaluates the receiver in the context with given parameters and answers the result.
    /// Should be abstract method.
    public func eval(in context: Context<T>, parameters: [T]) -> T {
        fatalError("Subclass responsibility")
    }
    
    // MARK: Iterating

    // Visit the expression and retain elements of given type satisfying the predicate.
    func filter<T>(_ expressionType: T.Type, _ predicate: (T) -> Bool) -> [T] {
        []
    }
    
}


/**
 Evaluation context for expressions.
 Contains dictionary of user-defined functions.
 */
public struct Context<T> {
    
    /// Function library
    public struct Library {
        
        // MARK: Stored properties

        /// Maps function names to functions.
        public let functions: [String: Function<T>]
        
        // MARK: Initializing
        
        /// Creates a library with given functions.
        /// Fails if there are duplicate function names.
        public init?(functions: [Function<T>] = []) {
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
    
    // MARK: Initializing
    
    /// Creates a context with given function library.
    public init(library: Library) {
        self.library = library
    }

    // MARK: Subscripting

    // Answers the function with given name or nil if none found.
    subscript(function name: String) -> Function<T>? {
        library[name]
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

    /// Create a function with given name, parameter names and expression.
    /// Fails if the function is not valid.
    public init?(name: String, parameters: [String] = [], expression: Expression<T>) {
        self.name = name
        self.parameters = parameters
        self.expression = expression
        
        guard isValid() else { return nil }
    }
    
    // MARK: Evaluating

    /// Evaluates the receiver in the context with given parameters and answers the result.
    public func eval(in context: Context<T>, parameters: [T]) -> T {
        expression.eval(in: context, parameters: parameters)
    }
    
    // MARK: Validating

    /// Answers if the function is valid:
    /// - The name must not be empty.
    /// - Nested parameter expressions must refer to valid parameter indices.
    /// - Parameter names must be unique.
    func isValid() -> Bool {
        guard !name.isEmpty else { return false }
        guard parameters.count == Set(parameters).count else { return false }
        
        return expression.filter(Operation<T>.Parameter.self) { param in
            param.index < 0 || param.index >= parameters.count
        }.isEmpty
    }
    
}
