/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Reflection predicates
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

%% fd_var(+Var)
%
%  True iff Var is a CLP(ℤ) variable.

fd_var(X) :- get_attr(X, clpz, _).

%% fd_inf(+Var, -Inf)
%
%  Inf is the infimum of the current domain of Var.

fd_inf(X, Inf) :-
        (   fd_get(X, XD, _) ->
            domain_infimum(XD, Inf0),
            bound_portray(Inf0, Inf)
        ;   must_be(integer, X),
            Inf = X
        ).

%% fd_sup(+Var, -Sup)
%
%  Sup is the supremum of the current domain of Var.

fd_sup(X, Sup) :-
        (   fd_get(X, XD, _) ->
            domain_supremum(XD, Sup0),
            bound_portray(Sup0, Sup)
        ;   must_be(integer, X),
            Sup = X
        ).

%% fd_size(+Var, -Size)
%
%  Size is the number of elements of the current domain of Var, or the
%  atom *sup* if the domain is unbounded.

fd_size(X, S) :-
        (   fd_get(X, XD, _) ->
            domain_num_elements(XD, S0),
            bound_portray(S0, S)
        ;   must_be(integer, X),
            S = 1
        ).

%% fd_dom(+Var, -Dom)
%
%  Dom is the current domain (see `(in)/2`) of Var. This predicate is
%  useful if you want to reason about domains. It is _not_ needed if
%  you only want to display remaining domains; instead, separate your
%  model from the search part and let the toplevel display this
%  information via residual goals.
%
%  For example, to implement a custom labeling strategy, you may need
%  to inspect the current domain of a finite domain variable. With the
%  following code, you can convert a _finite_ domain to a list of
%  integers:
%
% ```
%  dom_integers(D, Is) :- phrase(dom_integers_(D), Is).
%
%  dom_integers_(I)      --> { integer(I) }, [I].
%  dom_integers_(L..U)   --> { numlist(L, U, Is) }, Is.
%  dom_integers_(D1\/D2) --> dom_integers_(D1), dom_integers_(D2).
% ```
%
%  Example:
%
% ```
%  ?- X in 1..5, X #\= 4, fd_dom(X, D), dom_integers(D, Is).
%  D = 1..3\/5,
%  Is = [1,2,3,5],
%  X in 1..3\/5.
% ```

fd_dom(X, Drep) :-
        (   fd_get(X, XD, _) ->
            domain_to_drep(XD, Drep)
        ;   must_be(integer, X),
            Drep = X..X
        ).
