TODOS:
- [X] Builtin Types
- [] Arrays
- [] User defined types
- [] variable declarations/definition
- [] Remaining operators eg: /, *, ||... (|"||"|"!"| |"!="|">"|"<"|">="|"<=")
- [] constant definitions
- [] function definitions
- [] control statements (if, for, while, etc.)
- [] assignment statements
- [] arithmetic expressions
- [] boolean expressions
- [] function calls which can have as parameters: expressions, other function calls, identifiers, constants
- [] Print eg: Print(“value of expression x+2  is:”,x+2) 
- [] Escape character si altele

Your programs should be structured in 3 sections: one section for global variables, another section for functions and user defined data types and a special function representing the entry point of the program


Exemplu :

```
BEGIN_GLOBAL
Var Int #i = 5;
END_GLOBAL
BEGIN_DEFINITIONS

Func #Ex(Int x) -> Int
BEGIN
    return x + 5;
END

END_DEFINITIONS

Func #Main() -> Int 
BEGIN
    #i = #Ex(32);
    #Print(#i);
END
```