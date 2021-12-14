//
//  FunctionBuilder.swift
//  
//  Created by Michel Tilman on 10/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 'RPN' instructions for building a user-defined function.
 */
public enum Instruction {
    
    /// Represents a constant.
    case const(Value)
    
    /// Represents a zero-based reference to a parameter during execution.
    case param(Int)

    /// If-then-else expression.
    case cond
    
    /// Represents a function call.
    case apply(String)

    /// Represents the application of a transformation function on a list.
    case map(String)

    /// Represents the application of a reduction function on a list.
    case reduce(String)

}


// MARK: -

/**
  Interface for a function-as-tree node.
 */
protocol Node: AnyObject, CustomDebugStringConvertible {
    
    /// Answers the number of child nodes.
    var childCount: Int { get }
    
    /// Evalutes the node in given context with given variables and returns the result..
    ///
    /// Throws ``EvalError``.
    func eval(inContext context: Context, with parameters: [Value]) throws -> Value
    
}


// MARK: -

/**
 Represents a constant.
 */
class ConstantNode: Node {
    
    // MARK: -

    /// The constant value.
    let value: Value
    
    /// The number of child nodes.
    let childCount = 0
    
    // MARK: -

    /// Creates a constant node with given value.
    init(value: Value) {
        self.value = value
    }

}

// MARK: -

/**
 Represents a reference to a parameter.
 */
class ParameterNode: Node {
     
    // MARK: -

    /// Index in list of parameters.
    let index: Int
     
    /// The number of child nodes.
    let childCount = 0
    
    // MARK: -

    /// Creates a parameter node with given index.
    init(index: Int) {
         self.index = index
     }

 }
 
// MARK: -

/**
Represents an if-then-else expression.
*/
class ConditionNode: Node {
   
   // MARK: -

   /// Boolean expression, true branch and false branch.
   let testNode, trueNode, falseNode: Node
   
   /// The number of child nodes.
   var childCount: Int {
       3
   }
   
   // MARK: -

   /// Creates a condition node with test, true branch and false branch.
   ///
   /// Throws an ``EvalError`` when there are less than three nodes on the stack,
   init(stack: [Node]) throws {
       guard stack.count >= 3 else { throw FunctionError.invalidInstructions }
       
       self.testNode = stack[stack.count - 3]
       self.trueNode = stack[stack.count - 2]
       self.falseNode = stack[stack.count - 1]
   }

}

// MARK: -

/**
 Represents a function call.
 */
class ApplyNode: Node {
    
    // MARK: -

    /// Name of the unction to be called.
    let name: String
    
    /// Parameters of the function call.
    let parameterNodes: [Node]
    
    /// The number of child nodes.
    var childCount: Int {
        parameterNodes.count
    }
    
    // MARK: -

    /// Creates a functional call node with parameters on top of the stack.
    init(name: String, library: Context.Library, stack: [Node]) throws {
        guard let function = library[name] else { throw FunctionError.unknownFunction(name) }
        guard stack.count >= function.parameterCount else { throw FunctionError.invalidInstructions }
        
        self.name = name
        self.parameterNodes = Array(stack.suffix(function.parameterCount))
    }

}

// MARK: -

/**
 Represents the application of a function to a list of values.
 */
class MapNode: Node {
    
    // MARK: -

    /// Name of the function to be called.
    let name: String
    
    /// Node representing a list of values.
    let listNode: Node
    
    /// The number of child nodes.
    let childCount = 1
    
    // MARK: -

    /// Creates a map node with list parameter on top of the stack.
    init(name: String, library: Context.Library, stack: [Node]) throws {
        guard let function = library[name],
              function.parameterCount == 1 else { throw FunctionError.unknownFunction(name) }
        guard let node = stack.last else { throw FunctionError.invalidInstructions }
        
        self.name = name
        self.listNode = node
    }

}

// MARK: -

/**
 Represents the application of a reduction function to a list of values.
 */
class ReduceNode: Node {
    
    // MARK: -

    /// Name of the function to be called.
    let name: String
    
    /// Node representing the initial result of the reduce operation.
    let initialResultNode: Node
    
    /// Node representing a list of values.
    let listNode: Node
    
    /// The number of child nodes.
    let childCount = 2
    
