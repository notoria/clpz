/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   All relevant constraints get a propagation opportunity whenever a
   new constraint is posted.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

reinforce(X) :-
        term_variables(X, Vs),
        maplist(reinforce_, Vs).

reinforce_(X) :-
        (   fd_var(X), fd_get(X, Dom, Ps) ->
            put_full(X, Dom, Ps)
        ;   true
        ).

put_full(X, Dom, Ps) :-
        Dom \== empty,
        (   Dom = from_to(F, F) -> F = n(X)
        ;   (   get_attr(X, clpz, Attr) ->
                Attr = clpz_attr(_,_,_,OldDom, _OldPs,Q),
                put_attr(X, clpz, clpz_attr(no,no,no,Dom,Ps,Q)),
                %format("putting dom: ~w\n", [Dom]),
                (   OldDom == Dom -> true
                ;   new_queue(Q), % TODO: queue?
                    phrase((trigger_props(Ps, X, OldDom, Dom),
                            do_queue), [Q], _)
                )
            ;   var(X) -> %format('\t~w in ~w .. ~w\n',[X,L,U]),
                new_queue(Q),
                put_attr(X, clpz, clpz_attr(no,no,no,Dom,Ps,Q))
            ;   true
            )
        ).
