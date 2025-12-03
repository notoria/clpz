%% sum(+Vars, +Rel, ?Expr)
%
% The sum of elements of the list Vars is in relation Rel to Expr.
% Rel is one of #=, #\=, #<, #>, #=< or #>=. For example:
%
% ```
% ?- [A,B,C] ins 0..sup, sum([A,B,C], #=, 100).
% A in 0..100,
% A+B+C#=100,
% B in 0..100,
% C in 0..100.
% ```

sum(Vs, Op, Value) :-
        must_be(list, Vs),
        list_equisized(Vs, Ones),
        list_map(=(1), Ones),
        scalar_product(Ones, Vs, Op, Value).

%% scalar_product(+Cs, +Vs, +Rel, ?Expr)
%
% True iff the scalar product of Cs and Vs is in relation Rel to Expr.
% Cs is a list of integers, Vs is a list of variables and integers.
% Rel is #=, #\=, #<, #>, #=< or #>=.

foldl(_G_4, [], [], S, S).
foldl(G_4, [E0|Es0], [E1|Es1], S0, S) :-
    call(G_4, E0, E1, S0, S1),
    foldl(G_4, Es0, Es1, S1, S).

scalar_product(Cs, Vs, Op, Value) :-
        must_be(list(integer), Cs),
        must_be(list, Vs),
        list_map(fd_variable, Vs),
        (   Op = (#=), single_value(Value, Right), ground(Vs) ->
            list_foldl(coeff_int_linsum, Cs, Vs, 0, Right)
        ;   must_be(ground, Op),
            (   member(Op, [#=,#\=,#<,#>,#=<,#>=]) -> true
            ;   domain_error(scalar_product_relation, Op)
            ),
            must_be(acyclic, Value),
            foldl(coeff_var_plusterm, Cs, Vs, 0, Left),
            (   left_right_linsum_const(Left, Value, Cs1, Vs1, Const) ->
                '@scalar_product'(Op, Cs1, Vs1, Const)
            ;   sum(Cs, Vs, 0, Op, Value)
            )
        ).

single_value(V, T)    :- var(V), !, non_monotonic(V), T = V.
single_value(I, T)    :- integer(I), T = I.
single_value(?(V), T) :- fd_variable(V), T = V.

coeff_var_plusterm(C, V, T0, T0+(C* #V)).

coeff_int_linsum(C, I, S0, S) :-
    list_foldl(call, [integer_mul(C),integer_add(S0)], I, S).

sum([], _, Sum, Op, Value) :-
    call(Op, #Sum, #Value).
sum([C|Cs], [X|Xs], Acc, Op, Value) :-
        #NAcc #= #Acc + #C* #X,
        sum(Cs, Xs, NAcc, Op, Value).

multiples([], [], _).
multiples([C|Cs], [V|Vs], Left) :-
        (   (   Cs = [N|_] ; Left = [N|_] ) ->
            (   N =\= 1, integer_gcd(C, N, 1) ->
                list_foldl(integer_gcd, Cs, N, GCD0),
                list_foldl(integer_gcd, Left, GCD0, GCD),
                % gcd(Cs, N, GCD0),
                % gcd(Left, GCD0, GCD),
                (   GCD > 1 -> #V #= GCD * #_
                ;   true
                )
            ;   true
            )
        ;   true
        ),
        multiples(Cs, Vs, [C|Left]).

divide(D, N, Q) :-
    integer_mul(Q, D, N).

'@scalar_product'(#=, Cs0, Vs, S0) :-
    (   Cs0 = [C|Rest] ->
        list_foldl(integer_gcd, Rest, C, GCD),
        % gcd(Rest, C, GCD),
        S0 mod GCD =:= 0,
        list_map(divide(GCD), [S0|Cs0], [S|Cs])
    ;   S0 =:= 0, S = S0, Cs = Cs0
    ),
    (   S0 =:= 0 ->
        list_map(integer_abs, Cs, As),
        multiples(As, Vs, [])
    ;   true
    ),
    propagator_from_constraint(scalar_product_eq(Cs,Vs,S), P),
    propagator_trigger(P, Vs).
'@scalar_product'(#\=, Cs, Vs, C) :-
    propagator_from_constraint(scalar_product_neq(Cs,Vs,C), P),
    propagator_trigger(P, Vs).
'@scalar_product'(#=<, Cs, Vs, C) :-
    propagator_from_constraint(scalar_product_leq(Cs,Vs,C), P),
    propagator_trigger(P, Vs).
'@scalar_product'(#<, Cs, Vs, C0) :-
    integer_add(-1, C0, C),
    '@scalar_product'(#=<, Cs, Vs, C).
'@scalar_product'(#>, Cs, Vs, C0) :-
    integer_add(1, C0, C),
    '@scalar_product'(#>=, Cs, Vs, C).
'@scalar_product'(#>=, Cs, Vs, C0) :-
    list_map(integer_neg, Cs, Cs1),
    integer_add(C, C0, 0),
    '@scalar_product'(#=<, Cs1, Vs, C).

coeffs_variables_const([], [], [], [], I, I).
coeffs_variables_const([C|Cs], [V|Vs], Cs1, Vs1, I0, I) :-
        (   var(V) ->
            Cs1 = [C|CRest], Vs1 = [V|VRest], I1 = I0
        ;   list_foldl(call, [integer_mul(C),integer_add(I0)], V, I1), % I1 #= I0+C*V
            Cs1 = CRest, Vs1 = VRest
        ),
        coeffs_variables_const(Cs, Vs, CRest, VRest, I1, I).

sum_finite_domains([], [], Inf, Sup, Inf, Sup) ++> [].
sum_finite_domains([C|Cs], [V|Vs], Inf0, Sup0, Inf, Sup) ++>
        { fd_get(V, _, Inf1, Sup1, _) },
        (   Inf1 = n(NInf) ->
            (   C < 0 ->
                { list_foldl(call, [integer_mul(C),integer_add(Sup0)], NInf, Sup2) } % Sup2 #= Sup0+C*NInf
            ;   { list_foldl(call, [integer_mul(C),integer_add(Inf0)], NInf, Inf2) } % Inf2 #= Inf0+C*NInf
            )
        ;   (   C < 0 ->
                Sup2 = Sup0,
                []+[C*V]
            ;   Inf2 = Inf0,
                [C*V]+[]
            )
        ),
        (   Sup1 = n(NSup) ->
            (   C < 0 ->
                { list_foldl(call, [integer_mul(C),integer_add(Inf0)], NSup, Inf2) } % Inf2 #= Inf0+C*NSup
            ;   { list_foldl(call, [integer_mul(C),integer_add(Sup0)], NSup, Sup2) } % Sup2 #= Sup0+C*NSup
            )
        ;   (   C < 0 ->
                Inf2 = Inf0,
                [C*V]+[]
            ;   Sup2 = Sup0,
                []+[C*V]
            )
        ),
        sum_finite_domains(Cs, Vs, Inf2, Sup2, Inf, Sup).

remove_dist_upper_lower([], _, _, _) --> [].
remove_dist_upper_lower([C|Cs], [V|Vs], D1, D2) -->
        (   { fd_get(V, VD, VPs) } ->
            (   C < 0 ->
                { domain_supremum(VD, n(Sup)),
                  L is Sup + D1//C,
                  domain_remove_less_than(L, VD, VD1),
                  domain_infimum(VD1, n(Inf)),
                  G is Inf - D2//C,
                  domain_remove_greater_than(G, VD1, VD2) }
            ;   { domain_infimum(VD, n(Inf)),
                  G is Inf + D1//C,
                  domain_remove_greater_than(G, VD, VD1),
                  domain_supremum(VD1, n(Sup)),
                  L is Sup - D2//C,
                  domain_remove_less_than(L, VD1, VD2) }
            ),
            fd_put(V, VD2, VPs)
        ;   true
        ),
        remove_dist_upper_lower(Cs, Vs, D1, D2).


remove_dist_upper_leq([], _, _) --> [].
remove_dist_upper_leq([C|Cs], [V|Vs], D1) -->
        (   { fd_get(V, VD, VPs) } ->
            (   C < 0 ->
                { domain_supremum(VD, n(Sup)),
                  L is Sup + D1//C,
                  domain_remove_less_than(L, VD, VD1) }
            ;   { domain_infimum(VD, n(Inf)),
                  G is Inf + D1//C,
                  domain_remove_greater_than(G, VD, VD1) }
            ),
            fd_put(V, VD1, VPs)
        ;   true
        ),
        remove_dist_upper_leq(Cs, Vs, D1).


remove_dist_upper([], _) --> [].
remove_dist_upper([C*V|CVs], D) -->
        (   { fd_get(V, VD, VPs) } ->
            (   C < 0 ->
                (   { domain_supremum(VD, n(Sup)) } ->
                    { L is Sup + D//C,
                      domain_remove_less_than(L, VD, VD1) }
                ;   VD1 = VD
                )
            ;   (   { domain_infimum(VD, n(Inf)) } ->
                    { G is Inf + D//C,
                      domain_remove_greater_than(G, VD, VD1) }
                ;   VD1 = VD
                )
            ),
            fd_put(V, VD1, VPs)
        ;   true
        ),
        remove_dist_upper(CVs, D).

remove_dist_lower([], _) --> [].
remove_dist_lower([C*V|CVs], D) -->
        (   { fd_get(V, VD, VPs) } ->
            (   C < 0 ->
                (   { domain_infimum(VD, n(Inf)) } ->
                    { G is Inf - D//C,
                      domain_remove_greater_than(G, VD, VD1) }
                ;   VD1 = VD
                )
            ;   (   { domain_supremum(VD, n(Sup)) } ->
                    { L is Sup - D//C,
                      domain_remove_less_than(L, VD, VD1) }
                ;   VD1 = VD
                )
            ),
            fd_put(V, VD1, VPs)
        ;   true
        ),
        remove_dist_lower(CVs, D).

remove_upper([], _) --> [].
remove_upper([C*X|CXs], Max) -->
        (   { fd_get(X, XD, XPs) } ->
            D is Max//C,
            (   C < 0 ->
                { domain_remove_less_than(D, XD, XD1) }
            ;   { domain_remove_greater_than(D, XD, XD1) }
            ),
            fd_put(X, XD1, XPs)
        ;   true
        ),
        remove_upper(CXs, Max).

remove_lower([], _) --> [].
remove_lower([C*X|CXs], Min) -->
        (   { fd_get(X, XD, XPs) } ->
            D is -Min//C,
            (   C < 0 ->
                { domain_remove_greater_than(D, XD, XD1) }
            ;   { domain_remove_less_than(D, XD, XD1) }
            ),
            fd_put(X, XD1, XPs)
        ;   true
        ),
        remove_lower(CXs, Min).
