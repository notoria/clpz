update_bounds(X, XD, XPs, XL, XU, NXL, NXU) -->
        (   NXL == XL, NXU == XU -> []
        ;   { domains_intersection(XD, from_to(NXL, NXU), NXD) },
            fd_put(X, NXD, XPs)
        ).

min_product(L1, U1, L2, U2, Min) :-
        Min cis min(min(L1*L2,L1*U2),min(U1*L2,U1*U2)).
max_product(L1, U1, L2, U2, Max) :-
        Max cis max(max(L1*L2,L1*U2),max(U1*L2,U1*U2)).

finite(n(_)).

in_(L, U, X) :-
        fd_get(X, XD, XPs),
        domains_intersection(XD, from_to(L,U), NXD),
        fd_put(X, NXD, XPs).

min_max_factor(L1, U1, L2, U2, L3, U3, Min, Max) :-
        % use findall/3 to forget auxiliary constraints that are only
        % needed temporarily for reasoning about domain boundaries
        findall(Min-Max, min_max_factor_(L1, U1, L2, U2, L3, U3, Min, Max), [Min-Max]).

min_max_factor_(L1, U1, L2, U2, L3, U3, Min, Max) :-
        (   U1 cis_lt n(0),
            L2 cis_lt n(0), U2 cis_gt n(0),
            L3 cis_lt n(0), U3 cis_gt n(0) ->
            maplist(in_(L1,U1), [Z1,Z2]),
            in_(L2, n(-1), X1), in_(n(1), U3, Y1),
            (   X1*Y1 #= Z1 ->
                (   fd_get(Y1, _, Inf1, Sup1, _) -> true
                ;   Inf1 = n(Y1), Sup1 = n(Y1)
                )
            ;   Inf1 = inf, Sup1 = n(-1)
            ),
            in_(n(1), U2, X2), in_(L3, n(-1), Y2),
            (   X2*Y2 #= Z2 ->
                (   fd_get(Y2, _, Inf2, Sup2, _) -> true
                ;   Inf2 = n(Y2), Sup2 = n(Y2)
                )
            ;   Inf2 = n(1), Sup2 = sup
            ),
            Min cis max(min(Inf1,Inf2), L3),
            Max cis min(max(Sup1,Sup2), U3)
        ;   L1 cis_gt n(0),
            L2 cis_lt n(0), U2 cis_gt n(0),
            L3 cis_lt n(0), U3 cis_gt n(0) ->
            maplist(in_(L1,U1), [Z1,Z2]),
            in_(L2, n(-1), X1), in_(L3, n(-1), Y1),
            (   X1*Y1 #= Z1 ->
                (   fd_get(Y1, _, Inf1, Sup1, _) -> true
                ;   Inf1 = n(Y1), Sup1 = n(Y1)
                )
            ;   Inf1 = n(1), Sup1 = sup
            ),
            in_(n(1), U2, X2), in_(n(1), U3, Y2),
            (   X2*Y2 #= Z2 ->
                (   fd_get(Y2, _, Inf2, Sup2, _) -> true
                ;   Inf2 = n(Y2), Sup2 = n(Y2)
                )
            ;   Inf2 = inf, Sup2 = n(-1)
            ),
            Min cis max(min(Inf1,Inf2), L3),
            Max cis min(max(Sup1,Sup2), U3)
        ;   min_factor(L1, U1, L2, U2, Min0),
            Min cis max(L3,Min0),
            max_factor(L1, U1, L2, U2, Max0),
            Max cis min(U3,Max0)
        ).

min_factor(L1, U1, L2, U2, Min) :-
        (   L1 cis_geq n(0), L2 cis_gt n(0), finite(U2) ->
            Min cis div(L1+U2-n(1),U2)
        ;   L1 cis_gt n(0), U2 cis_lt n(0) -> Min cis div(U1,U2)
        ;   L1 cis_gt n(0), L2 cis_geq n(0) -> Min = n(1)
        ;   L1 cis_gt n(0) -> Min cis -U1
        ;   U1 cis_lt n(0), U2 cis_leq n(0) ->
            (   finite(L2) -> Min cis div(U1+L2+n(1),L2)
            ;   Min = n(1)
            )
        ;   U1 cis_lt n(0), L2 cis_geq n(0) -> Min cis div(L1,L2)
        ;   U1 cis_lt n(0) -> Min = L1
        ;   L2 cis_leq n(0), U2 cis_geq n(0) -> Min = inf
        ;   Min cis min(min(div(L1,L2),div(L1,U2)),min(div(U1,L2),div(U1,U2)))
        ).
max_factor(L1, U1, L2, U2, Max) :-
        (   L1 cis_geq n(0), L2 cis_geq n(0) -> Max cis div(U1,L2)
        ;   L1 cis_gt n(0), U2 cis_leq n(0) ->
            (   finite(L2) -> Max cis div(L1-L2-n(1),L2)
            ;   Max = n(-1)
            )
        ;   L1 cis_gt n(0) -> Max = U1
        ;   U1 cis_lt n(0), U2 cis_lt n(0) -> Max cis div(L1,U2)
        ;   U1 cis_lt n(0), L2 cis_geq n(0) ->
            (   finite(U2) -> Max cis div(U1-U2+n(1),U2)
            ;   Max = n(-1)
            )
        ;   U1 cis_lt n(0) -> Max cis -L1
        ;   L2 cis_leq n(0), U2 cis_geq n(0) -> Max = sup
        ;   Max cis max(max(div(L1,L2),div(L1,U2)),max(div(U1,L2),div(U1,U2)))
        ).
