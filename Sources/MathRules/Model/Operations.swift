//
//  Operations.swift
//  MathRules
//
//  Created by Michel Tilman on 20/12/2020.
//  Copyright © 2020 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 'Abstract' superclass representing state and initialization of operations involving one operand.
 */
public class UnaryOperation<T, A>: Expression<T> {
    
    /// The single operand.
    public let operand: A
    
    /// Initializes the operand.
    public init(_ operand: A) {
        self.operand = operand
    }
    
}


/**
 'Abstract' superclass representing state and initialization of operations involving two operands.
 */
public class BinaryOperation<T, A, B>: Expression<T> {
    
    /// Left- and right-hand-side operands.
    public let lhs: A, rhs: B
    
    /// Initializes the left- and right-hand-side operands.
    public init(_ lhs: A, _ rhs: B) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
}
