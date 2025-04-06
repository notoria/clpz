/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Conditions under which an equality can be compiled to built-in
   arithmetic. Their order is significant. (/)/2 becomes (//)/2.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

expr_conds(E, E)                 --> [integer(E)],
        { var(E), !, \+ monotonic }.
expr_conds(E, E)                 --> { integer(E) }.
expr_conds(?(E), E)              --> [integer(E)].
expr_conds(#E, E)                --> [integer(E)].
expr_conds(-E0, -E)              --> expr_conds(E0, E).
expr_conds(abs(E0), abs(E))      --> expr_conds(E0, E).
expr_conds(A0+B0, A+B)           --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(A0*B0, A*B)           --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(A0-B0, A-B)           --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(A0//B0, A//B)         -->
        expr_conds(A0, A), expr_conds(B0, B),
        [B =\= 0].
%expr_conds(A0/B0, AB)            --> expr_conds(A0//B0, AB).
expr_conds(min(A0,B0), min(A,B)) --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(max(A0,B0), max(A,B)) --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(A0 mod B0, A mod B)   -->
        expr_conds(A0, A), expr_conds(B0, B),
        [B =\= 0].
expr_conds(A0^B0, A^B)           -->
        expr_conds(A0, A), expr_conds(B0, B),
        [(B >= 0 ; A =:= -1)].
% Bitwise operations, added to make CLP(ℤ) usable in more cases
expr_conds(\ A0, \ A) --> expr_conds(A0, A).
expr_conds(A0<<B0, A<<B) --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(A0>>B0, A>>B) --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(A0/\B0, A/\B) --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(A0\/B0, A\/B) --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(xor(A0,B0), xor(A,B)) --> expr_conds(A0, A), expr_conds(B0, B).
expr_conds(lsb(A0), lsb(A)) --> expr_conds(A0, A).
expr_conds(msb(A0), msb(A)) --> expr_conds(A0, A).
expr_conds(popcount(A0), popcount(A)) --> expr_conds(A0, A).

clpz_expandable(_ in _).
clpz_expandable(_ #= _).
clpz_expandable(_ #>= _).
clpz_expandable(_ #=< _).
clpz_expandable(_ #> _).
clpz_expandable(_ #< _).
clpz_expandable(_ #\= _).
clpz_expandable(_ #<==> _).

clpz_expansion(Var in Dom, In) :-
        (   ground(Dom), Dom = L..U, integer(L), integer(U) ->
            expansion_simpler(
                (   integer(Var) ->
                    between:between(L, U, Var)
                ;   clpz:clpz_in(Var, Dom)
                ), In)
        ;   In = clpz:clpz_in(Var, Dom)
        ).
clpz_expansion(A #<==> B, Reif) :-
        nonvar(A),
        A =.. [F0,X0,Y0],
        clpz_builtin(F0, F),
        phrase(expr_conds(X0, X), Cs0, Cs),
        phrase(expr_conds(Y0, Y), Cs),
        list_goal(Cs0, Cond),
        Expr =.. [F,X,Y],
        expansion_simpler(( Cond, ( var(B) ; integer(B), clpz:between(0, 1, B) ) ->
                            (   Expr ->
                                B = 1
                            ;   B = 0
                            )
                          ; clpz:reify(A, RA),
                            clpz:reify(B, RA)
                          ), Reif).
clpz_expansion(X0 #= Y0, Equal) :-
        phrase(expr_conds(X0, X), CsX),
        phrase(expr_conds(Y0, Y), CsY),
        list_goal(CsX, CondX),
        list_goal(CsY, CondY),
        expansion_simpler(
                (   CondX ->
                    (   var(Y) -> Y is X
                    ;   CondY -> X =:= Y
                    ;   T is X, clpz:clpz_equal(T, Y0)
                    )
                ;   CondY ->
                    (   var(X) -> X is Y
                    ;   T is Y, clpz:clpz_equal(X0, T)
                    )
                ;   clpz:clpz_equal(X0, Y0)
                ), Equal).
clpz_expansion(X0 #>= Y0, Geq) :-
        phrase(expr_conds(X0, X), CsX),
        phrase(expr_conds(Y0, Y), CsY),
        list_goal(CsX, CondX),
        list_goal(CsY, CondY),
        expansion_simpler(
              (   CondX ->
                  (   CondY -> X >= Y
                  ;   T is X, clpz:clpz_geq(T, Y0)
                  )
              ;   CondY -> T is Y, clpz:clpz_geq(X0, T)
              ;   clpz:clpz_geq(X0, Y0)
              ), Geq).
clpz_expansion(X #=< Y,  Leq) :- clpz_expansion(Y #>= X, Leq).
clpz_expansion(X #> Y, Gt)    :- clpz_expansion(X #>= Y+1, Gt).
clpz_expansion(X #< Y, Lt)    :- clpz_expansion(Y #> X, Lt).
clpz_expansion(X0 #\= Y0, Neq) :-
        phrase(expr_conds(X0, X), CsX),
        phrase(expr_conds(Y0, Y), CsY),
        list_goal(CsX, CondX),
        list_goal(CsY, CondY),
        expansion_simpler(
              (   CondX ->
                  (   CondY -> X =\= Y
                  ;   T is X, clpz:clpz_neq(T, Y0)
                  )
              ;   CondY -> T is Y, clpz:clpz_neq(X0, T)
              ;   clpz:clpz_neq(X0, Y0)
              ), Neq).


clpz_builtin(#=, =:=).
clpz_builtin(#\=, =\=).
clpz_builtin(#>, >).
clpz_builtin(#<, <).
clpz_builtin(#>=, >=).
clpz_builtin(#=<, =<).

expansion_simpler((True->Then0;_), Then) :-
        is_true(True), !,
        expansion_simpler(Then0, Then).
expansion_simpler((False->_;Else0), Else) :-
        is_false(False), !,
        expansion_simpler(Else0, Else).
expansion_simpler((If->Then0;Else0), (If->Then;Else)) :- !,
        expansion_simpler(Then0, Then),
        expansion_simpler(Else0, Else).
expansion_simpler((A0,B0), (A,B)) :- !,
        expansion_simpler(A0, A),
        expansion_simpler(B0, B).
expansion_simpler(Var is Expr0, Goal) :-
        ground(Expr0), !,
        phrase(expr_conds(Expr0, Expr), Gs),
        (   maplist(call, Gs) -> Value is Expr, Goal = (Var = Value)
        ;   Goal = false
        ).
expansion_simpler(Var =:= Expr0, Goal) :-
        ground(Expr0), !,
        phrase(expr_conds(Expr0, Expr), Gs),
        (   maplist(call, Gs) -> Value is Expr, Goal = (Var =:= Value)
        ;   Goal = false
        ).
expansion_simpler(between:between(L,U,V), Goal) :-
        maplist(integer, [L,U,V]),
        !,
        (   between(L,U,V) -> Goal = true
        ;   Goal = false
        ).
expansion_simpler(Goal, Goal).

is_true(true).
is_true(integer(I))  :- integer(I).
% :- if(current_predicate(var_property/2)).
% is_true(var(X))      :- var(X), var_property(X, fresh(true)).
% is_false(integer(X)) :- var(X), var_property(X, fresh(true)).
% :- endif.
is_false((A,B))      :- is_false(A) ; is_false(B).
is_false(var(X)) :- nonvar(X).

:- dynamic(goal_expansion/1).

% user:goal_expansion(Goal0, Goal) :-
%         \+ goal_expansion(false),
%         clpz_expandable(Goal0),
%         clpz_expansion(Goal0, Goal).
