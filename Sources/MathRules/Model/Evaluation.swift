//
//  Evaluation.swift
//  
//  Created by Michel Tilman on 11/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

// MARK: - Evaluating -

public extension Function {
    
    // MARK: -

    /// Evaluates a function in given context.
    ///
    /// The parameters must match the type of the function.
    /// Throws an ``EvalError``.
    func eval(inContext context: Context, with parameters: [Value]) throws -> Value {
        guard parameters.count == parameterCount else { throw EvalError.invalidParameters }
        
        return try expression(parameters, context)
    }

}


// MARK: -

extension ConstantNode {
    
    // MARK: -
    
    /// Evaluates the constant node in given context.
    func eval(inContext context: Context, with parameters: [Value]) throws -> Value {
        value
    }
    
}


// MARK: -

extension ParameterNode {
    
    // MARK: -
    
    /// Evaluates the parameter node in given context.
    ///
    /// The index must reference a valid parameter.
    func eval(inContext context: Context, with parameters: [Value]) throws -> Value {
        parameters[index]
    }
    
}


// MARK: -

extension ConditionNode {
    
    // MARK: -

    /// Evaluates the condition node in given context.
    ///
    /// Throws an ``EvalError``.
    func eval(inContext context: Context, with parameters: [Value]) throws -> Value {
        let node = try bool(testNode.eval(inContext: context, with: parameters)) ? trueNode : falseNode
        
        return try node.eval(inContext: context, with: parameters)
    }
    
    // MARK: -

    // Casts given value into a Bool.
    // Throws an ``EvalError`` if not possible.
    private func bool(_ value: Value) throws -> Bool {
        switch value {
        case let .bool(boolean):
            return boolean
        default:
            throw EvalError.invalidType
        }
    }
}


// MARK: -

extension ApplyNode {
    
    // MARK: -

    /// Evaluates the function call node in given context.
    ///
    /// The parameters must match the type of the function.
    /// Throws an ``EvalError``.
    func eval(inContext context: Context, with parameters: [Value]) throws -> Value {
        guard let function = context[function: name] else { throw EvalError.unknownFunction(name) }
        guard parameterNodes.count == function.parameterCount else { throw EvalError.invalidParameters }
        let parameters = try parameterNodes.map { try $0.eval(inContext: context, with: parameters) }

        return try function.eval(inContext: context, with: parameters)
    }

}


// MARK: -

extension MapNode {
    
    // MARK: -

    /// Evaluates the map operator in given context.
    ///
    /// Throws an ``EvalError``.
    func eval(inContext context: Context, with parameters: [Value]) throws -> Value {
        guard let function = context[function: name], function.parameterCount == 1 else { throw EvalError.unknownFunction(name) }
        guard case let .list(list) = try listNode.eval(inContext: context, with: parameters) else { throw EvalError.invalidType }
        var params = [Value.int(0)]
        
        return try .list(list.map { params[0] = $0
            return try function.eval(inContext: context, with: params) })
    }
    
}


// MARK: -

extension ReduceNode {
    
    // MARK: -

    /// Evaluates the reduce operator in given context.
    ///
    /// Throws an ``EvalError``.
    func eval(inContext context: Context, with parameters: [Value]) throws -> Value {
        guard let function = context[function: name], function.parameterCount == 2 else { throw EvalError.unknownFunction(name) }
        let value = try initialResultNode.eval(inContext: context, with: parameters)
        guard case let .list(list) = try listNode.eval(inContext: context, with: parameters) else { throw EvalError.invalidType }
        var params = [Value.int(0), .int(0)]
        
        return try list.reduce(value) { params[0] = $0; params[1] = $1
            return try function.eval(inContext: context, with: params) }
    }

}