    // MARK: -

    /// Creates a reduce node with initial result and list parameter nodes on top of the stack.
    init(name: String, library: Context.Library, stack: [Node]) throws {
        guard let function = library[name], function.parameterCount == 2 else { throw FunctionError.unknownFunction(name) }

        self.name = name
        self.initialResultNode = stack[stack.count - 2]
        self.listNode = stack[stack.count - 1]
    }

}


// MARK: -

/**
 * Builds a custom function from a RPN-like stack of instructions.
 */
public struct FunctionBuilder {
    
    // MARK: -
    
    /// Default initializer is internal.
    public init() {}
    
    // MARK: -
    
    /// Creates a user-defined function with an expression wrapping a tree representation of given instructions.
    public func buildFunction(name: String, instructions: [Instruction], library: Context.Library) throws -> Function {
        let node = try buildNode(name: name, instructions: instructions, library: library)
    
        return Function(name: name, type: try inferType(instructions), isPredefined: false) { params, context in
            try node.eval(inContext: context, with: params)
        }
    }
    
    /// Creates a tree representation of the instructions.
    func buildNode(name: String, instructions: [Instruction], library: Context.Library) throws -> Node {
        var stack = [Node]()
        
        for i in 0 ..< instructions.count {
            let node = try buildNode(instructions[i], library, stack)
            let range = stack.count - node.childCount ..< stack.count
            
            stack.replaceSubrange(range, with: [node])
        }
        guard stack.count == 1, let node = stack.first else { throw FunctionError.invalidInstructions }
        
        return node
    }
    
    // MARK: -

    // Returns a node depending on the type of instruction.
    private func buildNode(_ instruction: Instruction, _ library: Context.Library, _ stack: [Node]) throws -> Node {
        switch instruction {
        case let .const(value):
            return ConstantNode(value: value)
        case let .param(index):
            return ParameterNode(index: index)
        case .cond:
            return try ConditionNode(stack: stack)
        case let .apply(name):
            return try ApplyNode(name: name, library: library, stack: stack)
        case let .map(name):
            return try MapNode(name: name, library: library, stack: stack)
        case let .reduce(name):
            return try ReduceNode(name: name, library: library, stack: stack)
        }
    }
    
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

        return ((0 ..< indices.count).map { ("param\($0)", Real.self) }, Real.self)
    }
    
}


// MARK: - CustomDebugStringConvertible -

extension Value: CustomDebugStringConvertible {
    
    // MARK: -

    /// Debug description representing a value.
    public var debugDescription: String {
        switch self {
        case let .int(i):
            return "\(i)"
        case let .real(r):
            return "\(r)"
        case let .list(l):
            return "\(l.map { $0 as Any })"
        case let .bool(b):
            return b.description
        }
    }
    
}


// MARK: -

extension ConstantNode {
    
    // MARK: -

    /// Debug description representing a constant.
    var debugDescription: String {
        "\(value.debugDescription)"
    }
    
}


// MARK: -

extension ParameterNode {
    
    // MARK: -

     /// Debug description representing a parameter reference.
    var debugDescription: String {
        "$\(index)"
    }
    
}


// MARK: -

extension ConditionNode {
    
    // MARK: -

    /// Debug string representing this node in a Lisp-like format.
    var debugDescription: String {
        "(cond \(testNode.debugDescription) \(trueNode.debugDescription) \(falseNode.debugDescription))"
    }
    
}


// MARK: -

extension ApplyNode {
    
    // MARK: -

    /// Debug description representing a function call in a Lisp-like format.
    var debugDescription: String {
        let parameters = parameterNodes.map { node in " \(node.debugDescription)" }
        
        return "(\(name)\(parameters.joined()))"
    }
    
}


// MARK: -

extension MapNode {
    
    // MARK: -

    /// Debug description representing a map operation in a Lisp-like format.
    var debugDescription: String {
        "(map \"\(name)\" \(listNode.debugDescription))"
    }
    
}


// MARK: -

extension ReduceNode {
    
    // MARK: -

    /// Debug description representinga reduce operation in a Lisp-like format.
    var debugDescription: String {
        "(reduce \"\(name)\" \(initialResultNode.debugDescription) \(listNode.debugDescription))"
    }
    
}
