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
    list_foldl('@element_constraint'(N, V), Is, 1, _),
    propagator_from_constraint(pelement(N,Is,V), P),
    propagator_trigger(P, [N|Is]).

'@element_constraint'(N, V, I, M0, M) :-
    integer_add(1, M0, M),
    #I #\= #V #==> #N #\= #M0.

'@element_domain'(V, VD) :-
    (   var(V)
    ->  fd_get(V, VD, _)
    ;   % integer(V),
        domain_singleton(VD, n(V))
    ).

'@element_domain'(Dom, V, N0-D0, N-D) :-
    integer_add(1, N0, N), % N #= N0+1.
    if_(domain_contains(Dom,N0),
        % list_foldl(call, [element_domain,domain_union(D0)], V, D),
        ('@element_domain'(V, VD), domain_union(VD, D0, D)),
        D = D0
    ).
