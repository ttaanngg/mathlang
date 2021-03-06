Project Tasks:

- [x] Implement the remaining arithmetic operators.
- [x] Add a new operator neg which takes only one argument and produces
the negative value of it.
- [x] Add boolean expressions, just like we have arithmetics, called
Bool. We need = < and > operators. Make sure to change the type of Env to (U Number Boolean) to also be able to store booleans. Also, you need to change the return type of eval to (U Number Boolean).
- [x] What fun are boolean expressions without if-statements? Implement an if-expression called Cond, with the following syntax:`(if b e1 e2)`. (You can parse it from \`(if ,b ,e1 ,e2)). If b evaluates to true, execute e1, otherwise execute e2.
- [x] What would it take to add lambda expressions and application to
the language? Can you implement it? Give it a try! All lambdas
should only be of type (-> Number Number).
- [x] This is the definition of a very simple and tiny type inference
algorithm. Because our language is not polymorphic, it only
contains types for numbers and booleans. Extend it such that all
the new functions you have added can be type checked.
