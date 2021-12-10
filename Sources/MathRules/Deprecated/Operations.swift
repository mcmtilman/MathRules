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
    
    public typealias Context = MathRules.DeprecatedContext<T>
    public typealias Expression = MathRules.Expression<T>

    // MARK: Common implementation classes for operations
    
    /// 'Abstract' superclass representing state and initialization of operations involving one operand.
    public class UnaryOperation<A>: Expression {
        
        /// The single operand.
        let operand: A
        
        /// Initializes the operand.
        public init(_ operand: A) {
            self.operand = operand
        }
        
    }

    /// 'Abstract' superclass representing state and initialization of operations involving two operands.
    public class BinaryOperation<A, B>: Expression {
        
        /// Left-hand-side operand.
        let lhs: A
        
        /// Right-hand-side operand.
        let rhs: B
        
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
public extension Operation {
    
    // Represents a function call, identified by a function name and a list of parameters.
    /// Currently does not verify consistency of function and parameters.
    class Call: BinaryOperation<String, [Expression]> {
        
        // MARK: Evaluating

       /// Evaluates the function call in the context with given parameters and answers the result.
        /// Fails if the function does not exist in the context.
        /// Parameters are evaluated eagerly.
        public override func eval(in context: Context, parameters: [T]) -> T {
            guard let function = context[function: lhs] else { fatalError("Unknown function") }
        
            return function.eval(in: context, parameters: rhs.map { $0.eval(in: context, parameters: parameters) })
        }
        
        // MARK: Iterating

        // Visit the expression and retain elements of given type satisfying the predicate.
        override func filter<E>(_ expressionType: E.Type, _ predicate: (E) -> Bool) -> [E] {
            rhs.reduce(into: super.filter(expressionType, predicate)) { list, expression in
                list.append(contentsOf: expression.filter(expressionType, predicate))
            }
        }
        
    }
    
    /// Represents a constant value.
    class Literal: UnaryOperation<T> {
        
        // MARK: Computed properties

        // Answers the literal value.
        var value: T {
            operand
        }
        
        // MARK: Evaluating

        /// Evaluates the literal value in the context with given parameters and answers the literal.
        public override func eval(in context: Context, parameters: [T]) -> T {
            operand
        }
        
    }
    
    /// References a parameter in a context.
    class Parameter: UnaryOperation<Int> {
        
        // MARK: Computed properties
        
        // Answers the index in the list of parameters.
        var index: Int {
            operand
        }
        
        // MARK: Evaluating

        /// Looks up a parameter in the list of parameters.
        /// Fails if the parameter cannot be found.
        public override func eval(in context: Context, parameters: [T]) -> T {
            guard index >= 0 && index < parameters.count else { fatalError("Unknown parameter") }
        
            return parameters[index]
        }

    }
    
}


/**
 Core operations for types conforming to LosslessStringConvertible.
 */
public extension Operation.Literal where T: LosslessStringConvertible {
    
    // MARK: Initializing
    
    /// Creates a literal from given string.
    /// Fails if not valid.
    convenience init?(_ string: String) {
        guard let value = T(string) else { return nil }
        
        self.init(value)
    }

}
