;;; alambda adefine --- define-syntax

(define seq-str "no argument for required sequent variable")
(define fox-str "no argument for required unnamed variable")
(define key-str "no argument for required keyword variable")

(define-syntax wow-opt
  (syntax-rules ()
    ((wow-opt n v) v)
    ((wow-opt n v t)
     (wow-opt n v t n))
    ((wow-opt n v t ts)
     (let ((n v)) (if t ts (error 'alet* "bad argument" n 'n 't))))
    ((wow-opt n v t ts fs)
     (let ((n v)) (if t ts fs)))))

(define-syntax wow-cat-last
  (syntax-rules ()
    ((wow-cat-last z n d)
     (if (null? (cdr z))
	 (car z)
	 (error 'alet* "too many arguments" z)))
    ((wow-cat-last z n d t)
     (wow-cat-last z n d t n))
    ((wow-cat-last z n d t ts)
     (if (null? (cdr z))
	 (let ((n (car z)))
	   (if t ts (error 'alet* "too many argument" z)))
	 (error 'alet* "too many arguments" z)))
    ((wow-cat-last z n d t ts fs)
     (if (null? (cdr z))
	 (let ((n (car z)))
	   (if t ts fs))
	 (error 'alet* "too many arguments" z)))))
(define-syntax wow-cat!
  (syntax-rules ()
    ((wow-cat! z n d)
     (let ((n (car z)))
       (set! z (cdr z))
       n))
    ((wow-cat! z n d t)
     (wow-cat! z n d t n))
    ((wow-cat! z n d t ts)
     (let ((n (car z)))
       (if t
	   (begin (set! z (cdr z)) ts)
	   (let lp ((head (list n)) (tail (cdr z)))
	     (if (null? tail)
		 d
		 (let ((n (car tail)))
		   (if t
		       (begin (set! z (append (reverse head) (cdr tail))) ts)
		       (lp (cons n head) (cdr tail)))))))))
    ((wow-cat! z n d t ts fs)
     (let ((n (car z)))
       (set! z (cdr z))
       (if t ts fs)))))

(define (wow-key z k d)
  (let ((x (car z))
	(y (cdr z)))
    (if (null? y)
	(cons d z)
	(if (eq? k x)
	    y
	    (let lp ((head (list x (car y))) (tail (cdr y)))
	      (if (null? tail)
		  (cons d z)
		  (let ((x (car tail))
			(y (cdr tail)))
		    (if (null? y)
			(cons d z)
			(if (eq? k x)
			    (cons (car y) (append head (cdr y)))
			    (lp (cons x (cons (car y) head)) (cdr y)))))))))))
(define-syntax wow-key!
  (syntax-rules ()
    ((wow-key! z m (n k) d)
     (wow-key! z m (n k eq?) d))
    ((wow-key! z 2 (n k f) d)
     ;; two at a time: k1 1 k2 2 (k3 3) k4 4 k5 5 -> k2 2 k1 1 k4 4 k5 5
     (let ((x (car z))
     	   (y (cdr z)))
       (if (null? y)
     	   d
     	   (if (f k x)
     	       (begin (set! z (cdr y)) (car y))
     	       (let lp ((head (list x (car y))) (tail (cdr y)))
     		 (if (null? tail)
     		     d
     		     (let ((x (car tail))
     			   (y (cdr tail)))
     		       (if (null? y)
     			   d
     			   (if (f k x)
     			       (begin (set! z (append head (cdr y)))
     				      (car y))
     			       (lp (cons x (cons (car y) head)) (cdr y)))))))))))
    ((wow-key! z 1 (n k f) d)
     ;; one at a time: 1 2 3 4 (5 6) 7 8 -> 1 2 3 4 7 8
     (let ((x (car z))
     	   (y (cdr z)))
       (if (null? y)
     	   d
     	   (if (f k x)
     	       (begin (set! z (cdr y)) (car y))
     	       (let lp ((head (list x)) (tail y))
     		 (let ((x (car tail))
     		       (y (cdr tail)))
     		   (if (null? y)
     		       d
     		       (if (f k x)
     			   (begin (set! z (append (reverse head) (cdr y)))
     				  (car y))
     			   (lp (cons x head) y)))))))))
    ((wow-key! z m (n k) d t)
     (wow-key! z m (n k eq?) d t n))
    ((wow-key! z m (n k f) d t)
     (wow-key! z m (n k f) d t n))
    ((wow-key! z m (n k) d t ts)
     (wow-key! z m (n k eq?) d t ts))
    ((wow-key! z m (n k f) d t ts)
     (wow-key! z m (n k f) d t ts (error 'alet* "bad argument" n 'n 't)))
    ((wow-key! z m (n k) d t ts fs)
     (wow-key! z m (n k eq?) d t ts fs))
    ((wow-key! z 2 (n k f) d t ts fs)
     ;; two at a time: k1 1 k2 2 (k3 3) k4 4 k5 5 -> k2 2 k1 1 k4 4 k5 5
     (let ((x (car z))
     	   (y (cdr z)))
       (if (null? y)
     	   d
     	   (if (f k x)
     	       (let ((n (car y)))
     		 (set! z (cdr y))
     		 (if t ts fs))
     	       (let lp ((head (list x (car y))) (tail (cdr y)))
     		 (if (null? tail)
     		     d
     		     (let ((x (car tail))
     			   (y (cdr tail)))
     		       (if (null? y)
     			   d
     			   (if (f k x)
     			       (let ((n (car y)))
     				 (set! z (append head (cdr y)))
     				 (if t ts fs))
     			       (lp (cons x (cons (car y) head)) (cdr y)))))))))))
    ((wow-key! z 1 (n k f) d t ts fs)
     ;; one at a time: 1 2 3 4 (5 6) 7 8 -> 1 2 3 4 7 8
     (let ((x (car z))
     	   (y (cdr z)))
       (if (null? y)
     	   d
     	   (if (f k x)
     	       (let ((n (car y)))
     		 (set! z (cdr y))
     		 (if t ts fs))
     	       (let lp ((head (list x)) (tail y))
     		 (let ((x (car tail))
     		       (y (cdr tail)))
     		   (if (null? y)
     		       d
     		       (if (f k x)
     			   (let ((n (car y)))
     			     (set! z (append (reverse head) (cdr y)))
     			     (if t ts fs))
     			   (lp (cons x head) y)))))))))))

(define-syntax lamb
  (syntax-rules (quote quasiquote & unquote)
    ((lamb () ((i m) ...) () ((('n k f ...) t ...) . e) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda key-str 'n)
		    (wow-key! z 2 (n k f ...) (error 'alambda key-str 'n) t ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () ((i m mt ...) ...) () ((('n k f ...) t ...) . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda key-str 'n)
		     (wow-key! z 2 (n k f ...) (error 'alambda key-str 'n) t ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () () (z) ((('n k f ...) t ...) . e) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda key-str 'n)
		  (wow-key! z 2 (n k f ...) (error 'alambda key-str 'n) t ...))))
       (lamb () () (z) e bd ...)))
    ((lamb (df) () (z) ((('n k f ...)) . e) bd ...)
     (let ((n (if (null? z)
		  df
		  (wow-key! z 2 (n k f ...) df))))
       (lamb (df) () (z) e bd ...)))
    ((lamb (df) () (z) ((('n k f ...) d t ...) . e) bd ...)
     (let ((n (if (null? z)
		  d
		  (wow-key! z 2 (n k f ...) d t ...))))
       (lamb (df) () (z) e bd ...)))
    ((lamb () ((i m) ...) () (((`n k f ...) t ...) . e) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda key-str 'n)
		    (wow-key! z 1 (n k f ...) (error 'alambda key-str 'n) t ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () ((i m mt ...) ...) () (((`n k f ...) t ...) . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda key-str 'n)
		     (wow-key! z 1 (n k f ...) (error 'alambda key-str 'n) t ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () () (z) (((`n k f ...) t ...) . e) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda key-str 'n)
		  (wow-key! z 1 (n k f ...) (error 'alambda key-str 'n) t ...))))
       (lamb () () (z) e bd ...)))
    ((lamb (df) () (z) (((`n k f ...)) . e) bd ...)
     (let ((n (if (null? z)
		  df
		  (wow-key! z 1 (n k f ...) df))))
       (lamb (df) () (z) e bd ...)))
    ((lamb (df) () (z) (((`n k f ...) d t ...) . e) bd ...)
     (let ((n (if (null? z)
		  d
		  (wow-key! z 1 (n k f ...) d t ...))))
       (lamb (df) () (z) e bd ...)))
    ((lamb () ((i m) ...) () (('n t ts ...) . e) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda key-str 'n)
		    (wow-key! z 2 (n 'n eq?) (error 'alambda key-str 'n) t ts ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () ((i m mt ...) ...) () (('n t ts ...) . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda key-str 'n)
		     (wow-key! z 2 (n 'n eq?) (error 'alambda key-str 'n) t ts ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () () (z) (('n t ts ...) . e) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda key-str 'n)
		  (wow-key! z 2 (n 'n eq?) (error 'alambda key-str 'n) t ts ...))))
       (lamb () () (z) e bd ...)))
    ((lamb (df) () (z) (('n d t ...) . e) bd ...)
     (let ((n (if (null? z)
		  d
		  (wow-key! z 2 (n 'n eq?) d t ...))))
       (lamb (df) () (z) e bd ...)))
    ((lamb () ((i m) ...) () ((`n t ts ...) . e) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda key-str 'n)
		    (wow-key! z 1 (n 'n eq?) (error 'alambda key-str 'n) t ts ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () ((i m mt ...) ...) () ((`n t ts ...) . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda key-str 'n)
		     (wow-key! z 1 (n 'n eq?) (error 'alambda key-str 'n) t ts ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () () (z) ((`n t ts ...) . e) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda key-str 'n)
		  (wow-key! z 1 (n 'n eq?) (error 'alambda key-str 'n) t ts ...))))
       (lamb () () (z) e bd ...)))
    ((lamb (df) () (z) ((`n d t ...) . e) bd ...)
     (let ((n (if (null? z)
		  d
		  (wow-key! z 1 (n 'n eq?) d t ...))))
       (lamb (df) () (z) e bd ...)))
    ((lamb () ((i m) ...) () ((,n t ts ...)) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda fox-str 'n)
		    (wow-cat-last z n (error 'alambda fox-str 'n) t ts ...))))
	 bd ...)))
    ((lamb () ((i m mt ...) ...) () ((,n t ts ...)) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda fox-str 'n)
		     (wow-cat-last z n (error 'alambda fox-str 'n) t ts ...))))
	 bd ...)))
    ((lamb () () (z) ((,n t ts ...)) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda fox-str 'n)
		  (wow-cat-last z n (error 'alambda fox-str 'n) t ts ...))))
       bd ...))
    ((lamb (df) () (z) ((,n d t ...)) bd ...)
     (let ((n (if (null? z)
		  d
		  (wow-cat-last z n d t ...))))
       bd ...))
    ((lamb () ((i m) ...) () ((,n t ts ...) . e) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda fox-str 'n)
		    (wow-cat! z n (error 'alambda fox-str 'n) t ts ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () ((i m mt ...) ...) () ((,n t ts ...) . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda fox-str 'n)
		     (wow-cat! z n (error 'alambda fox-str 'n) t ts ...))))
	 (lamb () () (z) e bd ...))))
    ((lamb () () (z) ((,n t ts ...) . e) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda fox-str 'n)
		  (wow-cat! z n (error 'alambda fox-str 'n) t ts ...))))
       (lamb () () (z) e bd ...)))
    ((lamb (df) () (z) ((,n d t ...) . e) bd ...)
     (let ((n (if (null? z)
		  d
		  (wow-cat! z n d t ...))))
       (lamb (df) () (z) e bd ...)))
    ((lamb (df) () (z) (((n k) d) . e) bd ...)
     (let* ((z (if (null? z) (cons d z) (wow-key z k d)))
	    (n (car z))
	    (z (cdr z)))
       (lamb (df) () (z) e bd ...)))
    ((lamb () ((i m) ...) () ('n . e) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda key-str 'n)
		    (wow-key! z 2 (n 'n eq?) (error 'alambda key-str 'n)))))
	 (lamb () () (z) e bd ...))))
    ((lamb () ((i m mt ...) ...) () ('n . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda key-str 'n)
		     (wow-key! z 2 (n 'n eq?) (error 'alambda key-str 'n)))))
	 (lamb () () (z) e bd ...))))
    ((lamb () () (z) ('n . e) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda key-str 'n)
		  (wow-key! z 2 (n 'n eq?) (error 'alambda key-str 'n)))))
       (lamb () () (z) e bd ...)))
    ((lamb (df) () (z) ('n . e) bd ...)
     (let ((n (if (null? z)
		  df
		  (wow-key! z 2 (n 'n eq?) df))))
       (lamb (df) () (z) e bd ...)))
    ((lamb () ((i m) ...) () (`n . e) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda key-str 'n)
		    (wow-key! z 1 (n 'n eq?) (error 'alambda key-str 'n)))))
	 (lamb () () (z) e bd ...))))
    ((lamb () ((i m mt ...) ...) () (`n . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda key-str 'n)
		     (wow-key! z 1 (n 'n eq?) (error 'alambda key-str 'n)))))
	 (lamb () () (z) e bd ...))))
    ((lamb () () (z) (`n . e) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda key-str 'n)
		  (wow-key! z 1 (n 'n eq?) (error 'alambda key-str 'n)))))
       (lamb () () (z) e bd ...)))
    ((lamb (df) () (z) (`n . e) bd ...)
     (let ((n (if (null? z)
		  df
		  (wow-key! z 1 (n 'n eq?) df))))
       (lamb (df) () (z) e bd ...)))
    ((lamb () ((i m) ...) () (,n . e) bd ...)
     (lambda (m ... . z)
       (let ((n (if (null? z)
		    (error 'alambda fox-str 'n)
		    (wow-cat! z n (error 'alambda fox-str 'n)))))
	 (lamb () () (z) e bd ...))))
    ((lamb () ((i m mt ...) ...) () (,n . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...
	      (n (if (null? z)
		     (error 'alambda fox-str 'n)
		     (wow-cat! z n (error 'alambda fox-str 'n)))))
	 (lamb () () (z) e bd ...))))
    ((lamb () () (z) (,n . e) bd ...)
     (let ((n (if (null? z)
		  (error 'alambda fox-str 'n)
		  (wow-cat! z n (error 'alambda fox-str 'n)))))
       (lamb () () (z) e bd ...)))
    ((lamb (df) () (z) (,n . e) bd ...)
     (let ((n (if (null? z)
		  df
		  (wow-cat! z n df))))
       (lamb (df) () (z) e bd ...)))
    ((lamb () (im ...) () ((n t ts ...) . e) bd ...)
     (lamb () (im ... (i n t ts ...)) () e bd ...))
    ((lamb () () (z) ((n t ts ...) . e) bd ...)
     (let ((y (if (null? z) z (cdr z)))
	   (n (if (null? z) (error 'alambda seq-str 'n) (wow-opt n (car z) t ts ...))))
       (lamb () () (y) e bd ...)))
    ((lamb (df) () (z) ((n d t ...) . e) bd ...)
     (let ((y (if (null? z) z (cdr z)))
	   (n (if (null? z) d (wow-opt n (car z) t ...))))
       (lamb (df) () (y) e bd ...)))

    ((lamb () ((i m) ...) () ((n) . e) bd ...)
     (lambda (m ... . z)
       (lamb (n) () (z) e bd ...)))
    ((lamb () ((i m mt ...) ...) () ((n) . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...)
	 (lamb (n) () (z) e bd ...))))
    ((lamb () () (z) ((n) . e) bd ...)
     (lamb (n) () (z) e bd ...))

    ((lamb () ((i m) ...) () (() . e) bd ...)
     (lambda (m ... . z)
       (lamb (#f) () (z) e bd ...)))
    ((lamb () ((i m mt ...) ...) () (() . e) bd ...)
     (lambda (i ... . z)
       (let* ((m (wow-opt m i mt ...)) ...)
	 (lamb (#f) () (z) e bd ...))))
    ((lamb () () (z) (() . e) bd ...)
     (lamb (#f) () (z) e bd ...))

    ((lamb () (im ...) () (n . e) bd ...)
     (lamb () (im ... (i n)) () e bd ...))
    ((lamb () () (z) (n . e) bd ...)
     (let ((y (if (null? z) z (cdr z)))
	   (n (if (null? z) (error 'alambda seq-str 'n) (car z))))
       (lamb () () (y) e bd ...)))
    ((lamb (df) () (z) (n . e) bd ...)
     (let ((y (if (null? z) z (cdr z)))
	   (n (if (null? z) df (car z))))
       (lamb (df) () (y) e bd ...)))

    ((lamb () ((i n) ...) () e bd ...)
     (lambda (n ... . e) bd ...))
    ((lamb () ((i n t ...) ...) () () bd ...)
     (lambda (i ...)
       (let* ((n (wow-opt n i t ...)) ...)
	 bd ...)))
    ((lamb () ((i n t ...) ...) () e bd ...)
     (lambda (i ... . te)
       (let* ((n (wow-opt n i t ...)) ... (e te))
	 bd ...)))
    ((lamb df () (z) () bd ...)
     (if (null? z)
	 (let () bd ...)
	 (error 'alambda "too many arguments" z)))
    ((lamb df () (z) e bd ...)
     (let ((e z)) bd ...))))

(define-syntax alambda
  (syntax-rules ()
    ((alambda e bd ...) (lamb () () () e bd ...))))

(define-syntax adefine
  (syntax-rules ()
    ((adefine (name . args) body ...)
     (define name (alambda args body ...)))
    ((adefine name body)
     (define name body))))

;;; eof
