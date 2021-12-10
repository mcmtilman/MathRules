//
//  FunctionBuilder.swift
//  
//  Created by Michel Tilman on 10/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import RealModule

public struct FunctionBuilder<R: Real> {
    
    // MARK: -
    
    public enum Instruction {
        
        case cond
        case const(R)
        case param(Int)
        case apply(String)

    }
    
    // MARK: -
    
    class Node {
        
        let instruction: Instruction
        let children: [Node]?
        
        init(instruction: Instruction, children: [Node]? = nil) {
            self.instruction = instruction
            self.children = children
        }
        
        public func debugDescription() -> String {
            switch instruction {
            case let .const(c):
                return "\(c)"
            case let .param(p):
                return "$\(p)"
            case .cond:
                let params = children?.map { child in " \(child.debugDescription())" } ?? []
                
                return "(cond\(params.joined(separator: " ")))"
           case let .apply(f):
                let params = children?.map { child in " \(child.debugDescription())" } ?? []
                
                return "(\(f)\(params.joined(separator: " ")))"
            }
        }
        
    }
    
    // MARK: -
    
    func buildFunction(name: String, instructions: [Instruction], library: Context<R>.Library) throws -> Function<R> {
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
        
        return Function<R>(name: name, type: try inferType(instructions), isPrimitive: false) { params, context in
            try node.eval(inContext: context, with: params)
        }
    }
    
    private func inferType(_ instructions: [Instruction]) throws -> ([(String, Any.Type)], Any.Type) {
        var indices = Set<Int>()
        
        for instruction in instructions {
            if case let .param(index) = instruction {
                indices.insert(index)
            }
        }
        
        if let index = (indices.first { $0 < 0 || $0 >= indices.count }) { throw FunctionError.invalidParameterIndex(index) }

        return ((0 ..< indices.count).map { ("param\($0)", Double.self) }, Double.self)
    }
    
}
