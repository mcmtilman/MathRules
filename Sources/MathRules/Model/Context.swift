//
//  Context.swift
//  
//  Copyright © 2021 by Michel Tilman.
//  Licensed under Apache License v2.0.
//

/**
 Evaluation context for functions.
 Contains library of standard and user-defined functions.
 */
public struct Context {
    
    // MARK: -

    /// Function library
    public class Library {
        
        // MARK: -

        /// Maps function names to functions.
        public private (set) var functions = [String: [Function]]()
        
        // MARK: -
        
        /// Creates a library with given primitive functions.
        public init?() {
            for function in Function.primitiveFunctions() {
                functions[function.name, default: []].append(function)
            }
        }

        // MARK: -

        /// Registers given function. Fails if its name overrides a predefined function.
        public func register(function: Function) throws {
            if let f = (functions[function.name]?.first {
                let x = function.type.0.map(\.1)
                print(x)
                return distance($0.type.0.map(\.1), function) == 0 }) {
                if f.isPredefined { throw FunctionError.duplicateFunction(function.name)
                } else {
                    functions[function.name]?.removeAll { distance($0.type.0.map(\.1), function) == 0 }
                }
            }
           
            functions[function.name, default: []].append(function)
        }
        
        func distance(_ paramTypes: [Any.Type], _ function: Function) -> Int {
            guard paramTypes.count == function.parameterCount else { return Int.max }
            if paramTypes.count == 0 { return 0 }
            var distance = 0
            
            for i in 0 ..< paramTypes.count {
                let lhsType = paramTypes[i]
                let rhsType = function.type.0[i].1
                
                if lhsType != rhsType {
                    if lhsType == Int.self, rhsType == Real.self {
                        distance = distance | 1 << i
                    } else {
                        return Int.max
                    }
                }
            }
            
            return distance
        }
        
        /// Answers the function with given name or nil if none found.
        public subscript(name: String) -> Function? {
            functions[name]?.first
        }
        
        /// Answers the function with given name and parameters or nil if none found.
        public subscript(name: String, parameters: [Any]) -> Function? {
            guard let functions = functions[name] else { return nil }
            
            let types = parameters.map { type(of: $0) }
            var function: Function?
            var minDistance = Int.max
            
            for f in functions {
                let distance = distance(types, f)
                
                if distance < minDistance {
                    minDistance = distance
                    function = f
                }
            }
                
            return function
        }
   }
    
    // MARK: -

    // Library of functions.
    let library: Library
    
    // MARK: -
    
    /// Creates a context with given function library.
    public init(library: Library) {
        self.library = library
    }

    // MARK: -

    // Answers the function with given name or nil if none found.
    subscript(function name: String) -> Function? {
        library[name]
    }
    
}
