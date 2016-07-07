#Tiny Math Language Implementation Instruction


TANG Weiqiang(201528013229047) XIAO Yan(201528013229127)
2016年7月7日

Arithmetic operator implementation



Lambda expression
The key idea of our implementation is that the execution of lambda expressions is to bind the data to variable, which is very similar to let expression. Having observed this point, we implement the lambda expression as the let expression, which seems a little tricky but effective.

Create more bi-operate struct just like the Plus




5.1 Key idea


5.2 Lambda application
  As in Racket, the lambda expression is called like below:
	((lambda (x) (+ x 2)) 3)
  We parse this line as `((lambda (,x) , e1), e2)
  If we consider e2 as 3, e1 as (+ x 2), then these two expressions are equal. Remember what let expression means, this is equal to let (x 3) (+ x 2).
  So it’s natural to implement the lambda application as let expression.

5.3 Using lambda expression with Let
  The usage is:
	(let (f (lambda (x) (+x 2))) (f 3))
  It is equal to (let (x 3) (+ x 2)), so it can also be implemented by ordinary let expression.

6 Type inference
  Since we just have two types: Bool and Number, so it is not difficult to implement this. The only case which needs some attention is Cond because we need infer the type by its subclause.
