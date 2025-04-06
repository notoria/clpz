/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   contracting/1 -- subject to change

   This can remove additional domain elements from the boundaries.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

contracting(Vs) :-
        must_be(list, contracting(Vs)-1, Vs),
        maplist(finite_domain(contracting(Vs), 1), Vs),
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
            ;   V #\= Max,
                contracting(Vs, true, Vars)
            )
        ;   V #\= Min,
            contracting(Vs, true, Vars)
        ).
