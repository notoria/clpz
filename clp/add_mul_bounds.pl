update_bounds(X, XD, XPs, XL, XU, NXL, NXU) -->
        (   NXL == XL, NXU == XU -> []
        ;   { domain_from_bounds(NXL, NXU, D), domain_inter(XD, D, NXD) },
            fd_put(X, NXD, XPs)
        ).

min_max_product(L0, U0, L1, U1, Min, Max) :-
    Min cis min(min(L0*L1,L0*U1),min(U0*L1,U0*U1)),
    Max cis max(max(L0*L1,L0*U1),max(U0*L1,U0*U1)).

min_product(L1, U1, L2, U2, Min) :-
        Min cis min(min(L1*L2,L1*U2),min(U1*L2,U1*U2)).
max_product(L1, U1, L2, U2, Max) :-
        Max cis max(max(L1*L2,L1*U2),max(U1*L2,U1*U2)).

finite(n(_)).

in_(L, U, X) :-
        fd_get(X, XD, XPs),
        domain_from_bounds(L, U, D),
        domain_inter(XD, D, NXD),
        fd_put(X, NXD, XPs).

min_max_contracting(L0, U0, L1, U1, L2, U2, Min, Max) :-
    (   L3 cis L2+n(1), L3 cis_gt L2, L3 cis_le U2,
        list_map(\=(n(0)), [L1,U1,L3,U2]),
        min_max_product(L1, U1, L3, U2, L4, U4),
        L4 cis_le L0, U0 cis_le U4
    ->  min_max_contracting(L0, U0, L1, U1, L3, U2, Min, Max)
    ;   U3 cis U2-n(1), U3 cis_lt U2, L2 cis_le U3,
        list_map(\=(n(0)), [L1,U1,L2,U3]),
        min_max_product(L1, U1, L2, U3, L4, U4),
        L4 cis_le L0, U0 cis_le U4
    ->  min_max_contracting(L0, U0, L1, U1, L2, U3, Min, Max)
    ;   Min = L2,
        Max = U2
    ).

min_max_factor_(<, <, <, <, L0, U0, L1, U1, Min, Max) :-
    Min cis max(n(1),L0 div U1),
    Max cis max(Min,U0 div L1).
min_max_factor_(=, <, <, <, _L0, U0, L1, _U1, Min, Max) :-
    Min = n(0),
    Max cis U0 div L1.
min_max_factor_(=, =, <, <, _L0, _U0, _L1, _U1, n(0), n(0)).
min_max_factor_(>, =, <, <, L0, _U0, L1, _U1, Min, Max) :-
    Max = n(0),
    Min cis -(-L0 div L1).
min_max_factor_(>, >, <, <, L0, U0, L1, U1, Min, Max) :-
    Max cis min(n(-1),-(-U0 div U1)),
    Min cis min(Max,-(-L0 div L1)).
min_max_factor_(>, <, <, <, L0, U0, L1, U1, Min, Max) :-
    min_max_factor_(>, =, <, <, L0, n(0), L1, U1, L3, U3),
    min_max_factor_(=, <, <, <, n(0), U0, L1, U1, L4, U4),
    Min cis min(L3,L4),
    Max cis max(U3,U4).
%
min_max_factor_(<, <, =, <, L0, U0, _L1, U1, Min, Max) :-
    Min cis max(n(1),L0 div U1), % floor
    Max = U0.
