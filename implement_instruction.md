#Tiny Math Language Implementation Instruction

**TANG Weiqiang**(201528013229047) **XIAO Yan**(201528013229127)

## Arithmetic operator implementation

This is a easy task, just follow the example code, write more Arith struct.

```lisp
 (define-type Arith (U Plus Minus Times Div Neg Lt Gt Eq Cond))
```

## Implement neg operator

Unlike these arithmetic operators, `neg`is an unary operator, it only needs one expression.

```lisp
(struct Neg ([e1 : Expr]) #:transparent)
```

## Boolean expression

So far, tiny mathlang dose not have Boolean type, in order to make `if` work, we add `Boolean` to `Val` union. 

```lisp
(define-type Val (U Number Boolean))
```

then we use `cast` to cast Val to Boolean according the context.

## If Statement

In this tiny mathlang, `if` is prefer to be called operator rather than statement, it just like the `condition?A:B`  in C programming language. So the `if`struct declare like this:

```lisp
(struct Cond  ([b  : Expr] [e1 : Expr] [e2 : Expr]) #:transparent)
```

## Lambda expression

### Key idea

The key idea of our implementation is that the execution of lambda expressions is to bind the data to variable, which is very similar to let expression. Having observed this point, we implement the lambda expression as the let expression, which seems a little tricky but effective.

### Lambda application

  As in Racket, the lambda expression is called like below:

```lisp
((lambda (x) (+ x 2)) 3)
```
We parse this line as `((lambda (,x) , e1), e2)`. If we consider e2 as 3, e1 as (+ x 2), then these two expressions are equal. Remember what let expression means, this is equal to `let (x 3) (+ x 2)`.
So it’s natural to implement the lambda application as let expression.

### Using lambda expression with Let

The usage is:

```lisp
(let (f (lambda (x) (+x 2))) (f 3))
```
It is equal to `(let (x 3) (+ x 2))`, so it can also be implemented by ordinary let expression.

##Type inference
Since we just have two types: Bool and Number, so it is not difficult to implement this. The only case which needs some attention is Cond because we need infer the type by its subclause.
