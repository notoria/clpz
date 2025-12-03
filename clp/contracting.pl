/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   contracting/1 -- subject to change

   This can remove additional domain elements from the boundaries.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

contracting(Vs) :-
    contracting(Vs, false, Vs).

contracting([], Repeat, Vars) :-
        (   call(Repeat) -> contracting(Vars, false, Vars)
        ;   true
        ).
contracting([V|Vs], Repeat, Vars) :-
        fd_inf(V, Min),
        (   \+ \+ (V = Min) ->
            fd_sup(V, Max),
            (   \+ \+ (V = Max) ->
                contracting(Vs, Repeat, Vars)
            ;   #V #\= Max,
                contracting(Vs, true, Vars)
            )
        ;   #V #\= Min,
            contracting(Vs, true, Vars)
        ).

contract(Vs) :-
    must_be(list, contract(Vs)-1, Vs),
    list_map(finite_domain(contract(Vs), 1), Vs),
    '@contract'(Vs).

'@contract'(Vs) :-
    if_(list_foldl('@contract', Vs, false), '@contract'(Vs), true).

'@contract'(V, T0, T) :-
    '@contract'(fd_inf, V, T0, T1),
    '@contract'(fd_sup, V, T1, T).

'@contract'(G_2, V, T0, T) :-
    call(G_2, V, I),
    (   \+ \+ (V = I)
    ->  T1 = false
    ;   #V #\= I,
        T1 = true
    ),
    '@contract_or'(T0, T1, T).

'@contract_or'(false, T, T).
'@contract_or'( true, _, true).