min_max_factor_(=, <, =, <, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(=, =, =, <, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, =, =, <, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, >, =, <, L0, U0, _L1, U1, Min, Max) :-
    Max cis min(n(-1),-(-U0 div U1)), % floor
    Min = L0.
min_max_factor_(>, <, =, <, _L0, _U0, _L1, _U1, inf, sup).
%
min_max_factor_(<, <, =, =, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(=, <, =, =, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(=, =, =, =, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, =, =, =, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, >, =, =, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, <, =, =, _L0, _U0, _L1, _U1, inf, sup).
%
min_max_factor_(<, <, >, =, L0, U0, L1, _U1, Min, Max) :-
    Max cis min(n(-1),-(L0 div -L1)), % floor
    Min cis -U0.
min_max_factor_(=, <, >, =, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(=, =, >, =, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, =, >, =, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, >, >, =, L0, U0, L1, _U1, Min, Max) :-
    Min cis max(n(1),U0 div L1), % floor
    Max cis -L0.
min_max_factor_(>, <, >, =, _L0, _U0, _L1, _U1, inf, sup).
%
min_max_factor_(<, <, >, >, L0, U0, L1, U1, Min, Max) :-
    Max cis min(n(-1),-(L0 div -L1)),
    Min cis min(Max,-(U0 div -U1)).
min_max_factor_(=, <, >, >, _L0, U0, _L1, U1, Min, Max) :-
    Max = n(0),
    Min cis -(U0 div -U1).
min_max_factor_(=, =, >, >, _L0, _U0, _L1, _U1, n(0), n(0)).
min_max_factor_(>, =, >, >, L0, _U0, _L1, U1, Min, Max) :-
    Min = n(0),
    Max cis L0 div U1.
min_max_factor_(>, >, >, >, L0, U0, L1, U1, Min, Max) :-
    Min cis max(n(1),U0 div L1),
    Max cis max(Min,L0 div U1).
min_max_factor_(>, <, >, >, L0, U0, L1, U1, Min, Max) :-
    min_max_factor_(>, =, >, >, L0, n(0), L1, U1, L3, U3),
    min_max_factor_(=, <, >, >, n(0), U0, L1, U1, L4, U4),
    Min cis min(L3,L4),
    Max cis max(U3,U4).
%
min_max_factor_(<, <, >, <, L0, U0, L1, U1, Min, Max) :-
    min_max_factor_(<, <, >, =, L0, U0, L1, n(0), L3, U3),
    min_max_factor_(<, <, =, <, L0, U0, n(0), U1, L4, U4),
    Min cis min(L3,L4),
    Max cis max(U3,U4).
min_max_factor_(=, <, >, <, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(=, =, >, <, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, =, >, <, _L0, _U0, _L1, _U1, inf, sup).
min_max_factor_(>, >, >, <, L0, U0, L1, U1, Min, Max) :-
    min_max_factor_(>, >, >, =, L0, U0, L1, n(0), L3, U3),
    min_max_factor_(>, >, =, <, L0, U0, n(0), U1, L4, U4),
    Min cis min(L3,L4),
    Max cis max(U3,U4).
min_max_factor_(>, <, >, <, _L0, _U0, _L1, _U1, inf, sup).

min_max_factor(L0, U0, L1, U1, Min, Max) :-
    cis_compare(O0, n(0), L0),
    cis_compare(O1, n(0), U0),
    cis_compare(O2, n(0), L1),
    cis_compare(O3, n(0), U1),
    min_max_factor_(O0, O1, O2, O3, L0, U0, L1, U1, Min, Max).

min_max_factor__(<, <, _L2, _U2, _L3, _U3, _L4, _U4, L5, U5, L6, U6, Min, Max) :-
    Min cis min(L5,L6),
    Max cis max(U5,U6).
min_max_factor__(<, =, _L2, _U2, _L3, _U3, _L4, _U4, L5, U5, L6, U6, Min, Max) :-
    Min cis min(L5,L6),
    Max cis max(U5,U6).
min_max_factor__(=, <, _L2, _U2, _L3, _U3, _L4, _U4, L5, U5, L6, U6, Min, Max) :-
    Min cis min(L5,L6),
    Max cis max(U5,U6).
min_max_factor__(=, =, _L2, _U2, _L3, _U3, _L4, _U4, L5, U5, L6, U6, Min, Max) :-
    Min cis min(L5,L6),
    Max cis max(U5,U6).
min_max_factor__(<, >, _L2, _U2, _L3, _U3, _L4, _U4, L5, U5, _L6, _U6, Min, Max) :-
    Min cis L5,
    Max cis U5.
min_max_factor__(=, >, _L2, _U2, _L3, _U3, _L4, _U4, L5, U5, _L6, _U6, Min, Max) :-
    Min cis L5,
    Max cis U5.
min_max_factor__(>, <, _L2, _U2, _L3, _U3, _L4, _U4, _L5, _U5, L6, U6, Min, Max) :-
    Min cis L6,
    Max cis U6.
min_max_factor__(>, =, _L2, _U2, _L3, _U3, _L4, _U4, _L5, _U5, L6, U6, Min, Max) :-
    Min cis L6,
    Max cis U6.
min_max_factor__(>, >, L2, U2, L3, U3, L4, U4, _L5, _U5, _L6, _U6, Min, Max) :-
    Min cis max(L2,min(U2,min(L3,L4))),
    Max cis min(U2,max(L2,max(U3,U4))).

min_max_factor_(<, <, <, <, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(<, <, <, <, L0, U0, L1, U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(<, <, =, <, L0, U0, _L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(<, <, <, <, L0, U0, n(1), U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(<, <, =, =, _L0, _U0, _L1, _U1, L2, U2, Min, Max) :-
    Min cis max(L2,inf),
    Max cis min(U2,sup).
min_max_factor_(<, <, >, =, L0, U0, L1, _U1, L2, U2, Min, Max) :-
    min_max_factor_(<, <, >, >, L0, U0, L1, n(-1), L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(<, <, >, >, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(<, <, >, >, L0, U0, L1, U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(<, <, >, <, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(<, <, >, >, L0, U0, L1, n(-1), L3, U3),
    min_max_factor_(<, <, <, <, L0, U0, n(1), U1, L4, U4),
    L5 cis max(L2,L3), U5 cis min(U2,U3),
    L6 cis max(L2,L4), U6 cis min(U2,U4),
    cis_compare(O0, L5, U5),
    cis_compare(O1, L6, U6),
    min_max_factor__(O0, O1, L2, U2, L3, U3, L4, U4, L5, U5, L6, U6, Min, Max).
min_max_factor_(=, <, O2, O3, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(=, <, O2, O3, L0, U0, L1, U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(=, =, O2, O3, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(=, =, O2, O3, L0, U0, L1, U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(>, =, O2, O3, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(>, =, O2, O3, L0, U0, L1, U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(>, >, <, <, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(>, >, <, <, L0, U0, L1, U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(>, >, =, <, L0, U0, _L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(>, >, <, <, L0, U0, n(1), U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(>, >, =, =, _L0, _U0, _L1, _U1, L2, U2, Min, Max) :-
    Min cis max(L2,inf),
    Max cis min(U2,sup).
min_max_factor_(>, >, >, =, L0, U0, L1, _U1, L2, U2, Min, Max) :-
    min_max_factor_(>, >, >, >, L0, U0, L1, n(-1), L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(>, >, >, >, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(>, >, >, >, L0, U0, L1, U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).
min_max_factor_(>, >, >, <, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(>, >, >, >, L0, U0, L1, n(-1), L3, U3),
    min_max_factor_(>, >, <, <, L0, U0, n(1), U1, L4, U4),
    L5 cis max(L2,L3), U5 cis min(U2,U3),
    L6 cis max(L2,L4), U6 cis min(U2,U4),
    cis_compare(O0, L5, U5),
    cis_compare(O1, L6, U6),
    min_max_factor__(O0, O1, L2, U2, L3, U3, L4, U4, L5, U5, L6, U6, Min, Max).
min_max_factor_(>, <, O2, O3, L0, U0, L1, U1, L2, U2, Min, Max) :-
    min_max_factor_(>, <, O2, O3, L0, U0, L1, U1, L3, U3),
    Min cis max(L2,L3),
    Max cis min(U2,U3).

min_max_factor(L0, U0, L1, U1, L2, U2, Min, Max) :-
    cis_compare(O0, n(0), L0),
    cis_compare(O1, n(0), U0),
    cis_compare(O2, n(0), L1),
    cis_compare(O3, n(0), U1),
    min_max_factor_(O0, O1, O2, O3, L0, U0, L1, U1, L2, U2, Min, Max),
    Min cis_le Max.
% min_max_factor(L0, U0, L1, U1, L2, U2, Min, Max) :-
%     (   cis_compare(>, n(0), L1), cis_compare(<, n(0), U1),
%         \+ (L0 cis_le n(0), n(0) cis_le U0)
%     ->  min_max_factor(L0, U0, L1, n(-1), L3, U3),
%         min_max_factor(L0, U0, n(1), U1, L4, U4),
%         L5 cis max(L2,L3), U5 cis min(U2,U3),
%         L6 cis max(L2,L4), U6 cis min(U2,U4),
%         (   L5 cis_le U5, L6 cis_le U6
%         ->  Min cis min(L5,L6),
%             Max cis max(U5,U6)
%         ;   L5 cis_le U5
%         ->  Min cis L5,
%             Max cis U5
%         ;   L6 cis_le U6
%         ->  Min cis L6,
%             Max cis U6
%         ;   % portray_clause(user_error,[L0,U0,L1,U1,L2,U2,L3,U3,L4,U4]),
%             Min cis max(L2,min(L3,L4)),
%             Max cis min(U2,max(U3,U4))
%         )
%     ;   min_max_factor(L0, U0, L1, U1, L3, U3),
%         Min cis max(L2,L3),
%         Max cis min(U2,U3)
%     ).

% min_max_factor(L1, U1, L2, U2, L3, U3, Min, Max) :-
%         % use findall/3 to forget auxiliary constraints that are only
%         % needed temporarily for reasoning about domain boundaries
%         findall(Min-Max, min_max_factor_(L1, U1, L2, U2, L3, U3, Min, Max), [Min-Max]).
% 
% min_max_factor_(L1, U1, L2, U2, L3, U3, Min, Max) :-
%         (   U1 cis_lt n(0),
%             L2 cis_lt n(0), U2 cis_gt n(0),
%             L3 cis_lt n(0), U3 cis_gt n(0) ->
%             list_map(in_(L1,U1), [Z1,Z2]),
%             in_(L2, n(-1), X1), in_(n(1), U3, Y1),
%             (   X1*Y1 #= Z1 ->
%                 (   fd_get(Y1, _, Inf1, Sup1, _) -> true
%                 ;   Inf1 = n(Y1), Sup1 = n(Y1)
%                 )
%             ;   Inf1 = inf, Sup1 = n(-1)
%             ),
%             in_(n(1), U2, X2), in_(L3, n(-1), Y2),
%             (   X2*Y2 #= Z2 ->
%                 (   fd_get(Y2, _, Inf2, Sup2, _) -> true
%                 ;   Inf2 = n(Y2), Sup2 = n(Y2)
%                 )
%             ;   Inf2 = n(1), Sup2 = sup
%             ),
%             Min cis max(min(Inf1,Inf2), L3),
%             Max cis min(max(Sup1,Sup2), U3)
%         ;   L1 cis_gt n(0),
%             L2 cis_lt n(0), U2 cis_gt n(0),
%             L3 cis_lt n(0), U3 cis_gt n(0) ->
%             list_map(in_(L1,U1), [Z1,Z2]),
%             in_(L2, n(-1), X1), in_(L3, n(-1), Y1),
%             (   X1*Y1 #= Z1 ->
%                 (   fd_get(Y1, _, Inf1, Sup1, _) -> true
%                 ;   Inf1 = n(Y1), Sup1 = n(Y1)
%                 )
%             ;   Inf1 = n(1), Sup1 = sup
%             ),
%             in_(n(1), U2, X2), in_(n(1), U3, Y2),
%             (   X2*Y2 #= Z2 ->
%                 (   fd_get(Y2, _, Inf2, Sup2, _) -> true
%                 ;   Inf2 = n(Y2), Sup2 = n(Y2)
%                 )
%             ;   Inf2 = inf, Sup2 = n(-1)
%             ),
%             Min cis max(min(Inf1,Inf2), L3),
%             Max cis min(max(Sup1,Sup2), U3)
%         ;   min_factor(L1, U1, L2, U2, Min0),
%             Min cis max(L3,Min0),
%             max_factor(L1, U1, L2, U2, Max0),
%             Max cis min(U3,Max0)
%         ).
% 
% min_factor(L1, U1, L2, U2, Min) :-
%         (   L1 cis_ge n(0), L2 cis_gt n(0), finite(U2) ->
%             Min cis div(L1+U2-n(1),U2)
%         ;   L1 cis_gt n(0), U2 cis_lt n(0) -> Min cis div(U1,U2)
%         ;   L1 cis_gt n(0), L2 cis_ge n(0) -> Min = n(1)
%         ;   L1 cis_gt n(0) -> Min cis -U1
%         ;   U1 cis_lt n(0), U2 cis_le n(0) ->
%             (   finite(L2) -> Min cis div(U1+L2+n(1),L2)
%             ;   Min = n(1)
%             )
%         ;   U1 cis_lt n(0), L2 cis_ge n(0) -> Min cis div(L1,L2)
%         ;   U1 cis_lt n(0) -> Min = L1
%         ;   L2 cis_le n(0), U2 cis_ge n(0) -> Min = inf
%         ;   Min cis min(min(div(L1,L2),div(L1,U2)),min(div(U1,L2),div(U1,U2)))
%         ).
% max_factor(L1, U1, L2, U2, Max) :-
%         (   L1 cis_ge n(0), L2 cis_ge n(0) -> Max cis div(U1,L2)
%         ;   L1 cis_gt n(0), U2 cis_le n(0) ->
%             (   finite(L2) -> Max cis div(L1-L2-n(1),L2)
%             ;   Max = n(-1)
%             )
%         ;   L1 cis_gt n(0) -> Max = U1
%         ;   U1 cis_lt n(0), U2 cis_lt n(0) -> Max cis div(L1,U2)
%         ;   U1 cis_lt n(0), L2 cis_ge n(0) ->
%             (   finite(U2) -> Max cis div(U1-U2+n(1),U2)
%             ;   Max = n(-1)
%             )
%         ;   U1 cis_lt n(0) -> Max cis -L1
%         ;   L2 cis_le n(0), U2 cis_ge n(0) -> Max = sup
%         ;   Max cis max(max(div(L1,L2),div(L1,U2)),max(div(U1,L2),div(U1,U2)))
%         ).
