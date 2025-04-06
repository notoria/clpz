/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Unification hook and constraint projection
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

verify_attributes(Var, Other, Gs) :-
        % portray_clause(Var = Other),
        (   get_atts(Var, +clpz(CLPZ)) ->
            CLPZ = clpz_attr(_,_,_,Dom,Ps,Q),
            (   nonvar(Other) ->
                (   integer(Other) -> true
                ;   type_error(integer, Other)
                ),
                domain_contains(Dom, Other),
                phrase(trigger_props(Ps), [Q], [_]),
                Gs = [phrase(do_queue, [Q], _)]
            ;   (   get_atts(Other, +clpz(clpz_attr(_,_,_,OD,OPs,_))) ->
                    domains_intersection(OD, Dom, Dom1),
                    append_propagators(Ps, OPs, Ps1),
                    new_queue(Q0),
                    variables_same_queue([Var,Other]),
                    phrase((fd_put(Other,Dom1,Ps1),
                            trigger_props(Ps1)), [Q0], _),
                    Gs = [phrase(do_queue, [Q0], _)]
                ;   put_atts(Other, +clpz(CLPZ)),
                    Gs = []
                )
            )
        ;   Gs = []
        ).

append_propagators(fd_props(Gs0,Bs0,Os0), fd_props(Gs1,Bs1,Os1), fd_props(Gs,Bs,Os)) :-
        maplist(append, [Gs0,Bs0,Os0], [Gs1,Bs1,Os1], [Gs,Bs,Os]).

bound_portray(inf, inf).
bound_portray(sup, sup).
bound_portray(n(N), N).

list_to_drep(List, Drep) :-
        list_to_domain(List, Dom),
        domain_to_drep(Dom, Drep).

domain_to_drep(Dom, Drep) :-
        domain_intervals(Dom, [A0-B0|Rest]),
        bound_portray(A0, A),
        bound_portray(B0, B),
        (   A == B -> Drep0 = A
        ;   Drep0 = A..B
        ),
        intervals_to_drep(Rest, Drep0, Drep).

intervals_to_drep([], Drep, Drep).
intervals_to_drep([A0-B0|Rest], Drep0, Drep) :-
        bound_portray(A0, A),
        bound_portray(B0, B),
        (   A == B -> D1 = A
        ;   D1 = A..B
        ),
        intervals_to_drep(Rest, Drep0 \/ D1, Drep).

attribute_goals(X) -->
        % { get_attr(X, clpz, Attr), format("A: ~w\n", [Attr]) },
        { get_attr(X, clpz, clpz_attr(_,_,_,Dom,fd_props(Gs,Bs,Os),_)),
          append(Gs, Bs, Ps0),
          append(Ps0, Os, Ps),
          domain_to_drep(Dom, Drep) },
        (   { default_domain(Dom), \+ all_dead_(Ps) } -> []
        ;   [clpz:(X in Drep)]
        ),
        attributes_goals(Ps),
        { del_attr(X, clpz) }.

attributes_goals([]) --> [].
attributes_goals([propagator(P, State)|As]) -->
        (   { ground(State) } -> []
        ;   { phrase(attribute_goal_(P), Gs) } ->
            { del_attr(State, clpz_aux), State = processed,
              (   monotonic ->
                  maplist(unwrap_with(bare_integer), Gs, Gs1)
              ;   maplist(unwrap_with(=), Gs, Gs1)
              ),
              maplist(with_clpz, Gs1, Gs2) },
            seq(Gs2)
        ;   [P] % possibly user-defined constraint
        ),
        attributes_goals(As).

with_clpz(G, clpz:G).

unwrap_with(G_2, T0, T) :-
    (   T0 = T, var(T)
    ->  true
    ;   T0 = #V0
    ->  call(G_2, V0, T)
    ;   T0 =.. [N|As0],
        maplist(unwrap_with(G_2), As0, As),
        T =.. [N|As]
    ).

