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
    
    // MARK: Stored properties

    // User-defined functions.
    let functions: [String: Function<T>]
    
    // Parameters needed by expression being evaluated.
    let parameters: [T]
    
    // MARK: Initializing
    
    /// Creates a context with given uniquely named functions and actual parameters.
    public init(functions: [Function<T>], parameters: [T]) {
        self.init(Dictionary(uniqueKeysWithValues: functions.map { f in (f.name, f) }), parameters)
    }
    
    // MARK: Private initializing
    
    // Creates a context with given function map and actual parameters.
    private init(_ functions: [String: Function<T>], _ parameters: [T]) {
        self.functions = functions
        self.parameters = parameters
    }
    
    // MARK: Accessing by subscripting

    // Answers the function with given name or nil if not found.
    subscript(function name: String) -> Function<T>? {
        functions[name]
    }
    
    // Answers the parameter at given index or nil if not found.
    subscript(parameter index: Int) -> T? {
        index >= 0 && index < parameters.count ? parameters[index] : nil
    }
    
    // MARK: Copying

    // Answers a copy of the context with the parameters replaced by given list.
    func withParameters(_ parameters: [T]) -> Self {
        Self(functions, parameters)
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
