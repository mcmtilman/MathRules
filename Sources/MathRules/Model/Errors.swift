//
//  Errors.swift
//  
//  Created by Michel Tilman on 10/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Function errors.
 */
public enum FunctionError: Error, Equatable {

    case invalidCondition
    case invalidInstructions
    case invalidParameterIndex(Int)
    case duplicateFunction(String)
    case undefinedFunction(String)

}


/**
 Evakuation errors.
 */
public enum EvalError: Error, Equatable {
    case invalidType
    case invalidParameters
    case unknownFunction(String)
    case runtimeError
}