bare_integer(V0, V)    :- ( integer(V0) -> V = V0 ; V = #V0 ).

attribute_goal_(presidual(Goal))       --> [Goal].
attribute_goal_(pgeq(A,B))             --> [#A #>= #B].
attribute_goal_(pplus(X,Y,Z))          --> [#X + #Y #= #Z].
attribute_goal_(pneq(A,B))             --> [#A #\= #B].
attribute_goal_(ptimes(X,Y,Z))         --> [#X * #Y #= #Z].
attribute_goal_(absdiff_neq(X,Y,C))    --> [abs(#X - #Y) #\= C].
attribute_goal_(x_eq_abs_plus_v(X,V))  --> [#X #= abs(#X) + #V].
attribute_goal_(x_neq_y_plus_z(X,Y,Z)) --> [#X #\= #Y + #Z].
attribute_goal_(x_leq_y_plus_c(X,Y,C)) --> [#X #=< #Y + C].
attribute_goal_(ptzdiv(X,Y,Z))         --> [#X // #Y #= #Z].
attribute_goal_(pexp(X,Y,Z))           --> [#X ^ #Y #= #Z].
attribute_goal_(psign(X,Y))            --> [#Y #= sign(#X)].
attribute_goal_(pabs(X,Y))             --> [#Y #= abs(#X)].
attribute_goal_(pmod(X,M,K))           --> [#X mod #M #= #K].
attribute_goal_(prem(X,Y,Z))           --> [#X rem #Y #= #Z].
attribute_goal_(pmax(X,Y,Z))           --> [#Z #= max(#X,#Y)].
attribute_goal_(pmin(X,Y,Z))           --> [#Z #= min(#X,#Y)].
attribute_goal_(pxor(X,Y,Z))           --> [#Z #= xor(#X, #Y)].
attribute_goal_(scalar_product_neq(Cs,Vs,C)) -->
        [Left #\= Right],
        { scalar_product_left_right([-1|Cs], [C|Vs], Left, Right) }.
attribute_goal_(scalar_product_eq(Cs,Vs,C)) -->
        [Left #= Right],
        { scalar_product_left_right([-1|Cs], [C|Vs], Left, Right) }.
attribute_goal_(scalar_product_leq(Cs,Vs,C)) -->
        [Left #=< Right],
        { scalar_product_left_right([-1|Cs], [C|Vs], Left, Right) }.
attribute_goal_(pdifferent(_,_,_,O))    --> original_goal(O).
attribute_goal_(weak_distinct(_,_,_,O)) --> original_goal(O).
attribute_goal_(pdistinct(Vs))          --> [all_distinct(Vs)].
attribute_goal_(pnvalue(N, Vs))         --> [nvalue(N, Vs)].
attribute_goal_(pexclude(_,_,_))  --> [].
attribute_goal_(pelement(N,Is,V)) --> [element(N, Is, V)].
attribute_goal_(pgcc(Vs, Pairs, _))   --> [global_cardinality(Vs, Pairs)].
attribute_goal_(pgcc_single(_,_))     --> [].
attribute_goal_(pgcc_check_single(_)) --> [].
attribute_goal_(pgcc_check(Pairs))    -->
        { pairs_values(Pairs, Nums),
          maplist(gcc_done, Nums) }.
attribute_goal_(pcircuit(Vs))       --> [circuit(Vs)].
attribute_goal_(pserialized(_,_,_,_,O)) --> original_goal(O).
attribute_goal_(rel_tuple(R, Tuple)) -->
        { get_attr(R, clpz_relation, Rel) },
        [tuples_in([Tuple], Rel)].
attribute_goal_(pzcompare(O,A,B)) --> [zcompare(O,A,B)].
% reified constraints
attribute_goal_(reified_in(V, D, B)) -->
        [V in Drep #<==> #B],
        { domain_to_drep(D, Drep) }.
attribute_goal_(reified_tuple_in(Tuple, R, B)) -->
        { get_attr(R, clpz_relation, Rel) },
        [tuples_in([Tuple], Rel) #<==> #B].
attribute_goal_(kill_reified_tuples(_,_,_)) --> [].
attribute_goal_(tuples_not_in(_,_,_)) --> [].
attribute_goal_(reified_fd(V,B)) --> [finite_domain(V) #<==> #B].
attribute_goal_(pskeleton(X,Y,D,_,Z,F)) -->
        { Prop =.. [F,X,Y,Z],
          phrase(attribute_goal_(Prop), Goals), list_goal(Goals, Goal) },
        [#D #= 1 #==> Goal, #Y #\= 0 #==> #D #= 1].
attribute_goal_(reified_neq(DX,X,DY,Y,_,B)) -->
        conjunction(DX, DY, #X #\= #Y, B).
attribute_goal_(reified_eq(DX,X,DY,Y,_,B))  -->
        conjunction(DX, DY, #X #= #Y, B).
attribute_goal_(reified_geq(DX,X,DY,Y,_,B)) -->
        conjunction(DX, DY, #X #>= #Y, B).
attribute_goal_(reified_and(X,_,Y,_,B))    --> [#X #/\ #Y #<==> #B].
attribute_goal_(reified_or(X, _, Y, _, B)) --> [#X #\/ #Y #<==> #B].
attribute_goal_(reified_not(X, Y))         --> [#\ #X #<==> #Y].
attribute_goal_(preified_slash(X, Y, _, R)) --> [#X/ #Y #= R].
attribute_goal_(preified_exp(X, Y, _, R))  --> [#X^ #Y #= R].
attribute_goal_(pimpl(X, Y, _))            --> [#X #==> #Y].
attribute_goal_(pfunction(Op, A, B, R)) -->
        { Expr =.. [Op,#A,#B] },
        [#R #= Expr].
attribute_goal_(pfunction(Op, A, R)) -->
        { Expr =.. [Op,#A] },
        [#R #= Expr].

conjunction(A, B, G, D) -->
        (   { A == 1, B == 1 } -> [G #<==> #D]
        ;   { A == 1 } -> [(#B #/\ G) #<==> #D]
        ;   { B == 1 } -> [(#A #/\ G) #<==> #D]
        ;   [(#A #/\ #B #/\ G) #<==> #D]
        ).

original_goal(original_goal(State, Goal)) -->
        (   { var(State) } ->
            { State = processed },
            [Goal]
        ;   []
        ).
