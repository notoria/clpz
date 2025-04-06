%% element(?N, +Vs, ?V)
%
%  The N-th element of the list of finite domain variables Vs is V.
%  Analogous to nth1/3.

element(N, Is, V) :-
        must_be(list, Is),
        length(Is, L),
        N in 1..L,
        element_(Is, 1, N, V),
        propagator_init_trigger([N|Is], pelement(N,Is,V)).

element_domain(V, VD) :-
        (   fd_get(V, VD, _) -> true
        ;   VD = from_to(n(V), n(V))
        ).

element_([], _, _, _).
element_([I|Is], N0, N, V) :-
        #I #\= #V #==> #N #\= N0,
        N1 is N0 + 1,
        element_(Is, N1, N, V).

integers_remaining([], _, _, D, D).
integers_remaining([V|Vs], N0, Dom, D0, D) :-
        (   domain_contains(Dom, N0) ->
            element_domain(V, VD),
            domains_union(D0, VD, D1)
        ;   D1 = D0
        ),
        N1 is N0 + 1,
        integers_remaining(Vs, N1, Dom, D1, D).
