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
    func eval(inContext context: Context<R>, with parameters: [Any]) throws -> Any {
        guard parameters.count == self.parameters.count else { throw EvalError.invalidParameters }
        
        return try expression(parameters, context)
    }

}


// MARK: -

extension FunctionBuilder.ConstantNode {
    
    // MARK: -
    
    /// Evaluates the constant node in given context.
    func eval<T>(inContext context: Context<T>, with parameters: [Any]) throws -> Any {
        value
    }
    
}


// MARK: -

extension FunctionBuilder.ParameterNode {
    
    // MARK: -
    
    /// Evaluates the parameter node in given context.
    ///
    /// The index must reference a valid parameter.
    func eval<T>(inContext context: Context<T>, with parameters: [Any]) throws -> Any {
        parameters[index]
    }
    
}


// MARK: -

extension FunctionBuilder.ConditionNode {
    
    // MARK: -

    /// Evaluates the condition node in given context.
    ///
    /// Throws an ``EvalError``.
    func eval<T>(inContext context: Context<T>, with parameters: [Any]) throws -> Any {
        let node = try bool(testNode.eval(inContext: context, with: parameters)) ? trueNode : falseNode
        
        return try node.eval(inContext: context, with: parameters)
    }
    
    // MARK: -

    // Casts given value into a Bool.
    // Throws an ``EvalError`` if not possible.
    private func bool(_ value: Any) throws -> Bool {
        switch value {
        case let boolean as Bool:
            return boolean
        default:
            throw EvalError.invalidType
        }
    }
}


// MARK: -

extension FunctionBuilder.ApplyNode {
    
    // MARK: -

    /// Evaluates the function call node in given context.
    ///
    /// The parameters must match the type of the function.
    /// Throws an ``EvalError``.
    func eval<T>(inContext context: Context<T>, with parameters: [Any]) throws -> Any {
        guard let function = context[function: name] else { throw EvalError.unknownFunction(name) }
        guard parameterNodes.count == function.parameters.count else { throw EvalError.invalidParameters }
        let parameters = try parameterNodes.map { try $0.eval(inContext: context, with: parameters) }

        return try function.eval(inContext: context, with: parameters)
    }

}


// MARK: -

extension FunctionBuilder.MapNode {
    
    // MARK: -

    /// Evaluates the map operator in given context.
    ///
    /// Throws an ``EvalError``.
    func eval<T>(inContext context: Context<T>, with parameters: [Any]) throws -> Any {
        guard let function = context[function: name], function.parameters.count == 1 else { throw EvalError.unknownFunction(name) }
        guard let list = try listNode.eval(inContext: context, with: parameters) as? [Any] else { throw EvalError.invalidType }

        return try list.map { try function.eval(inContext: context, with: [$0]) }
    }
    
}


extension FunctionBuilder.ReduceNode {
    
    // MARK: -

    /// Evaluates the map node in given context.
    ///
    /// Throws an ``EvalError``.
    func eval<T>(inContext context: Context<T>, with parameters: [Any]) throws -> Any {
        guard let function = context[function: name], function.parameters.count == 2 else { throw EvalError.unknownFunction(name) }
        let value = try initialResultNode.eval(inContext: context, with: parameters)
        guard let list = try listNode.eval(inContext: context, with: parameters) as? [Any] else { throw EvalError.invalidType }

        return try list.reduce(value) { try function.eval(inContext: context, with: [$0, $1]) }
    }

}
