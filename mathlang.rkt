#lang typed/racket

;; The general expression type. An expression is either a variable
;; name like "x", a constant like 5 or a let-binding like "(let (x 5)
;; x)".
(define-type Expr (U Var Const Let Arith Cond));;表达式类型
(struct Const ([n : Number]) #:transparent);;数字常量
(struct Var   ([v : String]) #:transparent);;变量
(struct Let   ([v : Var] [e1 : Expr] [e2 : Expr]) #:transparent);;变量绑定

;; An arithmetic expression is the application of a mathematical
;; operator to its argument expressions.
(define-type Arith (U Plus Minus Times Div Neg Lt Gt Eq Cond));;运算符类型
(struct Plus  ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Minus ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Times ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Div   ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Neg   ([e1 : Expr]            ) #:transparent)
(struct Lt    ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Gt    ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Eq    ([e1 : Expr] [e2 : Expr]) #:transparent)
(struct Cond  ([b  : Expr] [e1 : Expr] [e2 : Expr]) #:transparent)
(struct Lambda([e1 : Expr] [e2 : Expr]) #:transparent)


;; This is a simple parser that produces an expression tree from a
;; tiny math language. It is very much like Racket.
(: parse (-> Any Expr))
(define (parse expr)
  (match expr
    [(? number?)      (Const expr)]
    [(? symbol?)      (Var (symbol->string expr))]
    [`(let (,v ,e1) ,e2) (Let (Var (format "~a" v)) (parse e1) (parse e2))]
    [`(+ ,e1 ,e2)       (Plus  (parse e1) (parse e2))]
    [`(- ,e1 ,e2)       (Minus (parse e1) (parse e2))]
    [`(* ,e1 ,e2)       (Times (parse e1) (parse e2))]
    [`(/ ,e1 ,e2)       (Div   (parse e1) (parse e2))]
    [`(neg   ,e1)       (Neg   (parse e1))]
    [`(< ,e1 ,e2)       (Lt  (parse e1) (parse e2))]
    [`(> ,e1 ,e2)       (Gt  (parse e1) (parse e2))]
    [`(= ,e1 ,e2)       (Eq  (parse e1) (parse e2))]
    [`(if ,b ,e1 ,e2)   (Cond  (parse b)  (parse e1) (parse e2))]
    [`(lambda (,e1) ,e2)(Lambda e1 e2)]
    [_ (error (format "Invalid syntax: \"~a\"" expr))]))

;; Now, we want to implement an interpreter for this
;; language. Interpreters do not compile the source code but execute
;; the expression tree.

;; First, we need a general environment to store values in:
(define-type (Envof A) (Listof (Pairof String A)))

;; Retrieve the value stored for the variable name.
(: env-load (All (A) (-> String (Envof A) A)))
(define (env-load s env)
    (match (assoc s env)
      [(cons _ v) v]
      [_ (error (format "Free variable: ~a" s))]))

;; Store a value under a variable name.
(: env-store (All (A) (-> String A (Envof A) (Envof A))))
(define (env-store sym val env)
  (cons (cons sym val) env))

;; Type of eval result
(define-type Val (U Number Boolean))
;; This is the type of environment for number values.
(define-type ValEnv (Envof Val))

(: eval (-> Expr ValEnv Val))
(define (eval expr env)
  (match expr
    [(Const c)      c]
    [(Var v)       (env-load v env)]
    [(Let (Var v) e1 e2)
                   ;; Evaluate e1, store it under v and evaluate e2.
                   (cond
                     [(procedure? e1) ()]
                     [else (eval e2 (env-store v (eval e1 env) env))])]
    [(Lambda e1 e2)(lambda (e1) (e2))]
    [(Plus  e1 e2) (+ (cast (eval e1 env) Real) (cast (eval e2 env) Real))]
    [(Minus e1 e2) (- (cast (eval e1 env) Real) (cast (eval e2 env) Real))]
    [(Times e1 e2) (* (cast (eval e1 env) Real) (cast (eval e2 env) Real))]
    [(Div   e1 e2) (/ (cast (eval e1 env) Real) (cast (eval e2 env) Real))]
    [(Gt    e1 e2) (> (cast (eval e1 env) Real) (cast (eval e2 env) Real))]
    [(Lt    e1 e2) (< (cast (eval e1 env) Real) (cast (eval e2 env) Real))]
    [(Neg      e1) (-            0              (cast (eval e1 env) Real))]
    [(Eq    e1 e2) (equal? (cast (eval e1 env) Real) (cast (eval e2 env) Real))]
    [(Cond b e1 e2) (if (cast (eval b env) Boolean) (cast (eval e1 env) Real) (cast (eval e2 env) Real))]
    [_ (error "Not yet implemented!")]))


;;
;; Some test expressions:

;; 1)
(eval (parse '(* 2 5)) '())
(eval (parse '(let (x (* 2 5)) (/ x x))) '())
;; 2)
(eval (parse '(neg 3)) '())
(eval (parse '(let (x 4) (neg x))) '())

;; 3
(eval (parse '(< 3 4)) '())
(eval (parse '(let (x 123) (= x 123))) '())

;; 4
(eval (parse '(if (< 1 2) 1 2)) '())
(eval (parse '(let (x 3) (let (y 2) (if (= x 0) y (/ y x))))) '())


;; The type that describes types in our language.
(define-type MathType (U 'Number 'Bool))

;; An environment that stores types for variable names.
(define-type TypeEnv (Envof MathType))


;; Infer the type of an expression, using the type environment tenv.
(: type (-> Expr TypeEnv MathType))
(define (type expr tenv)
  (match expr
    [(Const c) 'Number] ;; Always the number type!
    [(Var v)   (env-load v tenv)] ;; Look-up type for variable name.
    [(Let (Var v) e1 e2)
               ;; Infer the type of e1, store under v and infer type of e2.
               (type e2 (env-store v (type e1 tenv) tenv))]
    [(Plus e1 e2) (if (and (eq? 'Number (type e1 tenv))  ;; Check whether e1 has the right type.
                           (eq? 'Number (type e2 tenv))) ;; Check whether e2 has the right type.
                      'Number ;; If both have the right type, the result type is 'Number.
                      (error "Wrong type arguments for +-operator!"))] ;; Error otherwise.
    [(Times e1 e2) (if (and (eq? 'Number (type e1 tenv))  ;; Check whether e1 has the right type.
                           (eq? 'Number (type e2 tenv))) ;; Check whether e2 has the right type.
                      'Number ;; If both have the right type, the result type is 'Number.
                      (error "Wrong type arguments for * operator!"))] ;; Error otherwise.
    [(Div e1 e2) (if (and (eq? 'Number (type e1 tenv))  ;; Check whether e1 has the right type.
                           (eq? 'Number (type e2 tenv))) ;; Check whether e2 has the right type.
                      'Number ;; If both have the right type, the result type is 'Number.
                      (error "Wrong type arguments for / operator!"))] ;; Error otherwise.
    [_ (error "Not implemented yet!")]))
