//
//  FunctionBuilder.swift
//  
//  Created by Michel Tilman on 10/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import RealModule

/**
 * Builds a custom function from a RPN-like stack of instructions.
 */
public struct FunctionBuilder<R: Real> {
    
    // MARK: -
    
    /// 'RPN' instruction for building functions.
    public enum Instruction {
        
        /// If-then-else expression.
        case cond
        
        /// Represents a literal value.
        case const(R)
        
        /// Represents a zero-based reference to a parameter during execution.
        case param(Int)

        /// Represents a function call.
        case apply(String)

    }
    
    // MARK: -
    
    /// Building block for representing a user-defined function as a tree.
    class Node {
        
        // MARK: -

        /// Instruction represented by this node.
        let instruction: Instruction
        
        /// Optional child nodes. May represent parameters in case of an apply node,
        /// or condition and true-false branches in case of a condition node.
        let children: [Node]?
        
        // MARK: -

        /// Creates a node for given instruction with optional child nodes.
        init(instruction: Instruction, children: [Node]? = nil) {
            self.instruction = instruction
            self.children = children
        }
        
    }
    
    // MARK: -
    
    /// Creates a user-defined function with expression wrapping given instructions viewed as a tree.
    public func buildFunction(name: String, instructions: [Instruction], library: Context<R>.Library) throws -> Function<R> {
        let node = try buildNode(name: name, instructions: instructions, library: library)
    
        return Function<R>(name: name, type: try inferType(instructions), isPrimitive: false) { params, context in
            try node.eval(inContext: context, with: params)
        }
    }
    
    /// Creates a tree representation of the instruction stack.
    func buildNode(name: String, instructions: [Instruction], library: Context<R>.Library) throws -> Node {
        var stack = [Node]()
        
        for i in 0 ..< instructions.count {
            switch instructions[i] {
            case .const(_), .param(_):
                stack.append(Node(instruction: instructions[i]))
            case .cond:
                let children = Array(stack.suffix(3))
                
                stack.removeLast(3)
                stack.append(Node(instruction: instructions[i], children: children))
           case let .apply(name):
                guard let function = library[name] else { throw FunctionError.undefinedFunction(name) }
                let frame = function.parameters.count
                let children = frame == 0 ? nil : Array(stack.suffix(frame))
                
                stack.removeLast(frame)
                stack.append(Node(instruction: instructions[i], children: children))
            }
        }
        guard stack.count == 1, let node = stack.first else { throw FunctionError.invalidInstructions }
        
        return node
    }
    
    // MARK: -
    
    // 'Infers' the type of the function.
    // Currently limited to collecting the required parameters, assumed to be of type R.
    private func inferType(_ instructions: [Instruction]) throws -> ([(String, Any.Type)], Any.Type) {
        var indices = Set<Int>()
        
        for instruction in instructions {
            if case let .param(index) = instruction {
                indices.insert(index)
            }
        }
        
        if let index = (indices.first { $0 < 0 || $0 >= indices.count }) { throw FunctionError.invalidParameterIndex(index) }

        return ((0 ..< indices.count).map { ("param\($0)", R.self) }, Double.self)
    }
    
}


// MARK: - CustomDebugStringConvertible -

extension FunctionBuilder.Node: CustomDebugStringConvertible {
    
    // MARK: -

    /// Debug string representing this node in a Lisp-like format.
    var debugDescription: String {
        switch instruction {
        case let .const(c):
            return "\(c)"
        case let .param(p):
            return "$\(p)"
        case .cond:
            let params = children?.map { child in " \(child.debugDescription)" } ?? []
            
            return "(cond\(params.joined()))"
       case let .apply(f):
            let params = children?.map { child in " \(child.debugDescription)" } ?? []
            
            return "(\(f)\(params.joined()))"
        }
    }
    
}
