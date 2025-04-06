linsum(T, S0, S) -->
    (   { var(T) }
    ->  { non_monotonic(T), S = S0 },
        [vn(T,1)]
    ;   linsum_(T, S0, S)
    ).

linsum_(I, S0, S)   --> { integer(I), S is S0 + I }.
linsum_(?(X), S, S) --> { must_be_fd_integer(X) }, [vn(X,1)].
linsum_(#X, S, S)   --> { must_be_fd_integer(X) }, [vn(X,1)].
linsum_(-A, S0, S)  --> mulsum(A, -1, S0, S).
linsum_(N*A, S0, S) --> { integer(N) }, !, mulsum(A, N, S0, S).
linsum_(A*N, S0, S) --> { integer(N) }, !, mulsum(A, N, S0, S).
linsum_(A+B, S0, S) --> linsum(A, S0, S1), linsum(B, S1, S).
linsum_(A-B, S0, S) --> linsum(A, S0, S1), mulsum(B, -1, S1, S).

mulsum(A, M, S0, S) -->
        { phrase(linsum(A, 0, CA), As), S is S0 + M*CA },
        lin_mul(As, M).

lin_mul([], _)             --> [].
lin_mul([vn(X,N0)|VNs], M) --> { N is N0*M }, [vn(X,N)], lin_mul(VNs, M).

v_or_i(T) :-
    (   var(T)
    ->  non_monotonic(T)
    ;   integer(T)
    ).

must_be_fd_integer(X) :-
        (   var(X) -> constrain_to_integer(X)
        ;   must_be(integer, X)
        ).

samsort(Ls0, Ls) :-
        maplist(as_key, Ls0, LKs0),
        keysort(LKs0, LKs),
        maplist(as_key, Ls, LKs).

as_key(E, E-t).

left_right_linsum_const(Left, Right, Cs, Vs, Const) :-
        phrase(linsum(Left, 0, CL), Lefts0, Rights),
        phrase(linsum(Right, 0, CR), Rights0),
        maplist(linterm_negate, Rights0, Rights),
        samsort(Lefts0, Lefts),
        Lefts = [vn(First,N)|LeftsRest],
        vns_coeffs_variables(LeftsRest, N, First, Cs0, Vs0),
        filter_linsum(Cs0, Vs0, Cs, Vs),
        Const is CR - CL.
        %format("linear sum: ~w ~w ~w\n", [Cs,Vs,Const]).

linterm_negate(vn(V,N0), vn(V,N)) :- N is -N0.

vns_coeffs_variables([], N, V, [N], [V]).
vns_coeffs_variables([vn(V,N)|VNs], N0, V0, Ns, Vs) :-
        (   V == V0 ->
            N1 is N0 + N,
            vns_coeffs_variables(VNs, N1, V0, Ns, Vs)
        ;   Ns = [N0|NRest],
            Vs = [V0|VRest],
            vns_coeffs_variables(VNs, N, V, NRest, VRest)
        ).

filter_linsum([], [], [], []).
filter_linsum([C0|Cs0], [V0|Vs0], Cs, Vs) :-
        (   C0 =:= 0 ->
            constrain_to_integer(V0),
            filter_linsum(Cs0, Vs0, Cs, Vs)
        ;   Cs = [C0|Cs1], Vs = [V0|Vs1],
            filter_linsum(Cs0, Vs0, Cs1, Vs1)
        ).

gcd([], G, G).
gcd([N|Ns], G0, G) :-
        G1 is gcd(N, G0),
        gcd(Ns, G1, G).
