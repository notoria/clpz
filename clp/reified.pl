/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Reified predicates for use with predicates from library(reif).
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

clpz_t(Expr, T) :-
        Expr #<==> #B,
        zo_t(B, T).

#=(X, Y, T) :- clpz_t(X #= Y, T).

#<(X, Y, T) :- clpz_t(X #< Y, T).

zo_t(0, false).
zo_t(1, true).
