# MathRules

## Functions

There are two types of functions:

* Built-in functions, like "+" and "sqrt". These functions cannot be overridden.
* User-defined functions with 0 or more arguments. User-defined functions may use other functions and are defined in in a RPN-style way.

Calling a function requires a *context* to resolve arguments and references to library functions.

User-defined functions are built from *instructions*. Instructions are 'entered' as on a RPN calculator. An instruction is either:

* a constant;
* an index in a parameter list;
* a (recursive) function call.
* an if-then-else condition.

## Dependencies

MathRules depends on the *swift-numerics* package.

## Status

Very early draft, with cleanup, renaming, unit testing and documentation to do first.
