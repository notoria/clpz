/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   All relevant constraints get a propagation opportunity whenever a
   new constraint is posted.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

reinforce(X) :-
    term_variables(X, Vs),
    list_map('@reinforce', Vs).

'@reinforce'(X) :-
    (   fd_var(X),
        fd_get(X, Dom, Ps)
    ->  '@reinforce'(X, Dom, Ps)
    ;   true
    ).

'@reinforce'(X, Dom, Ps) :-
    domain_empty(Dom, false),
    (   domain_singleton(Dom, n(X0))
    ->  X = X0
    ;   (   get_attr(X, clpz, Attr)
        ->  Attr = clpz_attr(_,_,_,OldDom, _OldPs,Q),
            put_attr(X, clpz, clpz_attr(no,no,no,Dom,Ps,Q)),
            %format("putting dom: ~w\n", [Dom]),
            (   OldDom == Dom
            ->  true
            ;   queue_empty(Q), % TODO: queue?
                phrase(
                    (   propagators_queuegb(Ps, X, OldDom, Dom),
                        propagator_catalyze
                    ),
                    [Q],
                    _
                )
            )
        ;   var(X)
        ->  % portray_clause(user_error, unexpected),
            queue_empty(Q),
            put_attr(X, clpz, clpz_attr(no,no,no,Dom,Ps,Q))
        ;   true % QUESTION: why? Shouldn't `X` be a variable? What about the constraints?
        )
    ).
