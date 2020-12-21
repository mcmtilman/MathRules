//
//  Operations.swift
//  MathRules
//
//  Created by Michel Tilman on 20/12/2020.
//  Copyright © 2020 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Utility types for operations.
 */
public enum Operation<T> {
    
    // MARK: Convenience type aliasses
    
    public typealias Context = MathRules.Context<T>
    public typealias Expression = MathRules.Expression<T>

    // MARK: Common implementation classes for operations
    
    /// 'Abstract' superclass representing state and initialization of operations involving one operand.
    public class UnaryOperation<A>: Expression {
        
        /// The single operand.
        public let operand: A
        
        /// Initializes the operand.
        public init(_ operand: A) {
            self.operand = operand
        }
        
    }

    /// 'Abstract' superclass representing state and initialization of operations involving two operands.
    public class BinaryOperation<A, B>: Expression {
        
        /// Left- and right-hand-side operands.
        public let lhs: A, rhs: B
        
        /// Initializes the left- and right-hand-side operands.
        public init(_ lhs: A, _ rhs: B) {
            self.lhs = lhs
            self.rhs = rhs
        }
        
    }

}


/**
 Core operations.
 */
extension Operation {
    
    // MARK: Core operations
    
    /// Represents a function call, identified by a function name and a list of parameters.
    /// Currently does not verify consistency of function and parameters.
    public class FunctionCall: BinaryOperation<String, [Expression]> {
        
        /// Evaluates the function call in given context and answers the result.
        /// Fails if the function does not exist in the context.
        /// Parameters are evaluated eagerly.
       public override func eval(in context: Context) -> T {
            guard let function = context[function: lhs] else { fatalError("Unknown function") }
        
            return function.eval(in: context.withParameters(rhs.map { $0.eval(in: context) }))
        }
        
    }
    
    /// Represents a constant value.
    public class Literal: UnaryOperation<T> {
        
        /// Evaluates the literal call in given context and answers the literal.
        public override func eval(in context: Context) -> T {
            operand
        }
        
    }
    
    /// References a parameter in a context.
    public class Parameter: UnaryOperation<Int> {
        
        /// Looks up a parameter in the context.
        /// Fails if the parameter cannot be found.
        public override func eval(in context: Context) -> T {
            guard let parameter = context[parameter: operand] else { fatalError("Unknown parameter") }
        
            return parameter
        }

    }
    
    // MARK: Shorthand functions to create core operations
    
    /// Answers a function call.
    static func call(_ function: String, parameters: [Expression]) -> FunctionCall {
        FunctionCall(function, parameters)
    }

    /// Answers a literal value.
    static func cons(_ value: T) -> Literal {
        Literal(value)
    }

    /// Answers a parameter reference.
    static func param(_ index: Int) -> Parameter {
        Parameter(index)
    }

}


/**
 Core operations for types conforming to LosslessStringConvertible.
 */
extension Operation where T: LosslessStringConvertible {
    
    // MARK: Creating literals from strings
    
    /// Answers a literal value for gven type, or nil if not valid.
    static func const(_ string: String) -> Literal? {
        T(string).map(Literal.init)
    }

}
