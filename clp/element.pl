%% element(?N, +Vs, ?V)
%
%  The N-th element of the list of finite domain variables Vs is V.
%  Analogous to nth1/3.

element(N, Is, V) :-
    must_be(list, Is),
    Is = [_|_],
    list_length(Is, L),
    % #1 #=< #L,
    N in 1..L,
    element_(Is, 1, N, V),
    % list_foldl('@element'(N, V), Is, 1, _),
    propagator_from_constraint(pelement(N,Is,V), P),
    propagator_trigger(P, [N|Is]).

element_domain(V, VD) :-
        (   fd_get(V, VD, _) -> true
        ;   domain_singleton(VD, n(V))
        ).

element_([], _, _, _).
element_([I|Is], N0, N, V) :-
        #I #\= #V #==> #N #\= N0,
        integer_add(1, N0, N1),
        element_(Is, N1, N, V).

% '@element'(N, V, I, M0, M) :-
%     #I #\= #V #==> #N #\= M0,
%     integer_add(1, M0, M).

integers_remaining([], _, _, D, D).
integers_remaining([V|Vs], N0, Dom, D0, D) :-
        (   domain_contains(Dom, N0) ->
            element_domain(V, VD),
            domain_union(D0, VD, D1)
        ;   D1 = D0
        ),
        N1 is N0 + 1,
        integers_remaining(Vs, N1, Dom, D1, D).
