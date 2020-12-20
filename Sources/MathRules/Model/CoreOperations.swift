//
//  CoreFunctions.swift
//  MathRules
//
//  Created by Michel Tilman on 20/12/2020.
//

public enum Operation<T> {
    
    public typealias Context = MathRules.Context<T>
    public typealias Expression = MathRules.Expression<T>

    public class Literal: UnaryOperation<T, T> {
        
        override func eval(in context: Context) -> T {
            operand
        }
        
    }
    
    public class FunctionCall: BinaryOperation<T, String, [Expression]> {
        
        override func eval(in context: Context) -> T {
            guard let function = context[function: lhs] else { fatalError("Unknown function") }
        
            return function.eval(in: context.withParameters(rhs.map { $0.eval(in: context) }))
        }
        
    }
    

    public class Parameter: UnaryOperation<T, Int> {
        
        override func eval(in context: Context) -> T {
            guard let parameter = context[parameter: operand] else { fatalError("Unknown parameter") }
        
            return parameter
        }

    }
    
    static func call(_ function: String, parameters: [Expression]) -> FunctionCall {
        FunctionCall(function, parameters)
    }

    static func const(_ value: T) -> Literal {
        Literal(value)
    }

    static func param(_ index: Int) -> Parameter {
        Parameter(index)
    }

}


extension Operation where T: ExpressibleByStringLiteral, String == T.StringLiteralType {
    
    public class StringLiteral: UnaryOperation<T, String> {
        
        override func eval(in context: Context) -> T {
            T(stringLiteral: operand)
        }
        
    }
    
    static func const(_ string: String) -> StringLiteral {
        StringLiteral(string)
    }

}
