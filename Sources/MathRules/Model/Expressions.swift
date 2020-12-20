//
//  Expressions.swift
//  MathRules
//
//  Created by Michel Tilman on 19/12/2020.
//  Copyright © 2020 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

public class Expression<T> {
    
    func eval(in context: Context<T>) -> T {
        fatalError("Subclass responsibility")
    }
    
}

public struct Context<T> {
    
    let functions: [String: Function<T>]
    
    let parameters: [T]
    
    subscript(function name: String) -> Function<T>? {
        functions[name]
    }
    
    subscript(parameter index: Int) -> T? {
        index >= 0 && index < parameters.count ? parameters[index] : nil
    }
    
    func withParameters(_ parameters: [T]) -> Self {
        Self(functions: functions, parameters: parameters)
    }
    
}


public struct Function<T> {
    
    let name: String
    
    let expression: Expression<T>
    
    func eval(in context: Context<T>) -> T {
        expression.eval(in: context)
    }
    
}
