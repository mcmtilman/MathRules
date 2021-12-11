# MathRules

## Functions

There are two types of functions:

* Built-in functions, like "+" and "sqrt". These functions are implemented in Swift and cannot be overridden.
* User-defined functions (UDF) with 0 or more arguments. User-defined functions may call other functions and are defined in in a RPN-style way.

Calling a function requires a *context* to resolve arguments and calls to library functions.

User-defined functions are built from *instructions*. Instructions are 'entered' as on a RPN calculator. An instruction is either:

* a constant;
* an index in a parameter list;
* an if-then-else condition;
* a (recursive) function call;
* mapping a function onto a list of variable.

## Dependencies

MathRules depends on the *swift-numerics* package.

## Status

Very early draft, with cleanup, renaming, unit testing and documentation to do first.
