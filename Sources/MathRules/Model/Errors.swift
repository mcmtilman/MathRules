//
//  Errors.swift
//  
//  Copyright © 2021 by Michel Tilman.
//  Licensed under Apache License v2.0.
//

/**
 Function errors.
 */
public enum FunctionError: Error, Equatable {

    /// An attempt is made to register a UDF overriding a predefined function.
    case duplicateFunction(String)
    
    /// The instruction stack is not correct.
    case invalidInstructions
    
    /// Parameter references should be in the range 0 ..< parameters count.
    case invalidParameterIndex(Int)
    
    /// Occurs when a function call or map references a non-existing function (name).
    case unknownFunction(String)

}


// MARK: -

/**
 Evaluation errors.
 */
public enum EvalError: Error, Equatable {
    
    /// An attempt is made to pass the wrong (number of) parameters to a function call or condition operator.
    case invalidParameters
    
    /// A parameter or constant does not have the expected type.
    case invalidType
    
    /// An attempt is made to call or map a function with a non-existing name.
    case unknownFunction(String)

}
