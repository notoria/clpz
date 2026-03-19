%propagate(P, _) --> { portray_clause(propagate(P)), false }.
% trivial propagator, used only to remember pending constraints
propagate(presidual(_), _) --> [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X =< Y
propagate(pleq(X,Y), MState) -->
    propagate_leq(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X \= Y
propagate(pneq(X,Y), MState) -->
    propagate_neq(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X + Y = Z
propagate(iadd(X,Y,Z), MState) -->
    propagate_iadd(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X * Y = Z
propagate(imul(X,Y,Z), MState) -->
    propagate_imul(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = X ^ Y
propagate(iexp(X,Y,Z), MState) -->
    propagate_iexp(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = min(X,Y)
propagate(imin(X,Y,Z), MState) -->
    propagate_imin(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = max(X,Y)
propagate(imax(X,Y,Z), MState) -->
    propagate_imax(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = X mod Y
propagate(imod(X,Y,Z), MState) -->
    propagate_imod(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = X rem Y
propagate(irem(X,Y,Z), MState) -->
    propagate_irem(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Y = abs(X)
propagate(iabs(X,Y), MState) -->
    propagate_iabs(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Y = sign(X)
propagate(isgn(X,Y), MState) -->
    propagate_isgn(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = X << Y
propagate(ishl(X,Y,Z), MState) -->
    propagate_ishl(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = X >> Y
propagate(ishr(X,Y,Z), MState) -->
    propagate_ishr(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = X /\ Y
propagate(iand(X,Y,Z), MState) -->
    propagate_iand(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = X \/ Y
propagate(iior(X,Y,Z), MState) -->
    propagate_iior(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Z = X xor Y
propagate(ixor(X,Y,Z), MState) -->
    propagate_ixor(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Y = lsb(X)
propagate(ilsb(X,Y), MState) -->
    propagate_ilsb(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Y = msb(X)
propagate(imsb(X,Y), MState) -->
    propagate_imsb(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Y = popcount(X)
propagate(ict1(X,Y), MState) -->
    propagate_ict1(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% V in D <==> B
propagate(bin(D,V,B), MState) -->
    propagate_bin(MState, D, V, B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% B0 /\ B1 <==> B
propagate(band(B0,Ps0,B1,Ps1,B), MState) -->
    propagate_band(MState, B0, Ps0, B1, Ps1, B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% B0 \/ B1 <==> B
propagate(bior(B0,Ps0,B1,Ps1,B), MState) -->
    propagate_bior(MState, B0, Ps0, B1, Ps1, B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% \ B0 <==> B
propagate(bnot(B0,B), MState) -->
    propagate_bnot(MState, B0, B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% (B0 <==> B1) <==> B2
propagate(beqv(B0,B1,B2), MState) -->
    propagate_beqv(MState, B0, B1, B2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X = Y <==> B
propagate(beq(B,X,Y), MState) -->
    propagate_beq(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X \= Y <==> B
propagate(bne(B,X,Y), MState) -->
    propagate_bne(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X =< Y <==> B
propagate(ble(B,X,Y), MState) -->
    propagate_ble(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X < Y <==> B
propagate(blt(B,X,Y), MState) -->
    propagate_blt(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X + Y = Z <==> B
propagate(add(B,X,Y,Z), MState) -->
    propagate_iadd(MState, B, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X ^ Y = Z <==> B
propagate(bexp(B,X,Y,Z), MState) -->
    propagate_bexp(MState, B, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X mod Y = Z <==> B
propagate(bmod(B,X,Y,Z), MState) -->
    propagate_bmod(MState, B, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% lsb(X) = Y <==> B
propagate(blsb(B,X,Y), MState) -->
    propagate_blsb(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% msb(X) = Y <==> B
propagate(bmsb(B,X,Y), MState) -->
    propagate_bmsb(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% popcount(X) = Y <==> B
propagate(bct1(B,X,Y), MState) -->
    propagate_bct1(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% B => call(G)
propagate(bdly(B,G), MState) -->
    propagate_bdly(MState, B, G).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(pdifferent(Left,Right,X,_), MState) -->
        propagate(pexclude(Left,Right,X), MState).

propagate(pexclude(Left,Right,X), _) -->
        (   ground(X) ->
            queue_disable,
            exclude_fire(Left, Right, X),
            queue_enable
        ;   true
        ).

propagate(pdistinct(Ls), _MState) --> distinct(Ls).

% propagate(pnvalue(N, Vars), _MState) --> { propagate_nvalue(N, Vars) }.

propagate(pnvalue(N, Vars0), _MState) -->
    {   sort(Vars0, Vars),
        include(nonvar, Vars, Ints),
        list_length(Ints, Distinct),
        list_foldl(num_infinite, Vars, 0, NumInfinite),
        with_local_attributes(
            Vars,
            (   difference_arcs(Vars, FreeLeft, FreeRight0),
                list_map(put_free, FreeRight0),
                phrase(maximal_matching(FreeLeft), MatchedLeft),
                list_length(MatchedLeft, MaxFurther)
            ),
            MaxFurther
        )
    },
    {   L = Distinct,
        list_foldl(integer_add, [NumInfinite,Distinct,MaxFurther], 0, U)
    },
    % { #L #= #Distinct, #U #= #NumInfinite + #Distinct + #MaxFurther },
    (   { var(N) }
    ->  {   fd_get(N, ND0, NPs),
            domain_from_bounds(n(L), n(U), D),
            domain_inter(D, ND0, ND)
        },
        fd_put(N, ND, NPs)
    ;   { integer(N) }
    ->  {   integer_le(L, N),
            integer_le(N, U)
        }
    ;   { false }
    ).
    % queue_pgoal(#N #>= #Distinct),
    % queue_pgoal(#N #=< #NumInfinite + #Distinct + #MaxFurther).

propagate(check_distinct(Left,Right,X), _) -->
    { list_map(\==(X), Left), list_map(\==(X), Right) }.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(pelement(N, Is, V), MState) -->
        (   { fd_get(N, NDom, _) } ->
            (   { fd_get(V, VDom, VPs) } ->
                { domain_empty(Empty),
                  integers_remaining(Is, 1, NDom, Empty, VDom1),
                  domain_inter(VDom, VDom1, VDom2) },
                fd_put(V, VDom2, VPs)
            ;   []
            )
        ;   { kill(MState), list_nth0(N, [_|Is], V), N \= 0 }
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(pgcc_single(Vs, Pairs), _) --> gcc_global(Vs, Pairs).

propagate(pgcc_check_single(Pairs), _) --> gcc_check(Pairs).

propagate(pgcc_check(Pairs), _) --> gcc_check(Pairs).

propagate(pgcc(Vs, _, Pairs), _) --> gcc_global(Vs, Pairs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(pcircuit(Vs), _MState) -->
        distinct(Vs),
        { propagate_circuit(Vs) }.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(rel_tuple(R, Tuple), MState) -->
        { get_attr(R, clpz_relation, Relation) },
        (   { ground(Tuple) } ->
            kill(MState),
            { del_attr(R, clpz_relation),
              once(member(Tuple, Relation)) }
        ;   { relation_unifiable(Relation, Tuple, Us, false, Changed),
              Us = [_|_] },
            (   { Tuple = [First,Second], ( ground(First) ; ground(Second) ) } ->
                kill(MState),
                { del_attr(R, clpz_relation) }
            ;   []
            ),
            (   { Us = [Single] } ->
                kill(MState),
                { del_attr(R, clpz_relation) },
                Single = Tuple
            ;   { call(Changed) } ->
                { put_attr(R, clpz_relation, Us) },
                queue_disable,
                tuple_domain(Tuple, Us),
                queue_enable
            ;   []
            )
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(pserialized(S_I, D_I, S_J, D_J, _), MState) -->
        (   nonvar(S_I), nonvar(S_J) ->
            kill(MState),
            (   S_I + D_I =< S_J -> []
            ;   S_J + D_J =< S_I -> []
            ;   false
            )
        ;   serialize_lower_upper(S_I, D_I, S_J, D_J, MState),
            serialize_lower_upper(S_J, D_J, S_I, D_I, MState)
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% abs(X-Y) #\= C
propagate(absdiff_neq(X,Y,C), MState) -->
    (   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), abs(X-Y) =\= C }
    ;   []
    ).

% X #= abs(X) + V
propagate(x_eq_abs_plus_v(X,V), MState) -->
        (   nonvar(V) ->
            (   V =:= 0 -> kill(MState), { X in 0..sup }
            ;   V < 0 -> kill(MState), { #X #= #V / #2 }
            ;   false % V > 0
            )
        ;   nonvar(X) ->
            kill(MState),
            { #V #= #X - abs(#X) }
        ;   true
        ).

% X #\= Y + Z
propagate(x_neq_y_plus_z(X,Y,Z), MState) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), X =\= Y + Z }
    ;   []
    ).

% X #=< Y + C
propagate(x_leq_y_plus_c(X,Y,C), MState) -->
    (   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), X =< Y + C }
    ;   []
    ).

propagate(scalar_product_neq(Cs0,Vs0,P0), MState) -->
        { coeffs_variables_const(Cs0, Vs0, Cs, Vs, 0, I),
          P is P0 - I,
          (   Vs = [] -> kill(MState), P =\= 0
          ;   Vs = [V], Cs = [C] ->
              kill(MState),
              (   C =:= 1 -> neq_num(V, P)
              ;   #C * #V #\= #P
              )
          ;   Cs == [1,-1] -> kill(MState), Vs = [A,B], x_neq_y_plus_z(A, B, P)
          ;   Cs == [-1,1] -> kill(MState), Vs = [A,B], x_neq_y_plus_z(B, A, P)
          ;   P =:= 0, Cs = [1,1,-1] ->
              kill(MState), Vs = [A,B,C], x_neq_y_plus_z(C, A, B)
          ;   P =:= 0, Cs = [1,-1,1] ->
              kill(MState), Vs = [A,B,C], x_neq_y_plus_z(B, A, C)
          ;   P =:= 0, Cs = [-1,1,1] ->
              kill(MState), Vs = [A,B,C], x_neq_y_plus_z(A, B, C)
          ;   true
          ) }.

propagate(scalar_product_leq(Cs0,Vs0,P0), MState) -->
        { coeffs_variables_const(Cs0, Vs0, Cs, Vs, 0, I) },
        P is P0 - I,
        (   Vs = [] -> kill(MState), P >= 0
        ;   { duophrase(sum_finite_domains(Cs, Vs, 0, 0, Inf, Sup), Infs, Sups) },
            D1 is P - Inf,
            queue_disable,
            (   Infs == [], Sups == [] ->
                Inf =< P,
                (   Sup =< P -> kill(MState)
                ;   remove_dist_upper_leq(Cs, Vs, D1)
                )
            ;   Infs == [] -> Inf =< P, remove_dist_upper(Sups, D1)
            ;   Infs = [_] -> remove_upper(Infs, D1)
            ;   true
            ),
            queue_enable
        ).

propagate(scalar_product_eq(Cs0,Vs0,P0), MState) -->
        { coeffs_variables_const(Cs0, Vs0, Cs, Vs, 0, I) },
        P is P0 - I,
        (   Vs = [] -> kill(MState), P =:= 0
        ;   Vs = [V], Cs = [C] -> kill(MState), P mod C =:= 0, V is P // C
        ;   Cs == [1,1] -> kill(MState), Vs = [A,B], { #A + #B #= #P }
        ;   Cs == [1,-1] -> kill(MState), Vs = [A,B], { #A #= #P + #B }
        ;   Cs == [-1,1] -> kill(MState), Vs = [A,B], { #B #= #P + #A }
        ;   Cs == [-1,-1] -> kill(MState), Vs = [A,B], P1 is -P, { #A + #B #= #P1 }
        ;   P =:= 0, Cs == [1,1,-1] -> kill(MState), Vs = [A,B,C], { #A + #B #= #C }
        ;   P =:= 0, Cs == [1,-1,1] -> kill(MState), Vs = [A,B,C], { #A + #C #= #B }
        ;   P =:= 0, Cs == [-1,1,1] -> kill(MState), Vs = [A,B,C], { #B + #C #= #A }
        ;   { duophrase(sum_finite_domains(Cs, Vs, 0, 0, Inf, Sup), Infs, Sups) },
            % { nl, writeln(Infs-Sups-Inf-Sup) },
            D1 is P - Inf,
            D2 is Sup - P,
            queue_disable,
            (   Infs == [], Sups == [] ->
                { integer_between(Inf, Sup, P) },
                remove_dist_upper_lower(Cs, Vs, D1, D2)
            ;   Sups = [] -> P =< Sup, remove_dist_lower(Infs, D2)
            ;   Infs = [] -> Inf =< P, remove_dist_upper(Sups, D1)
            ;   Sups = [_], Infs = [_] ->
                remove_lower(Sups, D2),
                remove_upper(Infs, D1)
            ;   Infs = [_] -> remove_upper(Infs, D1)
            ;   Sups = [_] -> remove_lower(Sups, D2)
            ;   true
            ),
            queue_enable
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X // Y = Z (round towards zero)
propagate(ptzdiv(X,Y,Z), MState) -->
        (   nonvar(X) ->
            (   nonvar(Y) -> kill(MState), Y =\= 0, Z is X // Y
            ;   { fd_get(Y, YD, YL, YU, YPs) },
                (   nonvar(Z) ->
                    (   Z =:= 0 ->
                        NYL is -abs(X) - 1,
                        NYU is abs(X) + 1,
                        { domain_from_bounds(inf, n(NYL), __D0),
                          domain_from_bounds(n(NYU), sup, __D1),
                          domain_union(__D0, __D1, __D2)
                        },
                        { domain_inter(
                            YD,
                            % split(0,from_to(inf,n(NYL)),from_to(n(NYU),sup)),
                            __D2,
                            NYD
                          ) },
                        fd_put(Y, NYD, YPs)
                    ;   (   sign(X) =:= sign(Z) ->
                            { NYL cis max(n(X) // (n(Z)+sign(n(Z))) + n(1), YL),
                              NYU cis min(n(X) // n(Z), YU) }
                        ;   { NYL cis max(n(X) // n(Z), YL),
                              NYU cis min(n(X) // (n(Z)+sign(n(Z))) - n(1), YU) }
                        ),
                        update_bounds(Y, YD, YPs, YL, YU, NYL, NYU)
                    )
                ;   { fd_get(Z, ZD, ZL, ZU, ZPs),
                      (   X >= 0, ( YL cis_gt n(0) ; YU cis_lt n(0) )->
                          NZL cis max(n(X)//YU, ZL),
                          NZU cis min(n(X)//YL, ZU)
                      ;   X < 0, ( YL cis_gt n(0) ; YU cis_lt n(0) ) ->
                          NZL cis max(n(X)//YL, ZL),
                          NZU cis min(n(X)//YU, ZU)
                      ;   % TODO: more stringent bounds, cover Y
                          NZL cis max(-abs(n(X)), ZL),
                          NZU cis min(abs(n(X)), ZU)
                      ) },
                    update_bounds(Z, ZD, ZPs, ZL, ZU, NZL, NZU),
                    (   { X >= 0, NZL cis_gt n(0), fd_get(Y, YD1, YPs1) } ->
                        { NYL cis n(X) // (NZU + n(1)) + n(1),
                          NYU cis n(X) // NZL,
                          domain_from_bounds(NYL, NYU, _D3),
                          domain_inter(YD1, _D3, NYD1) },
                        fd_put(Y, NYD1, YPs1)
                    ;   true
                    )
                )
            )
        ;   nonvar(Y) ->
            Y =\= 0,
            (   Y =:= 1 -> kill(MState), X = Z
            ;   Y =:= -1 -> kill(MState), { #Z #= - #X }
            ;   { fd_get(X, XD, XL, XU, XPs) },
                (   nonvar(Z) ->
                    kill(MState),
                    (   sign(Z) =:= sign(Y) ->
                        { NXL cis max(n(Z)*n(Y), XL),
                          NXU cis min((abs(n(Z))+n(1))*abs(n(Y))-n(1), XU) }
                    ;   Z =:= 0 ->
                        { NXL cis max(-abs(n(Y)) + n(1), XL),
                          NXU cis min(abs(n(Y)) - n(1), XU) }
                    ;   { NXL cis max((n(Z)+sign(n(Z)))*n(Y)+n(1), XL),
                          NXU cis min(n(Z)*n(Y), XU) }
                    ),
                    update_bounds(X, XD, XPs, XL, XU, NXL, NXU)
                ;   { fd_get(Z, ZD, ZPs),
                      domain_contract_less(XD, Y, Contracted),
                      domain_inter(ZD, Contracted, NZD) },
                    fd_put(Z, NZD, ZPs),
                    (   { fd_get(X, XD2, XPs2) } ->
                        { domain_expand_more(NZD, Y, Expanded),
                          domain_inter(XD2, Expanded, NXD2) },
                        fd_put(X, NXD2, XPs2)
                    ;   true
                    )
                )
            )
        ;   nonvar(Z) ->
            { fd_get(X, XD, XL, XU, XPs),
              fd_get(Y, _, YL, YU, _),
              (   YL cis_ge n(0), XL cis_ge n(0) ->
                  NXL cis max(YL*n(Z), XL),
                  NXU cis min(YU*(n(Z)+n(1))-n(1), XU)
              ;   %TODO: cover more cases
                  NXL = XL, NXU = XU
              ) },
            update_bounds(X, XD, XPs, XL, XU, NXL, NXU)
        ;   (   X == Y -> kill(MState), Z = 1
            ;   { fd_get(X, _, XL, XU, _),
                  fd_get(Y, _, YL, _, _),
                  fd_get(Z, ZD, ZPs),
                  NZU cis max(abs(XL), XU),
                  NZL cis -NZU,
                  domain_from_bounds(NZL, NZU, _D4),
                  domain_inter(ZD, _D4, NZD0),
                  (   XL cis_ge n(0), YL cis_ge n(0) ->
                      domain_remove_less_than(0, NZD0, NZD1)
                  ;   % TODO: cover more cases
                      NZD1 = NZD0
                  ) },
                fd_put(Z, NZD1, ZPs)
            )
        ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(pzcompare(O,A,B), MState) -->
    (   { nonvar(O), nonvar(A), nonvar(B) }
    ->  { kill(MState), integer_compare(O, A, B) }
    ;   []
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reified constraints

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(reified_in(V,Dom,B), MState) -->
    (   { nonvar(V), nonvar(B) }
    ->  { kill(MState), if_(domain_contains(Dom,V), B = 1, B = 0) }
    ;   []
    ).

propagate(reified_tuple_in(Tuple, R, B), MState) -->
        { get_attr(R, clpz_relation, Relation) },
        (   B == 1 -> kill(MState), { tuples_in([Tuple], Relation) }
        ;   (   ground(Tuple) ->
                kill(MState),
                (   { member(Tuple, Relation) } -> B = 1
                ;   B = 0
                )
            ;   { relation_unifiable(Relation, Tuple, Us, _, _) },
                (   Us = [] -> kill(MState), B = 0
                ;   []
                )
            )
        ).

propagate(tuples_not_in(Tuples, Relation, B), MState) -->
        (   B == 0 ->
            kill(MState),
            { tuples_in_conjunction(Tuples, Relation, Conj),
              #\ Conj }
        ;   []
        ).

propagate(kill_reified_tuples(B, Ps, Bs), _) -->
        (   B == 0 ->
            { list_map(kill_entailed, Ps),
              phrase(map(a, Bs), As),
              list_map(kill_entailed, As) }
        ;   []
        ).

propagate(reified_fd(V,B), MState) -->
        (   { fd_inf(V, I), I \== inf, fd_sup(V, S), S \== sup } ->
            kill(MState),
            B = 1
        ;   { B == 0 } ->
            (   { fd_inf(V, inf) } -> []
            ;   { fd_sup(V, sup) }
            )
        ;   []
        ).

% The result of X/Y, X mod Y, and X rem Y is undefined iff Y is 0.

propagate(pskeleton(X,Y,D,Skel,Z,_), MState) -->
        (   Y == 0 -> kill(MState), D = 0
        ;   D == 1 ->
            kill(MState), neq_num(Y, 0), { skeleton([X,Y,Z], Skel) }
        ;   integer(Y), Y =\= 0 ->
            kill(MState), D = 1, { skeleton([X,Y,Z], Skel) }
        ;   { fd_get(Y, YD, _), \+ domain_contains(YD, 0) } ->
            kill(MState), D = 1, { skeleton([X,Y,Z], Skel) }
        ;   []
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Propagators for arithmetic functions that only propagate
   functionally. These are currently the bitwise operations.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

propagate(pfunction(Op,A,B,R), MState) -->
        (   integer(A), integer(B) ->
            kill(MState),
            Expr =.. [Op,A,B],
            R is Expr
        ;   []
        ).
propagate(pfunction(Op,A,R), MState) -->
        (   integer(A) ->
            kill(MState),
            Expr =.. [Op,A],
            R is Expr
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(reified_geq(DX,X,DY,Y,Ps,B), MState) -->
        (   DX == 0 -> kill(MState, Ps), B = 0
        ;   DY == 0 -> kill(MState, Ps), B = 0
        ;   B == 1 ->  kill(MState), DX = 1, DY = 1, { geq(X, Y) }
        ;   DX == 1, DY == 1 ->
            (   var(B) ->
                (   nonvar(X) ->
                    (   nonvar(Y) ->
                        kill(MState),
                        (   X >= Y -> B = 1 ; B = 0 )
                    ;   { fd_get(Y, _, YL, YU, _) },
                        (   { n(X) cis_ge YU } -> kill(MState, Ps), B = 1
                        ;   { n(X) cis_lt YL } -> kill(MState, Ps), B = 0
                        ;   []
                        )
                    )
                ;   nonvar(Y) ->
                    { fd_get(X, _, XL, XU, _) },
                    (   { XL cis_ge n(Y) } -> kill(MState, Ps), B = 1
                    ;   { XU cis_lt n(Y) } -> kill(MState, Ps), B = 0
                    ;   []
                    )
                ;   X == Y -> kill(MState, Ps), B = 1
                ;   { fd_get(X, _, XL, XU, _),
                      fd_get(Y, _, YL, YU, _) },
                    (   { XL cis_ge YU } -> kill(MState, Ps), B = 1
                    ;   { XU cis_lt YL } -> kill(MState, Ps), B = 0
                    ;   []
                    )
                )
            ;   B =:= 0 -> { kill(MState), #X #< #Y }
            ;   []
            )
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(reified_eq(DX,X,DY,Y,Ps,B), MState) -->
        (   DX == 0 -> kill(MState, Ps), B = 0
        ;   DY == 0 -> kill(MState, Ps), B = 0
        ;   B == 1 -> kill(MState), DX = 1, DY = 1, X = Y
        ;   DX == 1, DY == 1 ->
            (   var(B) ->
                (   nonvar(X) ->
                    (   nonvar(Y) ->
                        kill(MState),
                        (   X =:= Y -> B = 1 ; B = 0)
                    ;   { fd_get(Y, YD, _) },
                        (   { domain_contains(YD, X) } -> []
                        ;   kill(MState, Ps), B = 0
                        )
                    )
                ;   nonvar(Y) ->
                    propagate(reified_eq(DY,Y,DX,X,Ps,B), MState)
                ;   X == Y -> kill(MState), B = 1
                ;   { fd_get(X, _, XL, XU, _),
                      fd_get(Y, _, YL, YU, _) },
                    (   { XL cis_gt YU } -> kill(MState, Ps), B = 0
                    ;   { YL cis_gt XU } -> kill(MState, Ps), B = 0
                    ;   []
                    )
                )
            ;   B =:= 0 -> kill(MState), { #X #\= #Y }
            ;   []
            )
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(reified_neq(DX,X,DY,Y,Ps,B), MState) -->
        (   DX == 0 -> kill(MState, Ps), B = 0
        ;   DY == 0 -> kill(MState, Ps), B = 0
        ;   B == 1 -> { kill(MState), DX = 1, DY = 1, #X #\= #Y }
        ;   DX == 1, DY == 1 ->
            (   var(B) ->
                (   nonvar(X) ->
                    (   nonvar(Y) ->
                        kill(MState),
                        (   X =\= Y -> B = 1 ; B = 0)
                    ;   { fd_get(Y, YD, _) },
                        (   { domain_contains(YD, X) } -> []
                        ;   kill(MState, Ps), B = 1
                        )
                    )
                ;   nonvar(Y) ->
                    propagate(reified_neq(DY,Y,DX,X,Ps,B), MState)
                ;   X == Y -> kill(MState), B = 0
                ;   { fd_get(X, _, XL, XU, _),
                      fd_get(Y, _, YL, YU, _) },
                    (   { XL cis_gt YU } -> kill(MState, Ps), B = 1
                    ;   { YL cis_gt XU } -> kill(MState, Ps), B = 1
                    ;   []
                    )
                )
            ;   B =:= 0 -> kill(MState), X = Y
            ;   []
            )
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(reified_and(X,Ps1,Y,Ps2,B), MState) -->
        (   nonvar(X) ->
            kill(MState),
            (   X =:= 0 -> { list_map(kill_entailed, Ps2), B = 0 }
            ;   B = Y
            )
        ;   nonvar(Y) -> propagate(reified_and(Y,Ps2,X,Ps1,B), MState)
        ;   B == 1 -> kill(MState), X = 1, Y = 1
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(reified_or(X,Ps1,Y,Ps2,B), MState) -->
        (   nonvar(X) ->
            kill(MState),
            (   X =:= 1 -> { list_map(kill_entailed, Ps2), B = 1 }
            ;   B = Y
            )
        ;   nonvar(Y) -> propagate(reified_or(Y,Ps2,X,Ps1,B), MState)
        ;   B == 0 -> kill(MState), X = 0, Y = 0
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(reified_not(X,Y), MState) -->
        (   X == 0 -> kill(MState), Y = 1
        ;   X == 1 -> kill(MState), Y = 0
        ;   Y == 0 -> kill(MState), X = 1
        ;   Y == 1 -> kill(MState), X = 0
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(pimpl(X, Y, Ps), MState) -->
        (   nonvar(X) ->
            kill(MState),
            (   X =:= 1 -> Y = 1
            ;   { list_map(kill_entailed, Ps) }
            )
        ;   nonvar(Y) ->
            kill(MState),
            (   Y =:= 0 -> X = 0
            ;   { list_map(kill_entailed, Ps) }
            )
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(preified_slash(X, Y, D, R), MState) -->
        (   Y == 0 ->
            kill(MState),
            D = 0
        ;   Y == 1 ->
            kill(MState),
            D = 1,
            R = X
        ;   nonvar(X),
            nonvar(Y) ->
            kill(MState),
            (   X mod Y =:= 0 ->
                D = 1,
                R is X // Y
            ;   D = 0
            )
        ;   D == 1 ->
            kill(MState),
            queue_pgoal(#X / #Y #= #R)
        ;   []
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate(preified_exp(X, Y, D, R), MState) -->
        (   X == 1 ->
            kill(MState),
            D = 1,
            R = 1
        ;   Y == 0 ->
            kill(MState),
            D = 1,
            R = 1
        ;   Y == 1 ->
            kill(MState),
            D = 1,
            R = X
        ;   nonvar(X),
            nonvar(Y) ->
            kill(MState),
            (   ( abs(X) =:= 1 ; Y >= 0 ) ->
                D = 1,
                R is X^Y
            ;   D = 0
            )
        ;   D == 1 ->
            kill(MState),
            queue_pgoal(#X ^ #Y #= #R)
        ;   []
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Propagator Details
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

% TODO: Generate formulas for properties.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X =< Y /\ Y =< X <=> X = Y. % Reflexive
%   X =< Y <=> X = Y \/ X < Y

% Update to X
propagate_leq0_x(>, X, YU) -->
    {   n(XU) = YU,
        fd_get(X, XD0, XPs),
        domain_remove_greater_than(XU, XD0, XD)
    },
    fd_put(X, XD, XPs).
propagate_leq0_x(=, _, _) --> [].
propagate_leq0_x(<, _, _) --> [].

% Update to Y
propagate_leq0_y(>, XL, Y) -->
    {   n(YL) = XL,
        fd_get(Y, YD0, YPs),
        domain_remove_less_than(YL, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_leq0_y(=, _, _) --> [].
propagate_leq0_y(<, _, _) --> [].

'@propagate_leq0'(=, MState, X, Y) -->
    { kill(MState) },
    queue_pgoal(X = Y).
'@propagate_leq0'(<, _, X, Y) -->
    (   { var(X), var(Y) }
    ->  {   fd_get(X, XD, _), domain_supremum(XD, XU0),
            fd_get(Y, YD_, _), domain_supremum(YD_, YU0),
            cis_compare(O_X, XU0, YU0)
        },
        propagate_leq0_x(O_X, X, YU0)
    ;   []
    ),
    (   { var(Y), var(X) }
    ->  {   fd_get(Y, YD, _), domain_infimum(YD, YL0),
            fd_get(X, XD_, _), domain_infimum(XD_, XL0),
            cis_compare(O_Y, XL0, YL0)
        },
        propagate_leq0_y(O_Y, XL0, Y)
    ;   []
    ).

propagate_leq0(>, O, MState, X, Y) -->
    '@propagate_leq0'(O, MState, X, Y).
% propagate_leq0(=, O, MState, X, Y) -->
%     '@propagate_leq0'(O, MState, X, Y).
propagate_leq0(=, _, _, _, _) --> [].
propagate_leq0(<, _, MState, _, _) -->
    { kill(MState) }.

% propagate_leq0(>, =, MState, X, Y) -->
%     { kill(MState) },
%     queue_pgoal(X = Y).
% propagate_leq0(>, <, MState, X, Y) -->
%     (   { var(X), var(Y) }
%     ->  {   fd_get(X, XD, _), domain_supremum(XD, XU0),
%             fd_get(Y, YD_, _), domain_supremum(YD_, YU0),
%             cis_compare(O_X, XU0, YU0)
%         },
%         propagate_leq0x(O_X, X, YU0)
%     ;   []
%     ),
%     (   { var(Y), var(X) }
%     ->  {   fd_get(Y, YD, _), domain_infimum(YD, YL0),
%             fd_get(X, XD_, _), domain_infimum(XD_, XL0),
%             cis_compare(O_Y, XL0, YL0)
%         },
%         propagate_leq0y(O_Y, XL0, Y)
%     ;   []
%     ).
% propagate_leq0(=, _, MState, X, Y) --> [].
% propagate_leq0(<, _, MState, _, _) --> { kill(MState) }.

propagate_leq2(=).
propagate_leq2(<).

propagate_leq(MState, X, Y) -->
    (   { X == Y } % Optimization
    ->  { kill(MState) }
    ;   { var(X), var(Y) }
    % ->  []
    ->  { fd_get(X, XD, XPs), fd_get(Y, YD, YPs) },
        (   { C = pleq(Y,X), propagators_constraint(XPs, C0), C0 == C }
        ->  { kill(MState) },
            queue_pgoal(X = Y)
        ;   {   domain_infimum(XD, XL),
                domain_supremum(XD, XU),
                domain_infimum(YD, YL),
                domain_supremum(YD, YU),
                cis_compare(O0, XU, YL),
                cis_compare(O1, XL, YU)
            },
            % { portray_clause(user_output, XPs-YPs) },
            propagate_leq0(O0, O1, MState, X, Y)
        )
    ;   { nonvar(X), var(Y) }
    ->  {   fd_get(Y, YD0, YPs),
            domain_remove_less_than(X, YD0, YD),
            kill(MState)
        },
        fd_put(Y, YD, YPs)
    ;   { var(X), nonvar(Y) }
    ->  {   fd_get(X, XD0, XPs),
            domain_remove_greater_than(Y, XD0, XD),
            kill(MState)
        },
        fd_put(X, XD, XPs)
    ;   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), integer_compare(O, X, Y), propagate_leq2(O) }
    ;   { false }
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X \= X <=> false. % Irreflexive
%   X \= Y <=> Y \= X. % Symmetric

propagate_neq0(MState, X, Y) -->
    (   { var(X), var(Y) }
    ->  { X \== Y }, % Optimization?
        {   fd_get(X, XD, _), fd_get(Y, YD, _),
            if_(domain_intersects(XD, YD), true, kill(MState))
        }
    ;   []
    ).

% No update to X
propagate_neq1_x(MState, X, Y) -->
    {   kill(MState),
        fd_get(Y, YD0, YPs),
        domain_remove(X, YD0, YD)
    },
    fd_put(Y, YD, YPs).

propagate_neq1(MState, X, Y) -->
    (   { nonvar(X), var(Y) }
    ->  propagate_neq1_x(MState, X, Y)
    ;   { var(X), nonvar(Y) }
    ->  propagate_neq1_x(MState, Y, X)
    ;   []
    ).

propagate_neq2(MState, X, Y) -->
    (   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), X \== Y }
    ;   []
    ).

propagate_neq(MState, X, Y) -->
    propagate_neq0(MState, X, Y),
    propagate_neq1(MState, X, Y),
    propagate_neq2(MState, X, Y).
    % (   { var(X), var(Y) }
    % ->  { X \== Y }, % Optimization?
    %     {   fd_get(X, XD, _), fd_get(Y, YD, _),
    %         domain_inter(XD, YD, D),
    %         if_(domain_empty(D), kill(MState), true)
    %     }
    % ;   { nonvar(X), var(Y) }
    % ->  {   kill(MState),
    %         fd_get(Y, YD0, YPs),
    %         domain_remove(X, YD0, YD)
    %     },
    %     fd_put(Y, YD, YPs)
    % ;   { var(X), nonvar(Y) }
    % ->  {   kill(MState),
    %         fd_get(X, XD0, XPs),
    %         domain_remove(Y, XD0, XD)
    %     },
    %     fd_put(X, XD, XPs)
    % ;   { nonvar(X), nonvar(Y) }
    % ->  { kill(MState), X \== Y }
    % ;   { false }
    % ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X + Y = Z <=> Y + X = Z. % Commutative
%   X + Y = Z /\ X = 0 => Y = Z. % Identity element
%   X + Y = Z /\ X = Z => Y = 0. % Identity element
%   X + Y = Z /\ X = Y => 2 * X = Z.

% Update to X
propagate_iadd0_x(MState, X, Y, Z) -->
    (   { var(X), var(Y), var(Z) }
    ->  (   { Y == Z }
        ->  { kill(MState) },
            queue_pgoal(X = 0)
        ;   {   fd_get(X, XD0, XPs),
                fd_get(Y, YD, _),
                fd_get(Z, ZD, _),
                domain_infimum(YD, YL),
                domain_supremum(YD, YU),
                domain_infimum(ZD, ZL),
                domain_supremum(ZD, ZU),
                XL cis ZL-YU, XU cis ZU-YL,
                domain_from_bounds(XL, XU, XD1),
                domain_inter(XD1, XD0, XD)
            },
            fd_put(X, XD, XPs)
        )
    ;   []
    ).

% Update to Z
propagate_iadd0_z(MState, X, Y, Z) -->
    (   { var(X), var(Y), var(Z) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(#2 * #X #= #Z)
        ;   {   fd_get(Z, ZD0, ZPs),
                fd_get(Y, YD, _),
                fd_get(X, XD, _),
                domain_infimum(YD, YL),
                domain_supremum(YD, YU),
                domain_infimum(XD, XL),
                domain_supremum(XD, XU),
                ZL cis XL+YL, ZU cis XU+YU,
                domain_from_bounds(ZL, ZU, ZD1),
                domain_inter(ZD1, ZD0, ZD)
            },
            fd_put(Z, ZD, ZPs)
        )
    ;   []
    ).

propagate_iadd0(MState, X, Y, Z) -->
    propagate_iadd0_z(MState, X, Y, Z),
    propagate_iadd0_x(MState, X, Y, Z),
    propagate_iadd0_x(MState, Y, X, Z).

% No update to Z
propagate_iadd1_z(MState, X, Y, Z) -->
    (   { X == Y }
    ->  { kill(MState) },
        queue_pgoal(#2 * #X #= #Z)
    ;   (   { var(Y), var(X) }
        ->  {   fd_get(Y, YD0, YPs),
                fd_get(X, XD_, _),
                domain_expand(-1, XD_, YD1),
                domain_shift(Z, YD1, YD2),
                domain_inter(YD2, YD0, YD)
            },
            fd_put(Y, YD, YPs)
        ;   []
        ),
        (   { var(X), var(Y) }
        ->  {   fd_get(X, XD0, XPs),
                fd_get(Y, YD_, _),
                domain_expand(-1, YD_, XD1),
                domain_shift(Z, XD1, XD2),
                domain_inter(XD2, XD0, XD)
            },
            fd_put(X, XD, XPs)
        ;   []
        )
    ).

'@propagate_iadd1_x'(>, Y, Z) -->
    (   {   fd_get(Y, _, YPs),
            C = pleq(Z,Y),
            \+ (propagators_constraint(YPs, C0), C0 == C)
        }
    ->  queue_pgoal(#Y #> #Z)
    ;   []
    ).
'@propagate_iadd1_x'(<, Y, Z) -->
    (   {   fd_get(Y, _, YPs),
            C = pleq(Y,Z),
            \+ (propagators_constraint(YPs, C0), C0 == C)
        }
    ->  queue_pgoal(#Y #< #Z)
    ;   []
    ).

% No update to X
propagate_iadd1_x(MState, X, Y, Z) -->
    (   { X == 0 }
    ->  { kill(MState) },
        queue_pgoal(Y = Z)
    ;   { Y == Z }
    ->  { kill(MState), X = 0 }
    ;   % { integer_compare(O, 0, X) },
        % '@propagate_iadd1_x'(O, Y, Z),
        (   { var(Z), var(Y) }
        ->  {   SZ = X,
                fd_get(Z, ZD0, ZPs),
                fd_get(Y, YD_, _),
                domain_shift(SZ, YD_, ZD1),
                domain_inter(ZD1, ZD0, ZD)
            },
            fd_put(Z, ZD, ZPs)
        ;   []
        ),
        (   { var(Y), var(Z) }
        ->  {   integer_neg(X, SY),
                fd_get(Y, YD0, YPs),
                fd_get(Z, ZD_, _),
                domain_shift(SY, ZD_, YD1),
                domain_inter(YD1, YD0, YD)
            },
            fd_put(Y, YD, YPs)
        ;   []
        )
    ).

propagate_iadd1(MState, X, Y, Z) -->
    (   { var(X), var(Y), nonvar(Z) }
    ->  propagate_iadd1_z(MState, X, Y, Z)
    ;   { var(X), nonvar(Y), var(Z) }
    ->  propagate_iadd1_x(MState, Y, X, Z)
    ;   { nonvar(X), var(Y), var(Z) }
    ->  propagate_iadd1_x(MState, X, Y, Z)
    ;   []
    ).

propagate_iadd2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_add(X0, Y, Z) },
        queue_pgoal(X = X0)
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  { kill(MState), integer_add(X, Y0, Z) },
        queue_pgoal(Y = Y0)
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_add(X, Y, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_iadd3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_add(X, Y, Z) }
    ;   []
    ).

propagate_iadd(MState, X, Y, Z) -->
    propagate_iadd0(MState, X, Y, Z),
    propagate_iadd1(MState, X, Y, Z),
    propagate_iadd2(MState, X, Y, Z),
    propagate_iadd3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X * Y = Z <=> Y * X = Z. % Commutative
%   X * Y = Z /\ X = 0 => Z = 0. % Absorbing element
%   X * Y = Z /\ Z = 0 => X = 0 \/ Y = 0. % Zero-product
%   X * Y = Z /\ Z \= 0 => D = [-abs(Z);abs(Z)]\{0} /\ X in D /\ Y in D.
%   X * Y = Z /\ Z = 1 => X = Y /\ X in {-1,1}.
%   X * Y = Z /\ X = 1 => Y = Z. % Identity element
%   X * Y = Z /\ X = -1 => Y + Z = 0. % Canonical form
%   X * Y = Z /\ X = Z /\ X \= 0 => Y = 1. % Identity element
%   X * Y = Z /\ X = Y => X ^ 2 = Z.

'@propagate_imul0_x0'(false, MState, X) -->
    { kill(MState) },
    queue_pgoal(X = 1).
'@propagate_imul0_x0'( true, _, _) --> [].

'@propagate_imul0_xy'(false, ZD, YD, XD0, XD) :-
    domain_infimum(YD, YL),
    domain_supremum(YD, YU),
    domain_infimum(ZD, ZL),
    domain_supremum(ZD, ZU),
    list_foldl(
        call,
        [domain_remove_greater_than(-1),domain_supremum],
        YD,
        YLU
    ),
    list_foldl(
        call,
        [domain_remove_less_than(1),domain_infimum],
        YD,
        YUL
    ),
    if_(bound_finite(YLU),
        interval_factor(ZL-ZU, YL-YLU, XIs1),
        XIs1 = []
    ),
    if_(bound_finite(YUL),
        interval_factor(ZL-ZU, YUL-YU, XIs2),
        XIs2 = []
    ),
    intervals_union(XIs1, XIs2, XIs),
    domain_from_intervals(XIs, XD1),
    domain_inter(XD1, XD0, XD).
'@propagate_imul0_xy'( true, _, _, XD, XD).

'@propagate_imul0_xz'(false, ZD, YD, XD0, XD) :-
    domain_infimum(YD, YL),
    domain_supremum(YD, YU),
    domain_infimum(ZD, ZL),
    domain_supremum(ZD, ZU),
    list_foldl(
        call,
        [domain_remove_greater_than(-1),domain_supremum],
        ZD,
        ZLU
    ),
    list_foldl(
        call,
        [domain_remove_less_than(1),domain_infimum],
        ZD,
        ZUL
    ),
    if_(bound_finite(ZLU),
        interval_factor(ZL-ZLU, YL-YU, XIs1),
        XIs1 = []
    ),
    if_(bound_finite(ZUL),
        interval_factor(ZUL-ZU, YL-YU, XIs2),
        XIs2 = []
    ),
    intervals_union(XIs1, XIs2, XIs),
    domain_from_intervals(XIs, XD1),
    domain_inter(XD1, XD0, XD).
'@propagate_imul0_xz'( true, _, _, XD, XD).

% Update to X
propagate_imul0_x(MState, X, Y, Z) -->
    (   { var(X), var(Y), var(Z) }
    ->  (   { Y == Z }
        ->  {   fd_get(Z, ZD, _),
                domain_contains(ZD, 0, T)
            },
            '@propagate_imul0_x0'(T, MState, X)
        ;   {   fd_get(X, XD0, XPs),
                fd_get(Y, YD, _),
                fd_get(Z, ZD, _),
                % domain_infimum(YD, YL),
                % domain_supremum(YD, YU),
                % domain_infimum(ZD, ZL),
                % domain_supremum(ZD, ZU),
                domain_contains(YD, 0, YT),
                domain_contains(ZD, 0, ZT),
                '@propagate_imul0_xy'(YT, ZD, YD, XD0, XD1),
                '@propagate_imul0_xz'(ZT, ZD, YD, XD0, XD2),
                % if_(
                %     domain_contains(YD, 0),
                %     XD1 = XD0,
                %     (   list_foldl(
                %             call,
                %             [domain_remove_greater_than(-1),domain_supremum],
                %             YD,
                %             YLU
                %         ),
                %         list_foldl(
                %             call,
                %             [domain_remove_less_than(1),domain_infimum],
                %             YD,
                %             YUL
                %         ),
                %         if_(
                %             bound_finite(YLU),
                %             interval_factor(ZL-ZU, YL-YLU, XIs1_Y),
                %             XIs1_Y = []
                %         ),
                %         if_(
                %             bound_finite(YUL),
                %             interval_factor(ZL-ZU, YUL-YU, XIs2_Y),
                %             XIs2_Y = []
                %         ),
                %         intervals_union(XIs1_Y, XIs2_Y, XIs_Y),
                %         domain_from_intervals(XIs_Y, XD1_Y),
                %         domain_inter(XD1_Y, XD0, XD1)
                %     )
                % ),
                % if_(
                %     domain_contains(ZD, 0),
                %     XD2 = XD0,
                %     (   list_foldl(
                %             call,
                %             [domain_remove_greater_than(-1),domain_supremum],
                %             ZD,
                %             ZLU
                %         ),
                %         list_foldl(
                %             call,
                %             [domain_remove_less_than(1),domain_infimum],
                %             ZD,
                %             ZUL
                %         ),
                %         if_(
                %             bound_finite(ZLU),
                %             interval_factor(ZL-ZLU, YL-YU, XIs1_Z),
                %             XIs1_Z = []
                %         ),
                %         if_(
                %             bound_finite(ZUL),
                %             interval_factor(ZUL-ZU, YL-YU, XIs2_Z),
                %             XIs2_Z = []
                %         ),
                %         intervals_union(XIs1_Z, XIs2_Z, XIs_Z),
                %         % interval_factor(ZL-ZU, YL-YU, XIs_Z),
                %         domain_from_intervals(XIs_Z, XD1_Z),
                %         domain_inter(XD1_Z, XD0, XD2)
                %     )
                % ),
                domain_inter(XD1, XD2, XD3),
                domain_inter(XD3, XD0, XD)
                % if_(
                %     domain_contains(ZD, 0),
                %     XD = XD0,
                %     (   domain_infimum(ZD, ZL),
                %         domain_supremum(ZD, ZU),
                %         XU cis max(abs(ZL),abs(ZU)),
                %         XL cis -XU,
                %         domain_from_bounds(XL, XU, XD1),
                %         domain_inter(XD1, XD0, XD2),
                %         domain_remove(0, XD2, XD)
                %     )
                % )
            },
            fd_put(X, XD, XPs)
        )
    ;   []
    ).

% Update to Z
propagate_imul0_z(MState, X, Y, Z) -->
    (   { var(Z), var(X), var(Y) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(#X ^ #2 #= #Z)
        ;   {   fd_get(Z, ZD0, ZPs),
                fd_get(Y, YD, _),
                fd_get(X, XD, _),
                domain_infimum(YD, YL),
                domain_supremum(YD, YU),
                domain_infimum(XD, XL),
                domain_supremum(XD, XU),
                ZL cis min(min(XL*YL,XL*YU),min(XU*YL,XU*YU)),
                ZU cis max(max(XL*YL,XL*YU),max(XU*YL,XU*YU)),
                domain_from_bounds(ZL, ZU, ZD1),
                domain_inter(ZD1, ZD0, ZD2),
                if_((domain_contains(XD, 0) ; domain_contains(YD, 0)),
                    ZD = ZD2,
                    domain_remove(0, ZD2, ZD)
                )
            },
            fd_put(Z, ZD, ZPs)
        )
    ;   []
    ).

propagate_imul0(MState, X, Y, Z) -->
    propagate_imul0_x(MState, X, Y, Z),
    propagate_imul0_x(MState, Y, X, Z),
    propagate_imul0_z(MState, X, Y, Z).

'@propagate_imul1_z0'(false, MState, X) -->
    { kill(MState) },
    queue_pgoal(X = 0).
'@propagate_imul1_z0'( true, _, _) --> [].

'@propagate_imul1_zx'(X, Y, Z) -->
    {   fd_get(X, XD0, XPs),
        fd_get(Y, YD, _),
        domain_infimum(YD, YL),
        domain_supremum(YD, YU),
        list_foldl(
            call,
            [domain_remove_greater_than(-1),domain_supremum],
            YD,
            YLU
        ),
        list_foldl(
            call,
            [domain_remove_less_than(1),domain_infimum],
            YD,
            YUL
        ),
        if_(bound_finite(YLU),
            interval_factor(n(Z)-n(Z), YL-YLU, XIs0),
            XIs0 = []
        ),
        if_(bound_finite(YUL),
            interval_factor(n(Z)-n(Z), YUL-YU, XIs1),
            XIs1 = []
        ),
        intervals_union(XIs0, XIs1, XIs),
        domain_from_intervals(XIs, D),
        domain_inter(D, XD0, XD)
    },
    fd_put(X, XD, XPs).

% No update to Z
propagate_imul1_z(MState, X, Y, Z) -->
    (   { Z == 0 }
    ->  (   { var(X) }
        ->  {   fd_get(X, XD, _),
                domain_contains(XD, 0, XT)
            },
            '@propagate_imul1_z0'(XT, MState, Y)
        % ->  {   fd_get(X, XD, _),
        %         if_(
        %             domain_contains(XD, 0),
        %             G_X = true,
        %             (   kill(MState),
        %                 G_X = (Y = 0)
        %             )
        %         )
        %     },
        %     queue_pgoal(G_X)
        ;   []
        ),
        (   { var(Y) }
        ->  {   fd_get(Y, YD, _),
                domain_contains(YD, 0, YT)
            },
            '@propagate_imul1_z0'(YT, MState, X)
        % ->  {   fd_get(Y, YD, _),
        %         if_(
        %             domain_contains(YD, 0),
        %             G_Y = true,
        %             (   kill(MState),
        %                 G_Y = (X = 0)
        %             )
        %         )
        %     },
        %     queue_pgoal(G_Y)
        ;   []
        )
    ;   { X == Y }
    ->  { kill(MState) },
        queue_pgoal(#X ^ #2 #= #Z)
    ;   {   integer_abs(Z, U), integer_neg(U, L),
            domain_from_bounds(n(L), n(U), D0),
            domain_remove(0, D0, D)
        },
        (   { var(Y) }
        ->  {   fd_get(Y, YD0, YPs),
                domain_inter(D, YD0, YD)
            },
            fd_put(Y, YD, YPs)
        ;   []
        ),
        (   { var(X) }
        ->  {   fd_get(X, XD0, XPs),
                domain_inter(D, XD0, XD)
            },
            fd_put(X, XD, XPs)
        ;   []
        ),
        (   { Z == -1 }
        ->  { kill(MState) },
            queue_pgoal(#X + #Y #= #0)
        ;   { Z == 1 }
        ->  { kill(MState) },
            queue_pgoal(X = Y)
        ;   '@propagate_imul1_zx'(X, Y, Z),
            '@propagate_imul1_zx'(Y, X, Z)
        )
    ).

'@propagate_imul1_x_positive'(>, >, YPs, Y, Z) -->
    (   {   C = pleq(Z,Y),
            \+ (propagators_constraint(YPs, C0), C0 == C)
        }
    ->  queue_pgoal(#Z #=< #Y)
    % ;   {   \+ (
    %             list_element([pneq(Z,Y),pneq(Y,Z)], C),
    %             propagators_constraint(YPs, C0), C0 == C
    %         )
    %     }
    % ->  queue_pgoal(#Y #\= #Z)
    ;   []
    ).
'@propagate_imul1_x_positive'(>, =, YPs, Y, Z) -->
    (   {   C = pleq(Z,Y),
            \+ (propagators_constraint(YPs, C0), C0 == C)
        }
    ->  queue_pgoal(#Z #=< #Y)
    ;   []
    ).
'@propagate_imul1_x_positive'(>, <, _, _, _) --> [].
'@propagate_imul1_x_positive'(=, <, YPs, Y, Z) -->
    (   {   C = pleq(Y,Z),
            \+ (propagators_constraint(YPs, C0), C0 == C)
        }
    ->  queue_pgoal(#Y #=< #Z)
    ;   []
    ).
'@propagate_imul1_x_positive'(<, <, YPs, Y, Z) -->
    (   {   C = pleq(Y,Z),
            \+ (propagators_constraint(YPs, C0), C0 == C)
        }
    ->  queue_pgoal(#Y #=< #Z)
    % ;   {   \+ (
    %             list_element([pneq(Y,Z),pneq(Z,Y)], C),
    %             propagators_constraint(YPs, C0), C0 == C
    %         )
    %     }
    % ->  queue_pgoal(#Y #\= #Z)
    ;   []
    ).

% Nothing when X is negative since the sign of Y and Z are different.
'@propagate_imul1_x'(>, _, _) --> [].
'@propagate_imul1_x'(<, Y, Z) -->
    {   fd_get(Y, YD, YPs),
        domain_infimum(YD, YL),
        domain_supremum(YD, YU),
        cis_compare(O0, n(0), YL),
        cis_compare(O1, n(0), YU)
    },
    '@propagate_imul1_x_positive'(O0, O1, YPs, Y, Z).

'@propagate_imul1_x_eq'(false, MState, X) -->
    { kill(MState), X = 1 }.
'@propagate_imul1_x_eq'( true, _, _) --> [].

% No update to X
propagate_imul1_x(MState, X, Y, Z) -->
    (   { X == 0 }
    ->  { kill(MState) },
        queue_pgoal(Z = 0)
    ;   { X == 1 }
    ->  { kill(MState) },
        queue_pgoal(Z = Y)
    ;   { X == -1 }
    ->  { kill(MState) },
        queue_pgoal(#Z + #Y #= #0)
    ;   { Y == Z }
    ->  {   fd_get(Z, ZD, _),
            domain_contains(ZD, 0, Truth)
            % if_(domain_contains(ZD, 0), true, (kill(MState), X = 1))
        },
        '@propagate_imul1_x_eq'(Truth, MState, X)
    ;   % { integer_compare(O, 0, X) },
        % '@propagate_imul1_x'(O, Y, Z),
        (   { var(Z), var(Y) }
        ->  {   fd_get(Z, ZD0, ZPs),
                fd_get(Y, YD_, _),
                domain_expand(X, YD_, ZD1),
                domain_inter(ZD1, ZD0, ZD)
            },
            fd_put(Z, ZD, ZPs)
        ;   []
        ),
        (   { var(Y), var(Z) }
        ->  {   fd_get(Y, YD0, YPs),
                fd_get(Z, ZD_, _),
                domain_shrink(X, ZD_, YD1),
                domain_inter(YD1, YD0, YD2),
                if_(domain_contains(ZD_, 0),
                    YD = YD2,
                    domain_remove(0, YD2, YD)
                )
            },
            fd_put(Y, YD, YPs)
        ;   []
        )
    ).

propagate_imul1(MState, X, Y, Z) -->
    (   { nonvar(X), var(Y), var(Z) }
    ->  propagate_imul1_x(MState, X, Y, Z)
    ;   { var(X), nonvar(Y), var(Z) }
    ->  propagate_imul1_x(MState, Y, X, Z)
    ;   { var(X), var(Y), nonvar(Z) }
    ->  propagate_imul1_z(MState, X, Y, Z)
    ;   []
    ).

% Update to X
propagate_imul2_x(>, X, Y, Z) -->
    { integer_mul(X0, Y, Z) },
    queue_pgoal(X = X0).
propagate_imul2_x(=, _, 0, 0) --> [].
propagate_imul2_x(<, X, Y, Z) -->
    { integer_mul(X0, Y, Z) },
    queue_pgoal(X = X0).

propagate_imul2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_compare(O, 0, Y) },
        propagate_imul2_x(O, X, Y, Z)
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  { kill(MState), integer_compare(O, 0, X) },
        propagate_imul2_x(O, Y, X, Z)
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_mul(X, Y, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_imul3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_mul(X, Y, Z) }
    ;   []
    ).

propagate_imul(MState, X, Y, Z) -->
    propagate_imul0(MState, X, Y, Z),
    propagate_imul1(MState, X, Y, Z),
    propagate_imul2(MState, X, Y, Z),
    propagate_imul3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Potential Properties:
%   X ^ Y = Z => (abs(X) \= 1 => Y >= 0).
%   X ^ Y = Z /\ X = 0 => (Z = 0 /\ Y > 0)\/(Z = 1 /\ Y = 0).
%   X ^ Y = Z /\ abs(X) \= 1 => Y >= 0.
%   X ^ Y = Z /\ X = -1 => Z in {-1,1}. % g X
%   X ^ Y = Z /\ Z = -1 /\ X = -1 => Y mod 2 = 1.
%   X ^ Y = Z /\ Z = 1 /\ X = -1 => Y mod 2 = 0.
%   X ^ Y = Z /\ X = 1 => Z = 1. % g X
%   %X ^ Y = Z /\ abs(X) = 1 => abs(Z) = 1.
%   X ^ Y = Z /\ Y = 0 => Z = 1. % g Y
%   X ^ Y = Z /\ Y < 0 /\ Y mod 2 = 0 => Z = 1 /\ X in {-1,1}. % g Y
%   X ^ Y = Z /\ Y < 0 /\ Y mod 2 = 1 => Z = X /\ X in {-1,1}. % g Y
%   %X ^ Y = Z /\ Y < 0 /\ Z = -1 => X = -1. % there is better % g Z
%   %X ^ Y = Z /\ Y < 0 /\ Z = 1 => X in {-1,1}. % there is better % g Z
%   X ^ Y = Z /\ Y < 0 => Z in {-1,1} /\ X in {-1,1}.
%   X ^ Y = Z /\ Y = 1 => Z = X. % g Y
%   X ^ Y = Z /\ Z = 0 => X = 0 /\ Y > 0. % g Z
%   X ^ Y = Z /\ abs(Z) \= 1 => Y > 0.
%   X ^ Y = Z /\ Z = -1 => X = -1 /\ Y mod 2 = 1.
%   X ^ Y = Z /\ Z = 1 /\ Y \= 0 => X in {-1,1}.
%   X ^ Y = Z /\ Z = 1 /\ abs(X) \= 1 => Y = 0.
%   X ^ Y = Z /\ Z = X /\ Y = 0 => X = 1.
%   X ^ Y = Z /\ Z = X /\ Y = -1 => X in {-1,1}.
%   X ^ Y = Z /\ Z = X /\ Y = 1 => true.
%   X ^ Y = Z /\ Z = X /\ abs(X) \= 1 => Y = 1.
%   X ^ Y = Z /\ Y = Z => X in {-1,1}.
%   X ^ Y = Z /\ X = Y => X >= -1.
% Properties:
%   X ^ Y = Z /\ Y > 0 /\ Y mod 2 = 0 => X in {-nrt(Y,abs(Z)),nrt(Y,abs(Z)}.
%   X ^ Y = Z /\ Y > 0 /\ Y mod 2 = 1 => X = sign(Z)*nrt(Y,abs(Z)).
%   X ^ Y = Z /\ Y = 0 => Z = 1.
%   X ^ Y = Z /\ Y < 0 /\ Y mod 2 = 0 /\ Z = 1 => X in {-1,1}.
%   X ^ Y = Z /\ Y < 0 /\ Y mod 2 = 1 /\ Z in {-1,1} => Z = X.
%   X ^ Y = Z /\ abs(X) > 1 => Y = log(X,Z).
%   X ^ Y = Z /\ X = -1 /\ X = -1 => Y mod 2 = 1. % abs(X) = 1
%   X ^ Y = Z /\ X = -1 /\ Z = 1 => Y mod 2 = 0. % abs(X) = 1
%   X ^ Y = Z /\ X = 1 /\ Z = 1 => true. % abs(X) = 1
%   X ^ Y = Z /\ X = 0 /\ Z = 0 => Y > 0. % abs(X) < 1
%   X ^ Y = Z /\ X = 0 /\ Z = 1 => Y = 0. % abs(X) < 1
%   X ^ Y = Z /\ Z = 0 => X = 0 /\ Y > 0.
% X ^ Y = Z /\ Z = -1 => X = -1, Y mod 2 #= 1
% X ^ Y = Z /\ Z = 1 => Y = 0 \/ X = 1 \/ (X = -1 /\ Y mod 2 #= 0)
% X ^ Y = Z /\ Z < 0 => X =< 0

'@@propagate_iexp1_xy_inf'(n(L0), X, n(L)) :-
    integer_log(ceil, X, L0, L).

'@@propagate_iexp1_xy_sup'(n(U0), X, n(U)) :-
    integer_log(floor, X, U0, U).
'@@propagate_iexp1_xy_sup'(sup, _, sup).

'@@propagate_iexp1_xz_inf'(n(_), X, n(L0), n(L)) :-
    integer_exp(X, L0, L).
'@@propagate_iexp1_xz_inf'(sup, _, _, n(1)).

'@@propagate_iexp1_xz_sup'(n(_), X, U0, U) :-
    U cis n(X)^U0.
'@@propagate_iexp1_xz_sup'(sup, _, _, sup).

'@@propagate_iexp1_xy'(X, Y, Z) -->
    {   fd_get(Z, ZD, _),
        fd_get(Y, YD0, YPs),
        domain_infimum(ZD, ZL),
        '@@propagate_iexp1_xy_inf'(ZL, X, YL),
        domain_supremum(ZD, ZU),
        '@@propagate_iexp1_xy_sup'(ZU, X, YU),
        domain_from_bounds(YL, YU, D),
        domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).

'@@propagate_iexp1_xz'(X, Y, Z) -->
    {   fd_get(Y, YD, _),
        fd_get(Z, ZD0, ZPs),
        domain_supremum(ZD0, ZU0),
        domain_infimum(YD, YL),
        % if_(bound_finite(ZU), ZL cis n(X)^YL, ZL = n(1)),
        '@@propagate_iexp1_xz_inf'(ZU0, X, YL, ZL),
        domain_supremum(YD, YU),
        % if_(bound_finite(ZU), ZU cis n(X)^YU, ZU = sup),
        '@@propagate_iexp1_xz_sup'(ZU0, X, YU, ZU),
        domain_from_bounds(ZL, ZU, D),
        domain_inter(D, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).

'@propagate_iexp1_x'(>, _, Y, Z) -->
    (   { var(Y), var(Z) }
    ->  {   fd_get(Y, YD0, YPs),
            domain_remove_less_than(0, YD0, YD)
        },
        fd_put(Y, YD, YPs)
    ;   []
    ),
    (   { var(Y), var(Z) }
    ->  {   fd_get(Z, ZD0, ZPs),
            domain_remove(0, ZD0, ZD)
        },
        fd_put(Z, ZD, ZPs)
    ;   []
    ).
'@propagate_iexp1_x'(<, X, Y, Z) -->
    {   fd_get(Z, ZD0, ZPs),
        domain_remove_less_than(1, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs),
    % Case for: ?- #D * #C #= -2, #A ^ #B #= #C, A = 3, D = -2, B = 0.
    {   fd_get(Y, YD0, YPs),
        domain_remove_less_than(0, YD0, YD)
    },
    fd_put(Y, YD, YPs),
    (   { var(Y), var(Z) }
    ->  '@@propagate_iexp1_xy'(X, Y, Z)
    ;   []
    ),
    (   { var(Y), var(Z) }
    ->  '@@propagate_iexp1_xz'(X, Y, Z)
    ;   []
    ).

% No update to X
propagate_iexp1_x(>, _, 0, Y, Z) -->
    { Y \== Z }, % optimization.
    {   fd_get(Y, YD0, YPs),
        domain_remove_less_than(0, YD0, YD)
    },
    fd_put(Y, YD, YPs),
    {   domain_from_bounds(n(0), n(1), D),
        fd_get(Z, ZD0, ZPs),
        domain_inter(D, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).
propagate_iexp1_x(=, MState, X, _, Z) -->
    (   { X == -1 }
    ->  {   domain_from_numbers([-1,1], D),
            fd_get(Z, ZD0, ZPs),
            domain_inter(D, ZD0, ZD)
        },
        fd_put(Z, ZD, ZPs)
    ;   { X == 1 }
    ->  { kill(MState) },
        queue_pgoal(Z = 1)
    ;   { false }
    ).
propagate_iexp1_x(<, _, X, Y, Z) -->
    { Y \== Z }, % optimization.
    { integer_compare(O, 0, X) },
    '@propagate_iexp1_x'(O, X, Y, Z).

'@@propagate_iexp1_y_positive_0x_inf'(n(L0), Y, n(L)) :-
    integer_nrt(ceil, Y, L0, L).

'@@propagate_iexp1_y_positive_0x_sup'(n(U0), Y, n(U)) :-
    integer_nrt(floor, Y, U0, U).
'@@propagate_iexp1_y_positive_0x_sup'(sup, _, sup).

'@@propagate_iexp1_y_positive_0z_inf'(n(_), Y, n(L0), n(L)) :-
    integer_exp(L0, Y, L).
'@@propagate_iexp1_y_positive_0z_inf'(sup, _, _, n(0)).

'@@propagate_iexp1_y_positive_0z_sup'(n(_), Y, n(U0), n(U)) :-
    integer_exp(U0, Y, U).
    % U cis U0^n(Y).
'@@propagate_iexp1_y_positive_0z_sup'(sup, _, _, sup).


'@@propagate_iexp1_y_positive_0x'(X, Y, Z) -->
    {   fd_get(Z, ZD, _),
        fd_get(X, XD0, XPs),
        domain_infimum(ZD, ZL),
        '@@propagate_iexp1_y_positive_0x_inf'(ZL, Y, XL),
        domain_supremum(ZD, ZU),
        '@@propagate_iexp1_y_positive_0x_sup'(ZU, Y, XU),
        domain_from_bounds(XL, XU, D0),
        domain_expand(-1, D0, D1),
        domain_union(D0, D1, D),
        domain_inter(D, XD0, XD)
    },
    fd_put(X, XD, XPs).

'@@propagate_iexp1_y_positive_0z'(X, Y, Z) -->
    {   fd_get(X, XD, _),
        fd_get(Z, ZD0, ZPs),
        domain_supremum(ZD0, ZU0),
        domain_remove_less_than(0, XD, XDU),
        domain_remove_greater_than(0, XD, XDL),
        domain_infimum(XDU, XL_U),
        domain_supremum(XDL, XL_L),
        XL cis min(-XL_L,XL_U),
        '@@propagate_iexp1_y_positive_0z_inf'(ZU0, Y, XL, ZL),
        domain_supremum(XDU, XU_U),
        domain_infimum(XDL, XU_L),
        XU cis max(-XU_L,XU_U),
        '@@propagate_iexp1_y_positive_0z_sup'(ZU0, Y, XU, ZU),
        domain_from_bounds(ZL, ZU, D),
        domain_inter(D, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).

'@@propagate_iexp1_y_positive_1x_inf'(>, inf, _, inf).
'@@propagate_iexp1_y_positive_1x_inf'(>, n(L0), Y, n(L)) :-
    integer_add(A0, L0, 0),
    integer_nrt(floor, Y, A0, A),
    integer_add(L, A, 0).
'@@propagate_iexp1_y_positive_1x_inf'(=, n(0), _, n(0)).
'@@propagate_iexp1_y_positive_1x_inf'(<, n(L0), Y, n(L)) :-
    integer_nrt(ceil, Y, L0, L).

'@@propagate_iexp1_y_positive_1x_sup'(>, n(U0), Y, n(U)) :-
    integer_add(A0, U0, 0),
    integer_nrt(ceil, Y, A0, A),
    integer_add(U, A, 0).
'@@propagate_iexp1_y_positive_1x_sup'(=, n(0), _, n(0)).
'@@propagate_iexp1_y_positive_1x_sup'(<, n(U0), Y, n(U)) :-
    integer_nrt(floor, Y, U0, U).
'@@propagate_iexp1_y_positive_1x_sup'(<, sup, _, sup).

'@@propagate_iexp1_y_positive_1z_inf'(inf, _, _, inf).
'@@propagate_iexp1_y_positive_1z_inf'(n(_), Y, n(L0), n(L)) :-
    integer_exp(L0, Y, L).

'@@propagate_iexp1_y_positive_1z_sup'(n(_), Y, n(U0), n(U)) :-
    integer_exp(U0, Y, U).
'@@propagate_iexp1_y_positive_1z_sup'(sup, _, _, sup).

'@@propagate_iexp1_y_positive_1x'(X, Y, Z) -->
    {   fd_get(Z, ZD, _),
        fd_get(X, XD0, XPs),
        domain_infimum(ZD, ZL),
        cis_compare(O_I, n(0), ZL),
        '@@propagate_iexp1_y_positive_1x_inf'(O_I, ZL, Y, XL),
        domain_supremum(ZD, ZU),
        cis_compare(O_S, n(0), ZU),
        '@@propagate_iexp1_y_positive_1x_sup'(O_S, ZU, Y, XU),
        domain_from_bounds(XL, XU, D),
        domain_inter(D, XD0, XD)
    },
    fd_put(X, XD, XPs).

'@@propagate_iexp1_y_positive_1z'(X, Y, Z) -->
    {   fd_get(X, XD, _),
        fd_get(Z, ZD0, ZPs),
        domain_infimum(ZD0, ZL0),
        domain_infimum(XD, XL),
        '@@propagate_iexp1_y_positive_1z_inf'(ZL0, Y, XL, ZL),
        domain_supremum(ZD0, ZU0),
        domain_supremum(XD, XU),
        '@@propagate_iexp1_y_positive_1z_sup'(ZU0, Y, XU, ZU),
        domain_from_bounds(ZL, ZU, D),
        domain_inter(D, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).

'@propagate_iexp1_y_negative'(0, _, _, Z) -->
    queue_pgoal(Z = 1).
'@propagate_iexp1_y_negative'(1, X, _, Z) -->
    queue_pgoal(Z = X).

'@propagate_iexp1_y_positive'(0, _, X, Y, Z) -->
    {   fd_get(Z, ZD0, ZPs),
        domain_remove_less_than(0, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs),
    (   { var(X), var(Z) }
    ->  '@@propagate_iexp1_y_positive_0x'(X, Y, Z)
    ;   []
    ),
    (   { var(X), var(Z) }
    ->  '@@propagate_iexp1_y_positive_0z'(X, Y, Z)
    ;   []
    ).
'@propagate_iexp1_y_positive'(1, MState, X, Y, Z) -->
    (   { Y == 1 }
    ->  { kill(MState) },
        queue_pgoal(Z = X)
    ;   (   { var(X), var(Z) }
        ->  '@@propagate_iexp1_y_positive_1x'(X, Y, Z)
        ;   []
        ),
        (   { var(X), var(Z) }
        ->  '@@propagate_iexp1_y_positive_1z'(X, Y, Z)
        ;   []
        )
    ).

% No update to Y
propagate_iexp1_y(>, P, MState, X, Y, Z) -->
    { kill(MState) },
    {   domain_from_numbers([-1,1], D),
        fd_get(X, XD0, XPs),
        domain_inter(D, XD0, XD)
    },
    fd_put(X, XD, XPs),
    '@propagate_iexp1_y_negative'(P, X, Y, Z).
propagate_iexp1_y(=, 0, MState, _, 0, Z) -->
    { kill(MState) },
    queue_pgoal(Z = 1).
propagate_iexp1_y(<, P, MState, X, Y, Z) -->
    '@propagate_iexp1_y_positive'(P, MState, X, Y, Z).

'@propagate_iexp1_z_one_x'(false, MState, Y) -->
    { kill(MState) },
    queue_pgoal(Y = 0).
'@propagate_iexp1_z_one_x'( true, _MState, _) --> [].

'@propagate_iexp1_z_one_y'(false, X) -->
    {   fd_get(X, XD0, XPs),
        domain_from_numbers([-1,1], D),
        domain_inter(D, XD0, XD)
    },
    fd_put(X, XD, XPs).
'@propagate_iexp1_z_one_y'( true, _) --> [].

'@propagate_iexp1_z_one'(-1, MState, X, Y) -->
    { kill(MState) },
    queue_pgoal(X = -1),
    queue_pgoal(#Y mod #2 #= #1).
'@propagate_iexp1_z_one'( 1, MState, X, Y) -->
    {   fd_get(X, XD, _),
        domain_from_numbers([-1,1], D),
        domain_intersects(XD, D, XT)
    },
    '@propagate_iexp1_z_one_x'(XT, MState, Y),
    {   fd_get(Y, YD, _),
        domain_contains(YD, 0, YT)
    },
    '@propagate_iexp1_z_one_y'(YT, X).

'@propagate_iexp1_z_big_x'(>, X) -->
    {   fd_get(X, XD0, XPs),
        domain_remove_greater_than(-2, XD0, XD)
    },
    fd_put(X, XD, XPs).
'@propagate_iexp1_z_big_x'(<, _) --> [].

% No update to Z
propagate_iexp1_z(>, MState, X, Y, 0) -->
    { kill(MState) },
    {   fd_get(Y, YD0, YPs),
        domain_remove_less_than(1, YD0, YD)
    },
    fd_put(Y, YD, YPs),
    queue_pgoal(X = 0).
propagate_iexp1_z(=, MState, X, Y, Z) -->
    '@propagate_iexp1_z_one'(Z, MState, X, Y).
    % (   { Z == -1 }
    % ->  { kill(MState) },
    %     queue_pgoal(X = -1),
    %     queue_pgoal(#Y mod #2 #= #1)
    % ;   { Z == 1 } % Do nothing.
    % ).
propagate_iexp1_z(<, _MState, X, Y, Z) -->
    { integer_compare(O, 0, Z) },
    '@propagate_iexp1_z_big_x'(O, X),
    {   fd_get(Y, YD0, YPs),
        domain_remove_less_than(1, YD0, YD)
    },
    fd_put(Y, YD, YPs).

propagate_iexp1(MState, X, Y, Z) -->
    (   { nonvar(X), var(Y), var(Z) }
    ->  { integer_abs(X, AX), integer_compare(O, 1, AX) },
        propagate_iexp1_x(O, MState, X, Y, Z)
    ;   { var(X), nonvar(Y), var(Z) }
    ->  { integer_compare(O, 0, Y), integer_ddqr(floor, Y, 2, _, P) },
        propagate_iexp1_y(O, P, MState, X, Y, Z)
    ;   { var(X), var(Y), nonvar(Z) }
    ->  { integer_abs(Z, AZ), integer_compare(O, 1, AZ) },
        propagate_iexp1_z(O, MState, X, Y, Z)
    ;   []
    ).

'@propagate_iexp2_x_negative'(0, X, _, Z) -->
    {   Z = 1,
        domain_from_numbers([-1,1], D),
        fd_get(X, XD0, XPs),
        domain_inter(D, XD0, XD)
    },
    fd_put(X, XD, XPs).
'@propagate_iexp2_x_negative'(1, X, _, Z) -->
    % {   if_(Z= -1, true, Z = 1),
    %     if_(Z=1, true, Z = -1)
    % },
    % queue_pgoal(X = Z).
    (   { Z == -1 }
    ->  queue_pgoal(X = Z)
    ;   { Z == 1 }
    ->  queue_pgoal(X = Z)
    ;   { false }
    ).

'@propagate_iexp2_x_positive'(0, X, Y, Z) -->
    (   { Z == 0 }
    ->  queue_pgoal(X = 0)
    ;   {   integer_compare(<, 0, Z),
            integer_nrt(floor, Y, Z, U),
            integer_exp(U, Y, Z),
            integer_neg(U, L),
            domain_from_numbers([L,U], D),
            fd_get(X, XD0, XPs),
            domain_inter(D, XD0, XD)
        },
        fd_put(X, XD, XPs)
    ).
'@propagate_iexp2_x_positive'(1, X, Y, Z) -->
    {   integer_abs(Z, AZ),
        integer_nrt(floor, Y, AZ, AX),
        integer_exp(AX, Y, AZ),
        integer_sgn(Z, SZ),
        integer_mul(SZ, AX, X0)
    },
    queue_pgoal(X = X0).

% Update to X
propagate_iexp2_x(>, P, X, Y, Z) -->
    '@propagate_iexp2_x_negative'(P, X, Y, Z).
propagate_iexp2_x(=, 0, _, _, 1) --> [].
propagate_iexp2_x(<, P, X, Y, Z) -->
    '@propagate_iexp2_x_positive'(P, X, Y, Z).

% Update to Y
propagate_iexp2_y(>, 0, Y, Z) -->
    % {   fd_get(Y, YD0, YPs),
    %     if_(Z=0, (domain_remove_less_than(1, YD0, YD), G = true), Z = 1),
    %     if_(Z=1, (YD = YD0, G = (Y = 0)), Z = 0)
    % },
    % fd_put(Y, YD, YPs),
    % queue_pgoal(G).
    (   { Z == 0 }
    ->  { fd_get(Y, YD0, YPs), domain_remove_less_than(1, YD0, YD) },
        fd_put(Y, YD, YPs)
    ;   { Z == 1 }
    ->  queue_pgoal(Y = 0)
    ;   { false }
    ).
propagate_iexp2_y(=, X, Y, Z) -->
    % (   { Z == -1 }
    % ->  { X == -1 },
    %     queue_pgoal(#Y mod #2 #= #1)
    % ;   { Z == 1 }
    % ->  (   { X == -1 }
    %     ->  queue_pgoal(#Y mod #2 #= #0)
    %     ;   { X == 1 }
    %     )
    % ;   { false }
    % ).
    (   { X == -1 }
    ->  % (   { Z == -1 }
        % ->  queue_pgoal(#Y mod #2 #= #1)
        % ;   { Z == 1 }
        % ->  queue_pgoal(#Y mod #2 #= #0)
        % ;   { false }
        % )
        { integer_abs(Z, 1), integer_add(Y0, Z, 1), integer_shr(1, Y0, Y1) },
        queue_pgoal(#Y mod #2 #= #Y1)
    ;   { X == 1, Z == 1 }
    ).
propagate_iexp2_y(<, X, Y, Z) -->
    {   integer_abs(X, AX),
        integer_abs(Z, AZ),
        integer_log(floor, AX, AZ, Y0),
        integer_exp(X, Y0, Z)
    },
    queue_pgoal(Y = Y0).

propagate_iexp2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  {   kill(MState),
            integer_compare(O, 0, Y),
            integer_ddqr(floor, Y, 2, _, P)
        },
        propagate_iexp2_x(O, P, X, Y, Z)
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  { kill(MState), integer_abs(X, AX), integer_compare(O, 1, AX) },
        propagate_iexp2_y(O, X, Y, Z)
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_exp(X, Y, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_iexp3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_exp(X, Y, Z) }
    ;   []
    ).

propagate_iexp(MState, X, Y, Z) -->
    % propagate_iexp0(MState, X, Y, Z),
    propagate_iexp1(MState, X, Y, Z),
    propagate_iexp2(MState, X, Y, Z),
    propagate_iexp3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Definition:
%   min(X,Y) = Z <=> (Z = X /\ Z < Y) \/ (Z < X /\ Z = Y) \/ (Z = X /\ Z = Y).
%   min(X,Y) = Z <=> Z =< X /\ Z =< Y /\ (Z = X \/ Z = Y).
% Properties:
%   min(X,Y) = Z => Z = X \/ Z = Y.
%   min(X,Y) = Z => Z =< X /\ Z =< Y.
%   min(X,Y) = Z <=> min(Y,X) = Z. % Commutative.
%   min(X,Y) = Z /\ Y = Z => Z =< X.
%   min(X,Y) = Z /\ Y > Z => Z = X.
%   min(X,Y) = Z /\ X =< Y => Z = X.

'@propagate_imin0_'(>, _, _, _, _) --> [].
'@propagate_imin0_'(=, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imin0_'(<, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).

'@propagate_imin0_'(inf, _) --> [].
'@propagate_imin0_'(n(L), Z) -->
    {   fd_get(Z, ZD0, ZPs),
        domain_remove_less_than(L, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).

propagate_imin0(MState, X, Y, Z) -->
    (   { var(X), var(Y), var(Z) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(Z = X)
        ;   { Y == Z }
        ->  { kill(MState) }
        ;   { Z == X }
        ->  { kill(MState) }
        ;   { fd_get(X, XD, _), fd_get(Y, YD, _) }, % QUESTION: Can it be better?
            (   { var(X), var(Y), var(Z) }
            ->  {   domain_supremum(XD, XU),
                    domain_infimum(YD, YL),
                    cis_compare(O_X, XU, YL)
                },
                '@propagate_imin0_'(O_X, MState, X, Y, Z)
            ;   []
            ),
            (   { var(Y), var(X), var(Z) }
            ->  {   domain_supremum(YD, YU),
                    domain_infimum(XD, XL),
                    cis_compare(O_Y, YU, XL)
                },
                '@propagate_imin0_'(O_Y, MState, Y, X, Z)
            ;   []
            ),
            (   { var(Y), var(X), var(Z) }
            ->  { ZL cis min(XL,YL) },
                '@propagate_imin0_'(ZL, Z)
            ;   []
            )
        )
    ;   []
    ).

'@propagate_imin1_xy'(>, >, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Z = Y).
'@propagate_imin1_xy'(>, =, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Z = Y).
'@propagate_imin1_xy'(>, <, _, _, _, _) --> [].
'@propagate_imin1_xy'(=, =, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imin1_xy'(=, <, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imin1_xy'(<, <, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).

'@propagate_imin1_x'(inf, _) --> [].
'@propagate_imin1_x'(n(L), Z) -->
    {   fd_get(Z, ZD0, ZPs),
        domain_remove_less_than(L, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).

'@propagate_imin1_xz'(>, >, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Z = Y).
'@propagate_imin1_xz'(>, =, _, _, _, _) --> [].
'@propagate_imin1_xz'(>, <, _, _, _, _) --> [].
'@propagate_imin1_xz'(=, <, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imin1_xz'(=, =, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).

% No update to X
propagate_imin1_x(MState, X, Y, Z) -->
    (   { Y == Z }
    ->  { kill(MState) }
    ;   {   fd_get(Y, YD, _),
            domain_infimum(YD, YL),
            domain_supremum(YD, YU),
            cis_compare(O_I0, n(X), YL),
            cis_compare(O_S0, n(X), YU),
            Min cis min(n(X),YL)
        },
        '@propagate_imin1_xy'(O_I0, O_S0, MState, X, Y, Z),
        '@propagate_imin1_x'(Min, Z),
        {   fd_get(Z, ZD, _),
            domain_infimum(ZD, ZL),
            domain_supremum(ZD, ZU),
            cis_compare(O_I1, n(X), ZL),
            cis_compare(O_S1, n(X), ZU)
        },
        '@propagate_imin1_xz'(O_I1, O_S1, MState, X, Y, Z)
    ).

'@propagate_imin1_z'(>, _, _, _, _) --> [].
'@propagate_imin1_z'(=, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(X = Z).
'@propagate_imin1_z'(<, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(X = Z).

'@propagate_imin1_z'(false,  true, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Y = Z).
'@propagate_imin1_z'( true, false, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(X = Z).
'@propagate_imin1_z'( true,  true, _, _, _, _) --> [].

% No update to Z
propagate_imin1_z(MState, X, Y, Z) -->
    (   { X == Y }
    ->  { kill(MState) },
        queue_pgoal(X = Z)
    ;   { fd_get(X, XD0, _), fd_get(Y, YD0, _) },
        (   { var(X), var(Y) }
        ->  {   domain_supremum(XD0, XU0),
                domain_infimum(YD0, YL0),
                cis_compare(O0, XU0, YL0)
            },
            '@propagate_imin1_z'(O0, MState, X, Y, Z)
        ;   []
        ),
        (   { var(Y), var(X) }
        ->  {   domain_supremum(YD0, YU0),
                domain_infimum(XD0, XL0),
                cis_compare(O1, YU0, XL0)
            },
            '@propagate_imin1_z'(O1, MState, Y, X, Z)
        ;   []
        ),
        {   fd_get(X, XD, _),
            fd_get(Y, YD, _),
            domain_infimum(XD, XL),
            domain_infimum(YD, YL),
            ZL cis min(XL,YL),
            ZL cis min(n(Z),ZL),
            domain_contains(XD, Z, XT),
            domain_contains(YD, Z, YT)
        },
        '@propagate_imin1_z'(XT, YT, MState, X, Y, Z)
    ).

propagate_imin1(MState, X, Y, Z) -->
    (   { nonvar(X), var(Y), var(Z) }
    ->  propagate_imin1_x(MState, X, Y, Z)
    ;   { var(X), nonvar(Y), var(Z) }
    ->  propagate_imin1_x(MState, Y, X, Z)
    ;   { var(X), var(Y), nonvar(Z) }
    ->  propagate_imin1_z(MState, X, Y, Z)
    ;   []
    ).

% Update to X
propagate_imin2_x(>, X, _, Z) --> queue_pgoal(X = Z).
propagate_imin2_x(=, _, Z, Z) --> [].

propagate_imin2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_compare(O, Y, Z) },
        propagate_imin2_x(O, X, Y, Z)
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  { kill(MState), integer_compare(O, X, Z) },
        propagate_imin2_x(O, Y, X, Z)
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_min(X, Y, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_imin3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_min(X, Y, Z) }
    ;   []
    ).

propagate_imin(MState, X, Y, Z) -->
    propagate_imin0(MState, X, Y, Z),
    propagate_imin1(MState, X, Y, Z),
    propagate_imin2(MState, X, Y, Z),
    propagate_imin3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Definition:
%   max(X,Y) = Z <=> (X = Z /\ Y < Z) \/ (X < Z /\ Y = Z) \/ (X = Z /\ Y = Z).
%   max(X,Y) = Z <=> X =< Z /\ Y =< Z /\ (X = Z \/ Y = Z).
% Properties:
%   max(X,Y) = Z => X =< Z /\ Y =< Z.
%   max(X,Y) = Z <=> max(Y,X) = Z. % Commutative.
%   max(X,Y) = Z /\ Y = Z => X =< Z.
%   max(X,Y) = Z /\ Y < Z => X = Z.
%   max(X,Y) = Z /\ X =< Y => Z = Y.

'@propagate_imax0_'(>, _, _, _, _) --> [].
'@propagate_imax0_'(=, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Z = Y).
'@propagate_imax0_'(<, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Z = Y).

'@propagate_imax0_'(n(U), Z) -->
    {   fd_get(Z, ZD0, ZPs),
        domain_remove_greater_than(U, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).
'@propagate_imax0_'(sup, _) --> [].

propagate_imax0(MState, X, Y, Z) -->
    (   { var(X), var(Y), var(Z) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(Z = X)
        ;   { Y == Z }
        ->  { kill(MState) }
        ;   { Z == X }
        ->  { kill(MState) }
        ;   { fd_get(X, XD, _), fd_get(Y, YD, _) }, % QUESTION: Can it be better?
            (   { var(X), var(Y), var(Z) }
            ->  {   domain_supremum(XD, XU),
                    domain_infimum(YD, YL),
                    cis_compare(O_X, XU, YL)
                },
                '@propagate_imax0_'(O_X, MState, X, Y, Z)
            ;   []
            ),
            (   { var(Y), var(X), var(Z) }
            ->  {   domain_supremum(YD, YU),
                    domain_infimum(XD, XL),
                    cis_compare(O_Y, YU, XL)
                },
                '@propagate_imax0_'(O_Y, MState, Y, X, Z)
            ;   []
            ),
            (   { var(Y), var(X), var(Z) }
            ->  { ZU cis max(XU,YU) },
                '@propagate_imax0_'(ZU, Z)
            ;   []
            )
        )
    ;   []
    ).

'@propagate_imax1_xy'(>, >, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imax1_xy'(>, =, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imax1_xy'(=, =, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imax1_xy'(>, <, _, _, _, _) --> [].
'@propagate_imax1_xy'(=, <, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Z = Y).
'@propagate_imax1_xy'(<, <, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Z = Y).

'@propagate_imax1_x'(n(L), Z) -->
    {   fd_get(Z, ZD0, ZPs),
        domain_remove_greater_than(L, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).
'@propagate_imax1_x'(sup, _) --> [].

'@propagate_imax1_xz'(=, =, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imax1_xz'(>, =, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = X).
'@propagate_imax1_xz'(>, <, _, _, _, _) --> [].
'@propagate_imax1_xz'(=, <, _, _, _, _) --> [].
'@propagate_imax1_xz'(<, <, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Z = Y).

% No update to X
propagate_imax1_x(MState, X, Y, Z) -->
    (   { Y == Z }
    ->  { kill(MState) }
    ;   {   fd_get(Y, YD, _),
            domain_infimum(YD, YL),
            domain_supremum(YD, YU),
            cis_compare(O_I0, n(X), YL),
            cis_compare(O_S0, n(X), YU),
            Max cis max(n(X),YU)
        },
        '@propagate_imax1_xy'(O_I0, O_S0, MState, X, Y, Z),
        '@propagate_imax1_x'(Max, Z),
        {   fd_get(Z, ZD, _),
            domain_infimum(ZD, ZL),
            domain_supremum(ZD, ZU),
            cis_compare(O_I1, n(X), ZL),
            cis_compare(O_S1, n(X), ZU)
        },
        '@propagate_imax1_xz'(O_I1, O_S1, MState, X, Y, Z)
    ).

'@propagate_imax1_z'(>, _, _, _, _) --> [].
'@propagate_imax1_z'(=, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Y = Z).
'@propagate_imax1_z'(<, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Y = Z).

'@propagate_imax1_z'(false,  true, MState, _, Y, Z) -->
    { kill(MState) },
    queue_pgoal(Y = Z).
'@propagate_imax1_z'( true, false, MState, X, _, Z) -->
    { kill(MState) },
    queue_pgoal(X = Z).
'@propagate_imax1_z'( true,  true, _, _, _, _) --> [].

% No update to Z
propagate_imax1_z(MState, X, Y, Z) -->
    (   { X == Y }
    ->  { kill(MState) },
        queue_pgoal(X = Z)
    ;   { fd_get(X, XD0, _), fd_get(Y, YD0, _) },
        (   { var(X), var(Y) }
        ->  {   domain_supremum(XD0, XU0),
                domain_infimum(YD0, YL0),
                cis_compare(O0, XU0, YL0)
            },
            '@propagate_imax1_z'(O0, MState, X, Y, Z)
        ;   []
        ),
        (   { var(Y), var(X) }
        ->  {   domain_supremum(YD0, YU0),
                domain_infimum(XD0, XL0),
                cis_compare(O1, YU0, XL0)
            },
            '@propagate_imax1_z'(O1, MState, Y, X, Z)
        ;   []
        ),
        {   fd_get(X, XD, _),
            fd_get(Y, YD, _),
            domain_supremum(XD, XU),
            domain_supremum(YD, YU),
            ZU cis max(XU,YU),
            ZU cis max(n(Z),ZU),
            domain_contains(XD, Z, XT),
            domain_contains(YD, Z, YT)
        },
        '@propagate_imax1_z'(XT, YT, MState, X, Y, Z)
    ).

propagate_imax1(MState, X, Y, Z) -->
    (   { nonvar(X), var(Y), var(Z) }
    ->  propagate_imax1_x(MState, X, Y, Z)
    ;   { var(X), nonvar(Y), var(Z) }
    ->  propagate_imax1_x(MState, Y, X, Z)
    ;   { var(X), var(Y), nonvar(Z) }
    ->  propagate_imax1_z(MState, X, Y, Z)
    ;   []
    ).

% Update to X
propagate_imax2_x(=, _, Z, Z) --> [].
propagate_imax2_x(<, X, _, Z) --> queue_pgoal(X = Z).

propagate_imax2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_compare(O, Y, Z) },
        propagate_imax2_x(O, X, Y, Z)
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  { kill(MState), integer_compare(O, X, Z) },
        propagate_imax2_x(O, Y, X, Z)
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_max(X, Y, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_imax3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_max(X, Y, Z) }
    ;   []
    ).

propagate_imax(MState, X, Y, Z) -->
    propagate_imax0(MState, X, Y, Z),
    propagate_imax1(MState, X, Y, Z),
    propagate_imax2(MState, X, Y, Z),
    propagate_imax3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X mod Y = Z <=> Z = X - floor(X / Y) * Y.
%   X mod Y = Z => X-Z mod Y = 0.
%   X mod Y = Z => abs(Z) < abs(Y).
%   X mod Y = Z /\ Y > 0 => Z >= 0.
%   X mod Y = Z /\ Y < 0 => Z =< 0.
%   X mod Y = Z /\ Z > 0 => X < 0 \/ Z =< X
%   X mod Y = Z /\ Z < 0 => 0 < X \/ X =< Z
%   X mod Y = Z /\ Z > 0 /\ X > 0 /\ Z \= X => Z < Y =< X-Z
%   X mod Y = Z /\ Z > 0 /\ X > 0 /\ Z = X => Z < Y
%   X mod Y = Z /\ Z > 0 /\ X < 0 => Z < Y =< Z-X
%   X mod Y = Z /\ Z < 0 /\ X > 0 => Z-X =< Y < Z
%   X mod Y = Z /\ Z < 0 /\ X < 0 /\ Z = X => Y < Z
%   X mod Y = Z /\ Z < 0 /\ X < 0 /\ Z \= X => X-Z =< Y < Z

'@propagate_imod1_x_negative_y'(>, >, _, _, Y) -->
    {   fd_get(Y, YD0, YPs),
        domain_remove_greater_than(-2, YD0, YD)
    },
    fd_put(Y, YD, YPs).
'@propagate_imod1_x_negative_y'(>, =, _, U, Y) -->
    {   fd_get(Y, YD0, YPs),
        domain_from_bounds(inf, U, D), domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).
'@propagate_imod1_x_negative_y'(=, =, _, _, _) --> [].
'@propagate_imod1_x_negative_y'(=, <, X, U, Y) -->
    {   fd_get(Y, YD0, YPs),
        domain_from_bounds(n(X), U, D), domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).
'@propagate_imod1_x_negative_y'(>, <, _, _, _) --> [].
'@propagate_imod1_x_negative_y'(<, <, _, U, Y) -->
    {   fd_get(Y, YD0, YPs),
        domain_from_bounds(n(2), U, D), domain_inter(D, YD0, YD)
        % domain_remove_less_than(2, YD0, YD)
    },
    fd_put(Y, YD, YPs).

% X > 0 ==> Z =< X
% X < 0 ==> Z >= X
% X < 0, ZL =< Z =< ZU, (0 =< ZU ==> Y =< ZU-X)
% X > 0, ZL =< Z =< ZU, (ZL =< 0 ==> ZL-X =< Y)
% ground(X), ZL =< Z =< ZU < 0 ==> Y =< ZU-1
% ground(X), 0 < ZL =< Z =< ZU ==> ZL+1 =< Y

% '@propagate_imod1_xn_y_z_sup'(>, _, _, _) --> [].
% '@propagate_imod1_xn_y_z_sup'(=, X, n(0), Y) -->
%     {   fd_get(Y, YD0, YPs),
%         integer_add(U, X, 0),
%         domain_remove_greater_than(U, YD0, YD)
%     },
%     fd_put(Y, YD, YPs).
% '@propagate_imod1_xn_y_z_sup'(<, X, ZU, Y) -->
%     {   fd_get(Y, YD0, YPs),
%         U cis ZU-n(X),
%         domain_from_bounds(inf, U, D),
%         domain_inter(D, YD0, YD)
%         % integer_add(U, X, Z), domain_remove_greater_than(U, YD0, YD)
%     },
%     fd_put(Y, YD, YPs).

% '@propagate_imod1_xp_y_z_inf'(>, X, ZL, Y) -->
%     {   fd_get(Y, YD0, YPs),
%         L cis ZL-n(X),
%         domain_from_bounds(L, sup, D),
%         domain_inter(D, YD0, YD)
%         % integer_add(L, X, Z), domain_remove_less_than(L, YD0, YD)
%     },
%     fd_put(Y, YD, YPs).
% '@propagate_imod1_xp_y_z_inf'(=, X, n(0), Y) -->
%     {   fd_get(Y, YD0, YPs),
%         integer_add(L, X, 0),
%         domain_remove_less_than(L, YD0, YD)
%     },
%     fd_put(Y, YD, YPs).
% '@propagate_imod1_xp_y_z_inf'(<, _, _, _) --> [].

'@propagate_imod1_x_y_z_inf'(>, _, _) --> [].
'@propagate_imod1_x_y_z_inf'(=, _, _) --> [].
'@propagate_imod1_x_y_z_inf'(<, Y, n(L0)) -->
    {   fd_get(Y, YD0, YPs),
        integer_add(1, L0, L),
        domain_remove_less_than(L, YD0, YD)
    },
    fd_put(Y, YD, YPs).

'@propagate_imod1_x_y_z_sup'(>, Y, n(U0)) -->
    {   fd_get(Y, YD0, YPs),
        integer_add(1, U, U0),
        domain_remove_greater_than(U, YD0, YD)
    },
    fd_put(Y, YD, YPs).
'@propagate_imod1_x_y_z_sup'(=, _, _) --> [].
'@propagate_imod1_x_y_z_sup'(<, _, _) --> [].

% No update to X
propagate_imod1_x(>, _, X, Y, Z) -->
    {   fd_get(Z, ZD0, ZPs),
        domain_remove_less_than(X, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs),
    {   domain_infimum(ZD, ZL),
        domain_supremum(ZD, ZU),
        cis_compare(O_I, n(0), ZL),
        cis_compare(O_S, n(0), ZU)
    },
    '@propagate_imod1_x_y_z_inf'(O_I, Y, ZL),
    '@propagate_imod1_x_y_z_sup'(O_S, Y, ZU).
    % '@propagate_imod1_xn_y_z_sup'(O_S, X, ZU, Y).
propagate_imod1_x(=, MState, 0, _, Z) -->
    { kill(MState) },
    queue_pgoal(Z = 0).
propagate_imod1_x(<, _, X, Y, Z) -->
    {   fd_get(Z, ZD0, ZPs),
        domain_remove_greater_than(X, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs),
    {   domain_infimum(ZD, ZL),
        domain_supremum(ZD, ZU),
        cis_compare(O_I, n(0), ZL),
        cis_compare(O_S, n(0), ZU)
    },
    '@propagate_imod1_x_y_z_inf'(O_I, Y, ZL),
    '@propagate_imod1_x_y_z_sup'(O_S, Y, ZU).
    % '@propagate_imod1_xp_y_z_inf'(O_I, X, ZL, Y).

% No update to Y
propagate_imod1_y(>, _, Y, Z) -->
    {   fd_get(Z, ZD0, ZPs),
        integer_add(1, Y, L),
        domain_from_bounds(n(L), n(0), D),
        domain_inter(D, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).
propagate_imod1_y(<, _, Y, Z) -->
    {   fd_get(Z, ZD0, ZPs),
        integer_add(1, U, Y),
        domain_from_bounds(n(0), n(U), D),
        domain_inter(D, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).

% No update to Z
propagate_imod1_z(>, X, Y, Z) -->
    {   fd_get(X, XD0, XPs),
        integer_add(1, Z, L),
        domain_from_bounds(n(L), n(0), D),
        domain_diff(D, XD0, XD)
    },
    fd_put(X, XD, XPs),
    {   fd_get(Y, YD0, YPs),
        integer_add(1, U, Z),
        domain_remove_greater_than(U, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_imod1_z(=, _, _, 0) --> [].
propagate_imod1_z(<, X, Y, Z) -->
    {   fd_get(X, XD0, XPs),
        integer_add(1, U, Z),
        domain_from_bounds(n(0), n(U), D),
        domain_diff(D, XD0, XD)
    },
    fd_put(X, XD, XPs),
    {   fd_get(Y, YD0, YPs),
        integer_add(1, Z, L),
        domain_remove_less_than(L, YD0, YD)
    },
    fd_put(Y, YD, YPs).

propagate_imod1(MState, X, Y, Z) -->
    (   { nonvar(X), var(Y), var(Z) }
    ->  { integer_compare(O, 0, X) },
        propagate_imod1_x(O, MState, X, Y, Z)
    ;   { var(X), nonvar(Y), var(Z) }
    ->  { integer_compare(O, 0, Y) },
        propagate_imod1_y(O, X, Y, Z)
    ;   { var(X), var(Y), nonvar(Z) }
    ->  { integer_compare(O, 0, Z) },
        propagate_imod1_z(O, X, Y, Z)
    ;   []
    ).

'@propagate_imod2_xz'(>, X, Z) -->
    {   fd_get(X, XD0, XPs),
        integer_add(1, Z, L),
        domain_from_bounds(n(L), n(0), D),
        domain_diff(D, XD0, XD)
    },
    fd_put(X, XD, XPs).
'@propagate_imod2_xz'(=, _, 0) --> [].
'@propagate_imod2_xz'(<, X, Z) -->
    {   fd_get(X, XD0, XPs),
        integer_add(1, U, Z),
        domain_from_bounds(n(0), n(U), D),
        domain_diff(D, XD0, XD)
    },
    fd_put(X, XD, XPs).

% Update to X
propagate_imod2_x(>, X, Y, Z) -->
    {   integer_le(Z, 0),
        integer_compare(O, 0, Z)
    },
    '@propagate_imod2_xz'(O, X, Z),
    {
        fd_get(X, XD0, XPs),
        domain_infimum(XD0, XL0),
        if_(bound_finite(XL0),
            XL cis n(Z)+  ( (XL0-n(Z)) div n(Y))*n(Y),
            XL = XL0
        ),
        domain_supremum(XD0, XU0),
        if_(bound_finite(XU0),
            XU cis n(Z)+ -(-(XU0-n(Z)) div n(Y))*n(Y),
            XU = XU0
        ),
        domain_from_bounds(XL, XU, XD1),
        domain_inter(XD1, XD0, XD)
    },
    fd_put(X, XD, XPs).
propagate_imod2_x(<, X, Y, Z) -->
    {   integer_le(0, Z),
        integer_compare(O, 0, Z)
    },
    '@propagate_imod2_xz'(O, X, Z),
    {
        fd_get(X, XD0, XPs),
        domain_infimum(XD0, XL0),
        if_(bound_finite(XL0),
            XL cis n(Z)+ -(-(XL0-n(Z)) div n(Y))*n(Y),
            XL = XL0
        ),
        domain_supremum(XD0, XU0),
        if_(bound_finite(XU0),
            XU cis n(Z)+  ( (XU0-n(Z)) div n(Y))*n(Y),
            XU = XU0
        ),
        domain_from_bounds(XL, XU, XD1),
        domain_inter(XD1, XD0, XD)
    },
    fd_put(X, XD, XPs).

'@propagate_imod2y_negative'(>, _, X, Z, D) :-
    integer_add(L, Z, X), % X-Z #= L
    YL = n(L),
    integer_add(1, U, Z), % Z-1 #= U
    YU = n(U),
    \+ integer_compare(>, L, U),
    domain_from_bounds(YL, YU, D).
'@propagate_imod2y_negative'(=, MState, Z, Z, D) :-
    kill(MState),
    YL = inf,
    integer_add(1, U, Z), % Z-1 #= U
    YU = n(U),
    domain_from_bounds(YL, YU, D).

'@propagate_imod2y_positive'(=, MState, Z, Z, D) :-
    kill(MState),
    integer_add(1, Z, L), % Z+1 #= L
    YL = n(L),
    YU = sup,
    domain_from_bounds(YL, YU, D).
'@propagate_imod2y_positive'(<, _, X, Z, D) :-
    integer_add(1, Z, L), % Z+1 #= L
    YL = n(L),
    integer_add(U, Z, X), % X-Z #= U
    \+ integer_compare(>, L, U),
    YU = n(U),
    domain_from_bounds(YL, YU, D).

% Update to Y
propagate_imod2_y(>, >, MState, X, Y, Z) -->
    {   fd_get(Y, YD0, YPs),
        integer_compare(O, Z, X),
        '@propagate_imod2y_negative'(O, MState, X, Z, D),
        % \+ integer_compare(<, Z, X),
        % integer_add(1, U, Z), % Z-1 #= U
        % YU = n(U),
        % (   X == Z
        % ->  kill(MState),
        %     YL = inf
        % ;   integer_add(L, Z, X), % X-Z #= L
        %     \+ integer_compare(>, L, U),
        %     YL = n(L)
        % ),
        % domain_from_bounds(YL, YU, D),
        domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_imod2_y(>, <, _, X, Y, Z) -->
    {   fd_get(Y, YD0, YPs),
        integer_add(L, X, Z), % Z-X #= L
        integer_add(1, U, Z), % Z-1 #= U
        domain_from_bounds(n(L), n(U), D),
        domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_imod2_y(=, >, _, X, Y, 0) -->
    {   fd_get(Y, YD0, YPs),
        L = X,
        integer_neg(X, U),
        domain_from_bounds(n(L), n(U), D),
        domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_imod2_y(=, =, MState, 0, _, 0) --> { kill(MState) }.
propagate_imod2_y(=, <, _, X, Y, 0) -->
    {   fd_get(Y, YD0, YPs),
        integer_neg(X, L),
        X = U,
        domain_from_bounds(n(L), n(U), D),
        domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_imod2_y(<, >, _, X, Y, Z) -->
    {   fd_get(Y, YD0, YPs),
        integer_add(1, Z, L), % Z+1 #= L
        integer_add(U, X, Z), % Z-X #= U
        domain_from_bounds(n(L), n(U), D),
        domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_imod2_y(<, <, MState, X, Y, Z) -->
    {   fd_get(Y, YD0, YPs),
        integer_compare(O, Z, X),
        '@propagate_imod2y_positive'(O, MState, X, Z, D),
        % \+ integer_compare(>, Z, X),
        % integer_add(1, Z, L), % Z+1 #= L
        % YL = n(L),
        % (   X == Z
        % ->  kill(MState),
        %     YU = sup
        % ;   integer_add(U, Z, X), % X-Z #= U
        %     \+ integer_compare(>, L, U),
        %     YU = n(U)
        % ),
        % domain_from_bounds(YL, YU, D),
        domain_inter(D, YD0, YD)
    },
    fd_put(Y, YD, YPs).

propagate_imod2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  { integer_compare(O, 0, Y) },
        propagate_imod2_x(O, X, Y, Z)
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  { integer_compare(O0, 0, Z), integer_compare(O1, 0, X) },
        propagate_imod2_y(O0, O1, MState, X, Y, Z)
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_ddqr(floor, X, Y, _, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_imod3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_ddqr(floor, X, Y, _, Z) }
    ;   []
    ).

propagate_imod(MState, X, Y, Z) -->
    % propagate_imod0(MState, X, Y, Z),
    propagate_imod1(MState, X, Y, Z),
    propagate_imod2(MState, X, Y, Z),
    propagate_imod3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X rem Y = Z <=> Z = X - truncate(X / Y) * Y.
%   X rem Y = Z => X-Z rem Y = 0.
%   X rem Y = Z => abs(Z) < abs(Y).
%   X rem Y = Z => 0 =< X * Z.
%   X rem Y = Z <=> sign(X)*(abs(X) mod abs(Y)) = Z.
%   X rem Y = Z /\ X >= 0 /\ Y > 0 <=> X mod Y = Z.
%   X rem Y = Z /\ X =< 0 /\ Y > 0 <=> -X mod -Y = Z.
%   X rem Y = Z /\ X =< 0 /\ Y < 0 <=> -X mod Y = Z.
%   X rem Y = Z /\ X >= 0 /\ Y < 0 <=> X mod -Y = Z.

propagate_irem(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), var(Z) }
    ->  {   kill(MState),
            integer_sgn(X, SX),
            integer_abs(X, AX),
            integer_abs(Y, AY),
            integer_ddqr(floor, AX, AY, _, AZ),
            integer_mul(SX, AZ, Z0)
        },
        queue_pgoal(Z = Z0)
    % ->  {   kill(MState),
    %         integer_sgn(X, SX),
    %         integer_sgn(Y, SY),
    %         integer_mul(SX, SY, SQ),
    %         integer_abs(X, AX),
    %         integer_abs(Y, AY),
    %         integer_ddqr(floor, AX, AY, AQ, _),
    %         integer_mul(SQ, AQ, Q),
    %         integer_mul(Q, Y, N),
    %         integer_add(Z0, N, X)
    %     },
    %     queue_pgoal(Z = Z0)
    ;   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  {   kill(MState),
            integer_sgn(X, SX),
            integer_abs(X, AX),
            integer_abs(Y, AY),
            integer_ddqr(floor, AX, AY, _, AZ),
            integer_mul(SX, AZ, Z)
        }
    % ->  {   kill(MState),
    %         integer_sgn(X, SX),
    %         integer_sgn(Y, SY),
    %         integer_mul(SX, SY, SQ),
    %         integer_abs(X, AX),
    %         integer_abs(Y, AY),
    %         integer_ddqr(floor, AX, AY, AQ, _),
    %         integer_mul(SQ, AQ, Q),
    %         integer_mul(Q, Y, N),
    %         integer_add(Z, N, X)
    %     }
    ;   []
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   abs(X) = Y /\ X > 0 => Y = X.
%   abs(X) = Y /\ X = 0 => Y = X.
%   abs(X) = Y /\ X < 0 => Y = -X.
%   abs(X) = Y /\ Y = 0 => X = Y.
%   abs(X) = Y /\ Y > 0 => X in {-Y,Y}.

propagate_iabs0_x(X, Y) -->
    (   { var(X), var(Y) }
    ->  {   fd_get(Y, YD_, _),
            domain_expand(-1, YD_, D0_X),
            domain_union(YD_, D0_X, D1_X),
            fd_get(X, XD0, XPs),
            domain_inter(D1_X, XD0, XD)
        },
        fd_put(X, XD, XPs)
    ;   []
    ).

propagate_iabs0_y(X, Y) -->
    (   { var(X), var(Y) }
    ->  {   fd_get(X, XD_, _),
            domain_remove_less_than(0, XD_, D0_Y),
            domain_remove_greater_than(0, XD_, D1_Y),
            domain_expand(-1, D1_Y, D2_Y),
            domain_union(D0_Y, D2_Y, D3_Y),
            fd_get(Y, YD0, YPs),
            domain_inter(D3_Y, YD0, YD)
        },
        fd_put(Y, YD, YPs)
    ;   []
    ).

'@propagate_iabs0'(<, <, MState, X, Y) -->
    { kill(MState) },
    queue_pgoal(X = Y).
'@propagate_iabs0'(=, <, MState, X, Y) -->
    { kill(MState) },
    queue_pgoal(X = Y).
'@propagate_iabs0'(>, <, _, _, _) --> [].
'@propagate_iabs0'(>, =, MState, X, Y) -->
    { kill(MState) },
    queue_pgoal(- #X #= #Y).
'@propagate_iabs0'(>, >, MState, X, Y) -->
    { kill(MState) },
    queue_pgoal(- #X #= #Y).

propagate_iabs0(MState, X, Y) -->
    (   { var(X), var(Y) }
    ->  propagate_iabs0_x(X, Y),
        propagate_iabs0_y(X, Y),
        (   { var(X), var(Y) }
        ->  {   fd_get(X, XD, _),
                domain_infimum(XD, XL),
                domain_supremum(XD, XU),
                cis_compare(O_I, n(0), XL),
                cis_compare(O_S, n(0), XU)
            },
            '@propagate_iabs0'(O_I, O_S, MState, X, Y)
        ;   []
        )
    ;   []
    ).

% Update to X
propagate_iabs1x(=, X, 0) --> queue_pgoal(X = 0).
propagate_iabs1x(<, X, Y) -->
    {   fd_get(X, XD0, XPs),
        integer_neg(Y, L),
        U = Y,
        domain_from_numbers([L,U], D),
        domain_inter(D, XD0, XD)
    },
    fd_put(X, XD, XPs).

propagate_iabs1(MState, X, Y) -->
    (   { var(X), nonvar(Y) }
    ->  { kill(MState), integer_compare(O, 0, Y) },
        propagate_iabs1x(O, X, Y)
    ;   { nonvar(X), var(Y) }
    ->  { kill(MState), integer_abs(X, Y0) },
        queue_pgoal(Y = Y0)
    ;   []
    ).

propagate_iabs2(MState, X, Y) -->
    (   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), integer_abs(X, Y) }
    ;   []
    ).

propagate_iabs(MState, X, Y) -->
    propagate_iabs0(MState, X, Y),
    propagate_iabs1(MState, X, Y),
    propagate_iabs2(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Definition:
%   sign(X) = Y <=> max(-1,min(1,X)) = Y /\ min(1,max(-1,X)) = Y.
% Properties:
%   sign(X) = Y => Y in {-1,0,1}.
%   sign(X) = Y /\ X > 0 => Y = 1.
%   sign(X) = Y /\ X >= 0 => Y in {0,1}.
%   sign(X) = Y /\ X = 0 => Y = 0.
%   sign(X) = Y /\ X =< 0 => Y in {-1,0}.
%   sign(X) = Y /\ X < 0 => Y = -1.
%   sign(X) = Y /\ Y =< 0 => X =< 0.
%   sign(X) = Y /\ Y >= 0 => X >= 0.
%   sign(X) = Y /\ Y = -1 => X < 0.
%   sign(X) = Y /\ Y = 0 => X = 0.
%   sign(X) = Y /\ Y = 1 => X > 0.

% No update to X
'propagate_isgn0_x'(>, >, MState, Y) -->
    { kill(MState) },
    queue_pgoal(Y = -1).
'propagate_isgn0_x'(>, =, _, Y) -->
    {   fd_get(Y, YD0, YPs),
        domain_remove(1, YD0, YD)
    },
    fd_put(Y, YD, YPs).
'propagate_isgn0_x'(>, <, _, _) --> [].
'propagate_isgn0_x'(=, <, _, Y) -->
    {   fd_get(Y, YD0, YPs),
        domain_remove(-1, YD0, YD)
    },
    fd_put(Y, YD, YPs).
'propagate_isgn0_x'(<, <, MState, Y) -->
    { kill(MState) },
    queue_pgoal(Y = 1).

% No update to Y
'propagate_isgn0_y'(>, =, X) -->
    {   fd_get(X, XD0, XPs),
        domain_remove_greater_than(0, XD0, XD)
    },
    fd_put(X, XD, XPs).
'propagate_isgn0_y'(>, <, _) --> [].
'propagate_isgn0_y'(=, <, X) -->
    {   fd_get(X, XD0, XPs),
        domain_remove_less_than(0, XD0, XD)
    },
    fd_put(X, XD, XPs).

propagate_isgn0(MState, X, Y) -->
    (   { var(X), var(Y) }
    ->  (   { X == Y }
        ->  { kill(MState) }
        ;   (   { var(X), var(Y) }
            ->  {   fd_get(X, XD, _),
                    domain_infimum(XD, XL),
                    domain_supremum(XD, XU),
                    cis_compare(O_XI, n(0), XL),
                    cis_compare(O_XS, n(0), XU)
                },
                'propagate_isgn0_x'(O_XI, O_XS, MState, Y)
            ;   []
            ),
            (   { var(X), var(Y) }
            ->  {   fd_get(Y, YD, _),
                    domain_infimum(YD, YL),
                    domain_supremum(YD, YU),
                    cis_compare(O_YI, n(0), YL),
                    cis_compare(O_YS, n(0), YU)
                },
                'propagate_isgn0_y'(O_YI, O_YS, X)
            ;   []
            )
        )
    ;   []
    ).

% No update to X
propagate_isgn1_x(X, -1) -->
    { fd_get(X, XD0, XPs), domain_remove_greater_than(-1, XD0, XD) },
    fd_put(X, XD, XPs).
propagate_isgn1_x(X, 0) --> queue_pgoal(X = 0).
propagate_isgn1_x(X, 1) -->
    { fd_get(X, XD0, XPs), domain_remove_less_than(1, XD0, XD) },
    fd_put(X, XD, XPs).

propagate_isgn1(MState, X, Y) -->
    (   { var(X), nonvar(Y) }
    ->  { kill(MState) },
        propagate_isgn1_x(X, Y)
    ;   { nonvar(X), var(Y) }
    ->  { kill(MState), integer_sgn(X, Y0) },
        queue_pgoal(Y = Y0)
    ;   []
    ).

propagate_isgn2(MState, X, Y) -->
    (   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), integer_sgn(X, Y) }
    ;   []
    ).

propagate_isgn(MState, X, Y) -->
    propagate_isgn0(MState, X, Y),
    propagate_isgn1(MState, X, Y),
    propagate_isgn2(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X << Y = Z /\ X >= 0 => floor(X * 2^Y) = Z.
%   X << Y = Z <=> floor(X * 2^Y) = Z.
%   X << Y = Z /\ Y > 0 => X * 2^Y = Z.
%   X << Y = Z /\ Y = 0 => X = Z.
%   X << Y = Z /\ Y < 0 => X div 2^Y = Z.

propagate_ishl2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  []
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  []
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_shl(Y, X, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_ishl3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_shl(Y, X, Z) }
    ;   []
    ).

propagate_ishl(MState, X, Y, Z) -->
    % propagate_ishl0(MState, X, Y, Z),
    % propagate_ishl1(MState, X, Y, Z),
    propagate_ishl2(MState, X, Y, Z),
    propagate_ishl3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X >> Y = Z /\ X >= 0 <=> floor(X * 2^ -Y) = Z.
%   X >> Y = Z <=> floor(X * 2^ -Y) = Z.
%   X >> Y = Z /\ Y > 0 => X div 2^Y = Z.
%   X >> Y = Z /\ Y = 0 => X = Z.
%   X >> Y = Z /\ Y < 0 => X * 2^Y = Z.

propagate_ishr2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  []
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  []
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_shr(Y, X, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_ishr3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_shr(Y, X, Z) }
    ;   []
    ).

propagate_ishr(MState, X, Y, Z) -->
    % propagate_ishr0(MState, X, Y, Z),
    % propagate_ishr1(MState, X, Y, Z),
    propagate_ishr2(MState, X, Y, Z),
    propagate_ishr3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X /\ Y = Z.

propagate_iand2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  []
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  []
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_and(X, Y, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_iand3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_and(X, Y, Z) }
    ;   []
    ).

propagate_iand(MState, X, Y, Z) -->
    % propagate_iand0(MState, X, Y, Z),
    % propagate_iand1(MState, X, Y, Z),
    propagate_iand2(MState, X, Y, Z),
    propagate_iand3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X \/ Y = Z.
%   X \/ Y = Z /\ Z = 0 => X = 0 /\ Y = 0.
%   X \/ Y = Z /\ Z >= 0 => max(msb(X), msb(Y)) =< msb(Z).

propagate_iior2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  []
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  []
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_ior(X, Y, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_iior3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_ior(X, Y, Z) }
    ;   []
    ).

propagate_iior(MState, X, Y, Z) -->
    % propagate_iior0(MState, X, Y, Z),
    % propagate_iior1(MState, X, Y, Z),
    propagate_iior2(MState, X, Y, Z),
    propagate_iior3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   Z = X xor Y /\ X = Y => Z = 0.
%   Z = X xor Y /\ Y = Z => X = 0.
%   Z = X xor Y /\ Z = X => Y = 0.
%   Z = X xor Y /\ Z = 0 => X = Y.
%   Z = X xor Y /\ X = 0 => Y = Z.
%   Z = X xor Y /\ Y = 0 => Z = X.

% Update to X
propagate_ixor0x(MState, X, Y, Z) -->
    (   { var(X), var(Y), var(Z) }
    ->  (   { Y == Z }
        ->  { kill(MState) },
            queue_pgoal(X = 0)
        ;   []
        )
    ;   []
    ).

propagate_ixor0(MState, X, Y, Z) -->
    propagate_ixor0x(MState, X, Y, Z),
    propagate_ixor0x(MState, Y, Z, X),
    propagate_ixor0x(MState, Z, X, Y).

% No update to X
propagate_ixor1_x(MState, X, Y, Z) -->
    (   { X == 0 }
    ->  { kill(MState) },
        queue_pgoal(Y = Z)
    ;   { Y == Z }
    ->  { kill(MState), X = 0 }
    ;   []
    ).

propagate_ixor1(MState, X, Y, Z) -->
    (   { nonvar(X), var(Y), var(Z) }
    ->  propagate_ixor1_x(MState, X, Y, Z)
    ;   { var(X), nonvar(Y), var(Z) }
    ->  propagate_ixor1_x(MState, Y, Z, X)
    ;   { var(X), var(Y), nonvar(Z) }
    ->  propagate_ixor1_x(MState, Z, X, Y)
    ;   []
    ).

propagate_ixor2(MState, X, Y, Z) -->
    (   { var(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_xor(X0, Y, Z) },
        queue_pgoal(X = X0)
    ;   { nonvar(X), var(Y), nonvar(Z) }
    ->  { kill(MState), integer_xor(X, Y0, Z) },
        queue_pgoal(Y = Y0)
    ;   { nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState), integer_xor(X, Y, Z0) },
        queue_pgoal(Z = Z0)
    ;   []
    ).

propagate_ixor3(MState, X, Y, Z) -->
    (   { nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState), integer_xor(Y, X, Z) }
    ;   []
    ).

propagate_ixor(MState, X, Y, Z) -->
    propagate_ixor0(MState, X, Y, Z),
    propagate_ixor1(MState, X, Y, Z),
    propagate_ixor2(MState, X, Y, Z),
    propagate_ixor3(MState, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   lsb(X) = Y => X = 2^Y*(2*K+1) /\ K >= 0.
%   lsb(X) = Y /\ X = Y => false.

propagate_ilsb1(MState, X, Y) -->
    (   { var(X), nonvar(Y) }
    ->  []
    ;   { nonvar(X), var(Y) }
    ->  { kill(MState), integer_lsb(X, Y0) },
        queue_pgoal(Y = Y0)
    ;   []
    ).

propagate_ilsb2(MState, X, Y) -->
    (   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), integer_lsb(X, Y) }
    ;   []
    ).

propagate_ilsb(MState, X, Y) -->
    % propagate_ilsb0(MState, X, Y),
    propagate_ilsb1(MState, X, Y),
    propagate_ilsb2(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   msb(X) = Y => 2^Y =< X < 2^(Y+1).
%   msb(X) = Y => X > 0 /\ Y >= 0.
%   msb(X) = Y /\ X = Y => false.
%   msb(X) = Y /\ X > 1 => Y > 0.

'@propagate_imsb0'(>, YD, YD).
'@propagate_imsb0'(=, YD, YD).
'@propagate_imsb0'(<, YD0, YD) :-
    domain_remove_less_than(1, YD0, YD).

propagate_imsb0(_, X, Y) -->
    (   { var(X), var(Y) }
    ->  {   X \== Y,
            fd_get(X, XD, _),
            domain_infimum(XD, XL),
            fd_get(Y, YD0, YPs),
            cis_compare(O, n(1), XL),
            '@propagate_imsb0'(O, YD0, YD)
            % if_(cis_lt(n(1), XL),
            %     domain_remove_less_than(0, YD0, YD),
            %     YD = YD0
            % )
        },
        fd_put(Y, YD, YPs)
    ;   []
    ).

propagate_imsb1(MState, X, Y) -->
    (   { var(X), nonvar(Y) }
    ->  {   kill(MState),
            integer_compare(<, -1, Y),
            fd_get(X, XD0, XPs),
            integer_shl(Y, 1, L),
            integer_add(1, Y, Z),
            integer_shl(Z, 1, U0),
            integer_add(1, U, U0),
            domain_from_bounds(n(L), n(U), D),
            domain_inter(D, XD0, XD)
        },
        fd_put(X, XD, XPs)
    ;   { nonvar(X), var(Y) }
    ->  { kill(MState), integer_msb(X, Y0) },
        queue_pgoal(Y = Y0)
    ;   []
    ).

propagate_imsb2(MState, X, Y) -->
    (   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), integer_msb(X, Y) }
    ;   []
    ).

propagate_imsb(MState, X, Y) -->
    propagate_imsb0(MState, X, Y),
    propagate_imsb1(MState, X, Y),
    propagate_imsb2(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   popcount(X) = Y => X >= 0 /\ Y >= 0.
%   popcount(X) = Y => Y =< msb(X+1).
%   popcount(X) = Y /\ X = Y => X = 0.
%   popcount(X) = Y /\ X > 0 => Y > 0.

'@propagate_ict10_inf'(=, YD, YD).
'@propagate_ict10_inf'(<, YD0, YD) :-
    domain_remove(0, YD0, YD).

'@propagate_ict10_sup'(n(XU), YD0, YD) :-
    integer_add(1, XU, U0),
    integer_msb(U0, U),
    domain_remove_greater_than(U, YD0, YD).
'@propagate_ict10_sup'(sup, YD, YD).

propagate_ict10(MState, X, Y) -->
    (   { var(X), var(Y) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(X = 0)
        ;   {   fd_get(X, XD, _),
                fd_get(Y, YD0, YPs),
                domain_infimum(XD, XL),
                cis_compare(O, n(0), XL),
                '@propagate_ict10_inf'(O, YD0, YD1),
                domain_supremum(XD, XU),
                '@propagate_ict10_sup'(XU, YD1, YD)
                % if_(bound_finite(XU),
                %     '@propagate_ict10'(XU, YD0, YD),
                %     YD = YD0
                % )
            },
            fd_put(Y, YD, YPs)
        )
    ;   []
    ).

% Update to X
propagate_ict11_x(=, MState, X, 0) --> { kill(MState) }, queue_pgoal(X = 0).
propagate_ict11_x(<, _, X, _) -->
    {   fd_get(X, XD0, XPs),
        domain_remove(0, XD0, XD)
    },
    fd_put(X, XD, XPs).

propagate_ict11(MState, X, Y) -->
    (   { var(X), nonvar(Y) }
    ->  { integer_compare(O, 0, Y) },
        propagate_ict11_x(O, MState, X, Y)
    ;   { nonvar(X), var(Y) }
    ->  { kill(MState), integer_ct1(X, Y0) },
        queue_pgoal(Y = Y0)
    ;   []
    ).

propagate_ict12(MState, X, Y) -->
    (   { nonvar(X), nonvar(Y) }
    ->  { kill(MState), integer_ct1(X, Y) }
    ;   []
    ).

propagate_ict1(MState, X, Y) -->
    propagate_ict10(MState, X, Y),
    propagate_ict11(MState, X, Y),
    propagate_ict12(MState, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   V in D #<==> #B.

'@propagate_bin0_intersects'(false, MState, _, _, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_bin0_intersects'( true, _, _, _, _) --> [].

'@propagate_bin0_includes'(false, MState, D, V, B) -->
    { fd_get(V, VD, _), domain_intersects(D, VD, Truth) },
    '@propagate_bin0_intersects'(Truth, MState, D, V, B).
'@propagate_bin0_includes'( true, MState, _, _, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).

propagate_bin0(MState, D, V, B) -->
    (   { var(V), var(B) }
    ->  { fd_get(V, VD, _), domain_includes(D, VD, Truth) },
        '@propagate_bin0_includes'(Truth, MState, D, V, B)
    % ->  {   fd_get(V, VD, _),
    %         if_(domain_includes(D, VD),
    %             (kill(MState), G = (B = 1)),
    %             if_(domain_intersects(D, VD),
    %                 G = true,
    %                 (kill(MState), G = (B = 0))
    %             )
    %         )
    %     },
    %     queue_pgoal(G)
    ;   []
    ).

propagate_bin1(MState, D, V, B) -->
    (   { var(V), nonvar(B) }
    ->  {   kill(MState),
            integer_if(B, VD1 = D, domain_complement(D, VD1)),
            fd_get(V, VD0, VPs),
            domain_inter(VD1, VD0, VD)
        },
        fd_put(V, VD, VPs)
    ;   { nonvar(V), var(B) }
    ->  { kill(MState), if_(domain_contains(D, V), B0 = 1, B0 = 0) },
        queue_pgoal(B = B0)
    ;   []
    ).

propagate_bin2(MState, D, V, B) -->
    (   { nonvar(V), nonvar(B) }
    ->  { kill(MState), if_(domain_contains(D, V), B = 1, B = 0) }
    ;   []
    ).

propagate_bin(MState, D, V, B) -->
    propagate_bin0(MState, D, V, B),
    propagate_bin1(MState, D, V, B),
    propagate_bin2(MState, D, V, B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #B0 #/\ #B1 #<==> #B.

propagate_band0(MState, B0, _, B1, _, B) -->
    (   { var(B0), var(B1), var(B) }
    ->  (   { B0 == B1 }
        ->  { kill(MState) },
            queue_pgoal(B = B0)
        ;   []
        )
    ;   []
    ).

% No update to X
propagate_band1_x(0, _, _, Ps1, B) -->
    { list_map(kill_entailed, Ps1) },
    queue_pgoal(B = 0).
propagate_band1_x(1, _, B1, _, B) -->
    queue_pgoal(B = B1).

% No update to Z
propagate_band1_z(MState, B0, _, B1, _, 0) -->
    (   { B0 == B1 }
    ->  { kill(MState) },
        queue_pgoal(B0 = 0)
    ;   []
    ).
propagate_band1_z(MState, B0, _, B1, _, 1) -->
    { kill(MState) },
    queue_pgoal(B0-B1 = 1-1).

propagate_band1(MState, B0, Ps0, B1, Ps1, B) -->
    (   { nonvar(B0), var(B1), var(B) }
    ->  { kill(MState) },
        propagate_band1_x(B0, Ps0, B1, Ps1, B)
    ;   { var(B0), nonvar(B1), var(B) }
    ->  { kill(MState) },
        propagate_band1_x(B1, Ps1, B0, Ps0, B)
    ;   { var(B0), var(B1), nonvar(B) }
    ->  propagate_band1_z(MState, B0, Ps0, B1, Ps1, B)
    ;   []
    ).

% Update to X
propagate_band2_x(_, Ps0, 0, _, 0) -->
    { list_map(kill_entailed, Ps0) }.
propagate_band2_x(B0, _, 1, _, B) -->
    queue_pgoal(B = B0).

propagate_band2(MState, B0, Ps0, B1, Ps1, B) -->
    (   { var(B0), nonvar(B1), nonvar(B) }
    ->  { kill(MState) },
        propagate_band2_x(B0, Ps0, B1, Ps1, B)
    ;   { nonvar(B0), var(B1), nonvar(B) }
    ->  { kill(MState) },
        propagate_band2_x(B1, Ps1, B0, Ps0, B)
    ;   { nonvar(B0), nonvar(B1), var(B) }
    ->  {   kill(MState),
            integer_and(B0, B1, B2)
        },
        queue_pgoal(B = B2)
    ;   []
    ).

propagate_band3(MState, B0, _, B1, _, B) -->
    (   { nonvar(B0), nonvar(B1), nonvar(B) }
    ->  { kill(MState), integer_and(B0, B1, B) }
    ;   []
    ).

propagate_band(MState, B0, Ps0, B1, Ps1, B) -->
    propagate_band0(MState, B0, Ps0, B1, Ps1, B),
    propagate_band1(MState, B0, Ps0, B1, Ps1, B),
    propagate_band2(MState, B0, Ps0, B1, Ps1, B),
    propagate_band3(MState, B0, Ps0, B1, Ps1, B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #B0 #\/ #B1 #<==> #B.

propagate_bior0(MState, B0, _, B1, _, B) -->
    (   { var(B0), var(B1), var(B) }
    ->  (   { B0 == B1 }
        ->  { kill(MState) },
            queue_pgoal(B = B0)
        ;   []
        )
    ;   []
    ).

% No update to X
propagate_bior1_x(0, _, B1, _, B) -->
    queue_pgoal(B = B1).
propagate_bior1_x(1, _, _, Ps1, B) -->
    { list_map(kill_entailed, Ps1) },
    queue_pgoal(B = 1).

% No update to Z
propagate_bior1_z(MState, B0, _, B1, _, 0) -->
    { kill(MState) },
    queue_pgoal(B0-B1 = 0-0).
propagate_bior1_z(MState, B0, _, B1, _, 1) -->
    (   { B0 == B1 }
    ->  { kill(MState) },
        queue_pgoal(B0 = 1)
    ;   []
    ).

propagate_bior1(MState, B0, Ps0, B1, Ps1, B) -->
    (   { nonvar(B0), var(B1), var(B) }
    ->  { kill(MState) },
        propagate_bior1_x(B0, Ps0, B1, Ps1, B)
    ;   { var(B0), nonvar(B1), var(B) }
    ->  { kill(MState) },
        propagate_bior1_x(B1, Ps1, B0, Ps0, B)
    ;   { var(B0), var(B1), nonvar(B) }
    ->  propagate_bior1_z(MState, B0, Ps0, B1, Ps1, B)
    ;   []
    ).

% Update to X
propagate_bior2_x(B0, _, 0, _, B) -->
    queue_pgoal(B = B0).
propagate_bior2_x(_, Ps0, 1, _, 1) -->
    { list_map(kill_entailed, Ps0) }.

propagate_bior2(MState, B0, Ps0, B1, Ps1, B) -->
    (   { var(B0), nonvar(B1), nonvar(B) }
    ->  { kill(MState) },
        propagate_bior2_x(B0, Ps0, B1, Ps1, B)
    ;   { nonvar(B0), var(B1), nonvar(B) }
    ->  { kill(MState) },
        propagate_bior2_x(B1, Ps1, B0, Ps0, B)
    ;   { nonvar(B0), nonvar(B1), var(B) }
    ->  { kill(MState), integer_ior(B0, B1, B2) },
        queue_pgoal(B = B2)
    ;   []
    ).

propagate_bior3(MState, B0, _, B1, _, B) -->
    (   { nonvar(B0), nonvar(B1), nonvar(B) }
    ->  { kill(MState), integer_ior(B0, B1, B) }
    ;   []
    ).

propagate_bior(MState, B0, Ps0, B1, Ps1, B) -->
    propagate_bior0(MState, B0, Ps0, B1, Ps1, B),
    propagate_bior1(MState, B0, Ps0, B1, Ps1, B),
    propagate_bior2(MState, B0, Ps0, B1, Ps1, B),
    propagate_bior3(MState, B0, Ps0, B1, Ps1, B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #\ #B0 #<==> #B <=> #B0 + #B #= #1.

propagate_bnot1(MState, B0, B) -->
    (   { var(B0), nonvar(B) }
    ->  { kill(MState), integer_xor(1, B1, B) },
        queue_pgoal(B0 = B1)
    ;   { nonvar(B0), var(B) }
    ->  { kill(MState), integer_xor(1, B0, B1) },
        queue_pgoal(B = B1)
    ;   []
    ).

propagate_bnot2(MState, B0, B) -->
    (   { nonvar(B0), nonvar(B) }
    ->  { kill(MState), integer_xor(1, B0, B) }
    ;   []
    ).

propagate_bnot(MState, B0, B) -->
    % % propagate_bnot0(MState, B0, B),
    % propagate_bnot1(MState, B0, B),
    % propagate_bnot2(MState, B0, B).
    % { kill(MState) },
    % queue_pgoal(#B0 + #B #= #1).
    (   { var(B0), var(B) }
    ->  { B0 \== B }
    ;   { var(B0), nonvar(B) }
    ->  { kill(MState), integer_xor(1, B1, B) },
        queue_pgoal(B0 = B1)
    ;   { nonvar(B0), var(B) }
    ->  { kill(MState), integer_xor(1, B0, B1) },
        queue_pgoal(B = B1)
    ;   { nonvar(B0), nonvar(B) }
    ->  { kill(MState), integer_xor(1, B0, B) }
    ;   { false }
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   (#B0 #==> #B1) #<==> #B.

propagate_bimp1_x(MState, 0, _, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).
propagate_bimp1_x(MState, 1, B1, B) -->
    { kill(MState) },
    queue_pgoal(B = B1).

propagate_bimp1_y(MState, B0, 0, B) -->
    { B0 \== B, kill(MState) },
    queue_pgoal(#\ #B0 #<==> #B).
propagate_bimp1_y(MState, _, 1, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).

propagate_bimp1_z(MState, B0, B1, 0) -->
    { kill(MState) },
    queue_pgoal(B0-B1 = 1-0).
propagate_bimp1_z(MState, B0, B1, 1) -->
    (   { B0 == B1 }
    ->  { kill(MState) }
    ;   []
    ).

propagate_bimp1(MState, B0, B1, B) -->
    (   { nonvar(B0), var(B1), var(B) }
    ->  propagate_bimp_x(MState, B0, B1, B)
    ;   { var(B0), nonvar(B1), var(B) }
    ->  propagate_bimp_y(MState, B0, B1, B)
    ;   { var(B0), var(B1), nonvar(B) }
    ->  propagate_bimp_z(MState, B0, B1, B)
    ;   []
    ).

propagate_bimp2_x(B, 0, 0) --> queue_pgoal(B = 1).
% propagate_bimp2_x(B0, 1, 0) --> { false }.
propagate_bimp2_x(B, 0, 1) --> queue_pgoal(B = 0).
propagate_bimp2_x(_, 1, 1) --> [].

propagate_bimp2_y(0, _, 0) --> [].
propagate_bimp2_y(1, B, 0) --> queue_pgoal(B = 0).
propagate_bimp2_y(0, _, 1) --> [].
propagate_bimp2_y(1, B, 1) --> queue_pgoal(B = 1).

% propagate_bimp2_z(0, 0, B) --> queue_pgoal(B = 1).
% propagate_bimp2_z(0, 1, B) --> queue_pgoal(B = 1).
% propagate_bimp2_z(1, 0, B) --> queue_pgoal(B = 0).
% propagate_bimp2_z(1, 1, B) --> queue_pgoal(B = 1).

propagate_bimp2(MState, B0, B1, B) -->
    (   { var(B0), nonvar(B1), nonvar(B) }
    ->  { kill(MState) },
        propagate_bimp2_x(B0, B1, B)
    ;   { nonvar(B0), var(B1), nonvar(B) }
    ->  { kill(MState) },
        propagate_bimp2_y(B0, B1, B)
    ;   { nonvar(B0), nonvar(B1), var(B) }
    ->  { kill(MState), propagate_bimp3_(B0, B1, B2) },
        queue_pgoal(B = B2)
    ;   []
    ).

propagate_bimp3_(0, 0, 1).
propagate_bimp3_(0, 1, 1).
propagate_bimp3_(1, 0, 0).
propagate_bimp3_(1, 1, 1).

propagate_bimp3(MState, B0, B1, B) -->
    (   { nonvar(B0), nonvar(B1), nonvar(B) }
    ->  { kill(MState), propagate_bimp3_(B0, B1, B) }
    ;   []
    ).

propagate_bimp(MState, B0, B1, B) -->
    % propagate_bimp0(MState, B0, B1, B),
    % propagate_bimp1(MState, B0, B1, B),
    % propagate_bimp2(MState, B0, B1, B),
    propagate_bimp3(MState, B0, B1, B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #B0 #<==> (#B1 #<==> #B2) <=> (#B0 #<==> #B1) #<==> #B2.

propagate_beqv0_(MState, B0, B1, B2) -->
    (   { var(B0), var(B1), var(B2) }
    ->  (   { B1 == B2 }
        ->  { kill(MState) },
            queue_pgoal(B0 = 1)
        ;   []
        )
    ;   []
    ).

propagate_beqv0(MState, B0, B1, B2) -->
    propagate_beqv0_(MState, B0, B1, B2),
    propagate_beqv0_(MState, B1, B2, B0),
    propagate_beqv0_(MState, B2, B0, B1).

propagate_beqv1_(     _, 0, B0, B1) -->
    { B0 \== B1 }.
propagate_beqv1_(MState, 1, B0, B1) -->
    { kill(MState) },
    queue_pgoal(B0 = B1).
    % (   { B0 == B1 }
    % ->  { kill(MState) }
    % % ;   []
    % ;   { kill(MState) },
    %     queue_pgoal(B0 = B1)
    % ).

propagate_beqv1(MState, B0, B1, B2) -->
    (   { nonvar(B0), var(B1), var(B2) }
    ->  propagate_beqv1_(MState, B0, B1, B2)
    ;   { var(B0), nonvar(B1), var(B2) }
    ->  propagate_beqv1_(MState, B1, B2, B0)
    ;   { var(B0), var(B1), nonvar(B2) }
    ->  propagate_beqv1_(MState, B2, B0, B1)
    ;   []
    ).

propagate_beqv2_(0, 0, B) --> queue_pgoal(B = 1).
propagate_beqv2_(0, 1, B) --> queue_pgoal(B = 0).
propagate_beqv2_(1, 0, B) --> queue_pgoal(B = 0).
propagate_beqv2_(1, 1, B) --> queue_pgoal(B = 1).
% propagate_beqv2_(B0, B1, B) -->
%     { integer_xor(B0, B1, B2), integer_xor(1, B2, B3) },
%     queue_pgoal(B = B3).

propagate_beqv2(MState, B0, B1, B2) -->
    (   { var(B0), nonvar(B1), nonvar(B2) }
    ->  { kill(MState) }, propagate_beqv2_(B1, B2, B0)
    ;   { nonvar(B0), var(B1), nonvar(B2) }
    ->  { kill(MState) }, propagate_beqv2_(B2, B0, B1)
    ;   { nonvar(B0), nonvar(B1), var(B2) }
    ->  { kill(MState) }, propagate_beqv2_(B0, B1, B2)
    ;   []
    ).

propagate_beqv3(MState, B0, B1, B2) -->
    (   { nonvar(B0), nonvar(B1), nonvar(B2) }
    ->  { kill(MState), integer_xor(B0, B1, B), integer_xor(1, B2, B) }
    ;   []
    ).

propagate_beqv(MState, B0, B1, B2) -->
    propagate_beqv0(MState, B0, B1, B2),
    propagate_beqv1(MState, B0, B1, B2),
    propagate_beqv2(MState, B0, B1, B2),
    propagate_beqv3(MState, B0, B1, B2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #B #<==> #X #= #Y <=> #B #<==> #Y #= #X.

'@propagate_beq0'(false, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_beq0'( true, _MState, _) --> [].

propagate_beq0(MState, B, X, Y) -->
    (   { var(B), var(X), var(Y) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(B = 1)
        ;   {   fd_get(X, XD, _),
                fd_get(Y, YD, _),
                domain_intersects(XD, YD, Truth)
            },
            '@propagate_beq0'(Truth, MState, B)
        % ;   {   fd_get(X, XD, _),
        %         fd_get(Y, YD, _),
        %         if_(domain_intersects(XD, YD), G = true, (kill(MState), G = (B = 0)))
        %     },
        %     queue_pgoal(G)
        )
    ;   []
    ).

propagate_beq1_b(MState, 0, X, Y) -->
    % {   X \== Y,
    %     fd_get(X, XD, _), fd_get(Y, YD, _),
    %     if_(domain_intersects(XD, YD), true, kill(MState))
    % }.
    { X \== Y, kill(MState) },
    queue_pgoal(#X #\= #Y).
propagate_beq1_b(MState, 1, X, Y) -->
    { kill(MState) },
    queue_pgoal(X = Y).

'@propagate_beq1_x'(false, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_beq1_x'( true, _MState, _) --> [].

% No update to X
propagate_beq1_x(MState, B, X, Y) -->
    {   fd_get(Y, YD, _),
        domain_contains(YD, X, Truth)
    },
    '@propagate_beq1_x'(Truth, MState, B).
    % {   fd_get(Y, YD, _),
    %     if_(domain_contains(YD, X), G = true, (kill(MState), G = (B = 0)))
    % },
    % queue_pgoal(G).

propagate_beq1(MState, B, X, Y) -->
    (   { nonvar(B), var(X), var(Y) }
    ->  propagate_beq1_b(MState, B, X, Y)
    ;   { var(B), nonvar(X), var(Y) }
    ->  propagate_beq1_x(MState, B, X, Y)
    ;   { var(B), var(X), nonvar(Y) }
    ->  propagate_beq1_x(MState, B, Y, X)
    ;   []
    ).

% Update to X
propagate_beq2_x(0, X, Y) -->
    {   fd_get(X, XD0, XPs),
        domain_remove(Y, XD0, XD)
    },
    fd_put(X, XD, XPs).
propagate_beq2_x(1, X, Y) -->
    queue_pgoal(X = Y).

propagate_beq2(MState, B, X, Y) -->
    (   { var(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), if_(integer_eq(X, Y), B0 = 1, B0 = 0) },
        queue_pgoal(B = B0)
    ;   { nonvar(B), var(X), nonvar(Y) }
    ->  { kill(MState) },
        propagate_beq2_x(B, X, Y)
    ;   { nonvar(B), nonvar(X), var(Y) }
    ->  { kill(MState) },
        propagate_beq2_x(B, Y, X)
    ;   []
    ).

propagate_beq3(MState, B, X, Y) -->
    (   { nonvar(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), if_(integer_eq(X, Y), B = 1, B = 0) }
    ;   []
    ).

propagate_beq(MState, B, X, Y) -->
    propagate_beq0(MState, B, X, Y),
    propagate_beq1(MState, B, X, Y),
    propagate_beq2(MState, B, X, Y),
    propagate_beq3(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #B #<==> #X #\= #Y <=> #B #<==> #Y #\= #X.

'@propagate_bne0'(false, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).
'@propagate_bne0'( true, _MState, _) --> [].

propagate_bne0(MState, B, X, Y) -->
    (   { var(B), var(X), var(Y) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(B = 0)
        % Interesting but more research is needed.
        % ;   {   fd_get(X, _, XPs),
        %         list_element([pneq(X,Y),pneq(Y,X)], C),
        %         propagators_constraint(XPs, C0), C0 == C
        %     }
        % ->  { kill(MState) },
        %     queue_pgoal(B = 1)
        ;   {   fd_get(X, XD, _),
                fd_get(Y, YD, _),
                domain_intersects(XD, YD, Truth)
            },
            '@propagate_bne0'(Truth, MState, B)
        % ;   {   fd_get(X, XD, _),
        %         fd_get(Y, YD, _),
        %         if_(domain_intersects(XD, YD), G = true, (kill(MState), G = (B = 1)))
        %     },
        %     queue_pgoal(G)
        )
    ;   []
    ).

propagate_bne1_b(MState, 0, X, Y) -->
    { kill(MState) },
    queue_pgoal(X = Y).
propagate_bne1_b(MState, 1, X, Y) -->
    % {   X \== Y,
    %     fd_get(X, XD, _), fd_get(Y, YD, _),
    %     if_(domain_intersects(XD, YD), true, kill(MState))
    % }.
    { X \== Y, kill(MState) },
    queue_pgoal(#X #\= #Y).

'@propagate_bne1_x'(false, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).
'@propagate_bne1_x'( true, _MState, _) --> [].

% No update to X
propagate_bne1_x(MState, B, X, Y) -->
    {   fd_get(Y, YD, _),
        domain_contains(YD, X, Truth)
    },
    '@propagate_bne1_x'(Truth, MState, B).
    % {   fd_get(Y, YD, _),
    %     if_(domain_contains(YD, X), G = true, (kill(MState), G = (B = 1)))
    % },
    % queue_pgoal(G).

propagate_bne1(MState, B, X, Y) -->
    (   { nonvar(B), var(X), var(Y) }
    ->  propagate_bne1_b(MState, B, X, Y)
    ;   { var(B), nonvar(X), var(Y) }
    ->  propagate_bne1_x(MState, B, X, Y)
    ;   { var(B), var(X), nonvar(Y) }
    ->  propagate_bne1_x(MState, B, Y, X)
    ;   []
    ).

% Update to X
propagate_bne2_x(0, X, Y) -->
    queue_pgoal(X = Y).
propagate_bne2_x(1, X, Y) -->
    {   fd_get(X, XD0, XPs),
        domain_remove(Y, XD0, XD)
    },
    fd_put(X, XD, XPs).

propagate_bne2(MState, B, X, Y) -->
    (   { var(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), if_(integer_ne(X, Y), B0 = 1, B0 = 0) },
        queue_pgoal(B = B0)
    ;   { nonvar(B), var(X), nonvar(Y) }
    ->  { kill(MState) },
        propagate_bne2_x(B, X, Y)
    ;   { nonvar(B), nonvar(X), var(Y) }
    ->  { kill(MState) },
        propagate_bne2_x(B, Y, X)
    ;   []
    ).

propagate_bne3(MState, B, X, Y) -->
    (   { nonvar(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), if_(integer_ne(X, Y), B = 1, B = 0) }
    ;   []
    ).

propagate_bne(MState, B, X, Y) -->
    propagate_bne0(MState, B, X, Y),
    propagate_bne1(MState, B, X, Y),
    propagate_bne2(MState, B, X, Y),
    propagate_bne3(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #B #<==> #X #=< #Y.
%   #B #<==> #X #=< #Y <=> #\ #B #<==> #X #> #Y.

'@propagate_ble0_0'(>, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_ble0_0'(=, _, _) --> [].
'@propagate_ble0_0'(<, _, _) --> [].

'@propagate_ble0_1'(>, _, _) --> [].
'@propagate_ble0_1'(=, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).
'@propagate_ble0_1'(<, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).

propagate_ble0(MState, B, X, Y) -->
    (   { var(B), var(X), var(Y) }
    ->  { fd_get(X, XD, _), fd_get(Y, YD, _) },
        (   { var(B), var(X), var(Y) }
        ->  {   domain_infimum(XD, XL),
                domain_supremum(YD, YU),
                cis_compare(O_0, XL, YU)
            },
            '@propagate_ble0_0'(O_0, MState, B)
        ;   []
        ),
        (   { var(B), var(X), var(Y) }
        ->  {   domain_supremum(XD, XU),
                domain_infimum(YD, YL),
                cis_compare(O_1, XU, YL)
            },
            '@propagate_ble0_1'(O_1, MState, B)
        ;   []
        )
    ;   []
    ).

'@propagate_ble1_0x'(>, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_ble1_0x'(=, _, _) --> [].
'@propagate_ble1_0x'(<, _, _) --> [].

'@propagate_ble1_1x'(>, _, _) --> [].
'@propagate_ble1_1x'(=, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).
'@propagate_ble1_1x'(<, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).

% No update to X
propagate_ble1_x(MState, B, X, Y) -->
    { fd_get(Y, YD, _) },
    (   { var(B), var(Y) }
    ->  {   domain_supremum(YD, YU),
            cis_compare(O_0, n(X), YU)
        },
        '@propagate_ble1_0x'(O_0, MState, B)
    ;   []
    ),
    (   { var(B), var(Y) }
    ->  {   domain_infimum(YD, YL),
            cis_compare(O_1, n(X), YL)
        },
        '@propagate_ble1_1x'(O_1, MState, B)
    ;   []
    ).

'@propagate_ble1_0y'(>, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_ble1_0y'(=, _, _) --> [].
'@propagate_ble1_0y'(<, _, _) --> [].

'@propagate_ble1_1y'(>, _, _) --> [].
'@propagate_ble1_1y'(=, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).
'@propagate_ble1_1y'(<, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).

% No update to Y
propagate_ble1_y(MState, B, X, Y) -->
    { fd_get(X, XD, _) },
    (   { var(B), var(X) }
    ->  {   domain_infimum(XD, XL),
            cis_compare(O_0, XL, n(Y))
        },
        '@propagate_ble1_0y'(O_0, MState, B)
    ;   []
    ),
    (   { var(B), var(X) }
    ->  {   domain_supremum(XD, XU),
            cis_compare(O_1, XU, n(Y))
        },
        '@propagate_ble1_1y'(O_1, MState, B)
    ;   []
    ).

propagate_ble1_b(0, X, Y) -->
    queue_pgoal(#X #> #Y).
propagate_ble1_b(1, X, Y) -->
    queue_pgoal(#X #=< #Y).

propagate_ble1(MState, B, X, Y) -->
    (   { nonvar(B), var(X), var(Y) }
    ->  { kill(MState) },
        propagate_ble1_b(B, X, Y)
    ;   { var(B), nonvar(X), var(Y) }
    ->  propagate_ble1_x(MState, B, X, Y)
    ;   { var(B), var(X), nonvar(Y) }
    ->  propagate_ble1_y(MState, B, X, Y)
    ;   []
    ).

% Update to X
propagate_ble2_x(0, X, Y) -->
    {   integer_add(1, Y, Y0),
        fd_get(X, XD0, XPs),
        domain_remove_less_than(Y0, XD0, XD)
    },
    fd_put(X, XD, XPs).
propagate_ble2_x(1, X, Y) -->
    {   fd_get(X, XD0, XPs),
        domain_remove_greater_than(Y, XD0, XD)
    },
    fd_put(X, XD, XPs).

% Update to Y
propagate_ble2_y(0, X, Y) -->
    {   integer_add(1, X0, X),
        fd_get(Y, YD0, YPs),
        domain_remove_greater_than(X0, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_ble2_y(1, X, Y) -->
    {   fd_get(Y, YD0, YPs),
        domain_remove_less_than(X, YD0, YD)
    },
    fd_put(Y, YD, YPs).

propagate_ble2(MState, B, X, Y) -->
    (   { var(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), if_(integer_le(X, Y), B0 = 1, B0 = 0) },
        queue_pgoal(B = B0)
    ;   { nonvar(B), var(X), nonvar(Y) }
    ->  { kill(MState) },
        propagate_ble2_x(B, X, Y)
    ;   { nonvar(B), nonvar(X), var(Y) }
    ->  { kill(MState) },
        propagate_ble2_y(B, X, Y)
    ;   []
    ).

propagate_ble3(MState, B, X, Y) -->
    (   { nonvar(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), if_(integer_le(X, Y), B = 1, B = 0) }
    ;   []
    ).

propagate_ble(MState, B, X, Y) -->
    propagate_ble0(MState, B, X, Y),
    propagate_ble1(MState, B, X, Y),
    propagate_ble2(MState, B, X, Y),
    propagate_ble3(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #B #<==> #X #< #Y.
%   #B #<==> #X #< #Y <=> #\ #B #<==> #X #>= #Y.

'@propagate_blt0_0'(>, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_blt0_0'(=, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_blt0_0'(<, _, _) --> [].

'@propagate_blt0_1'(>, _, _) --> [].
'@propagate_blt0_1'(=, _, _) --> [].
'@propagate_blt0_1'(<, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).

propagate_blt0(MState, B, X, Y) -->
    (   { var(B), var(X), var(Y) }
    ->  { fd_get(X, XD, _), fd_get(Y, YD, _) },
        (   { var(B), var(X), var(Y) }
        ->  {   domain_infimum(XD, XL),
                domain_supremum(YD, YU),
                cis_compare(O_0, XL, YU)
            },
            '@propagate_blt0_0'(O_0, MState, B)
        ;   []
        ),
        (   { var(B), var(X), var(Y) }
        ->  {   domain_supremum(XD, XU),
                domain_infimum(YD, YL),
                cis_compare(O_1, XU, YL)
            },
            '@propagate_blt0_1'(O_1, MState, B)
        ;   []
        )
    ;   []
    ).

'@propagate_blt1_0x'(>, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_blt1_0x'(=, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_blt1_0x'(<, _, _) --> [].

'@propagate_blt1_1x'(>, _, _) --> [].
'@propagate_blt1_1x'(=, _, _) --> [].
'@propagate_blt1_1x'(<, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).

% No update to X
propagate_blt1_x(MState, B, X, Y) -->
    { fd_get(Y, YD, _) },
    (   { var(B), var(Y) }
    ->  {   domain_supremum(YD, YU),
            cis_compare(O_S, n(X), YU)
        },
        '@propagate_blt1_0x'(O_S, MState, B)
    ;   []
    ),
    (   { var(B), var(Y) }
    ->  {   domain_infimum(YD, YL),
            cis_compare(O_I, n(X), YL)
        },
        '@propagate_blt1_1x'(O_I, MState, B)
    ;   []
    ).

'@propagate_blt1_0y'(>, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_blt1_0y'(=, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_blt1_0y'(<, _, _) --> [].

'@propagate_blt1_1y'(>, _, _) --> [].
'@propagate_blt1_1y'(=, _, _) --> [].
'@propagate_blt1_1y'(<, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 1).

% No update to Y
propagate_blt1_y(MState, B, X, Y) -->
    { fd_get(X, XD, _) },
    (   { var(B), var(X) }
    ->  {   domain_infimum(XD, XL),
            cis_compare(O_0, XL, n(Y))
        },
        '@propagate_blt1_0y'(O_0, MState, B)
    ;   []
    ),
    (   { var(B), var(X) }
    ->  {   domain_supremum(XD, XU),
            cis_compare(O_1, XU, n(Y))
        },
        '@propagate_blt1_1y'(O_1, MState, B)
    ;   []
    ).

propagate_blt1_b(0, X, Y) -->
    queue_pgoal(#X #>= #Y).
propagate_blt1_b(1, X, Y) -->
    queue_pgoal(#X #< #Y).

propagate_blt1(MState, B, X, Y) -->
    (   { nonvar(B), var(X), var(Y) }
    ->  { kill(MState) },
        propagate_blt1_b(B, X, Y)
    ;   { var(B), nonvar(X), var(Y) }
    ->  propagate_blt1_x(MState, B, X, Y)
    ;   { var(B), var(X), nonvar(Y) }
    ->  propagate_blt1_y(MState, B, X, Y)
    ;   []
    ).

% Update to X
propagate_blt2_x(0, X, Y) -->
    {   fd_get(X, XD0, XPs),
        domain_remove_less_than(Y, XD0, XD)
    },
    fd_put(X, XD, XPs).
propagate_blt2_x(1, X, Y) -->
    {   integer_add(1, Y0, Y),
        fd_get(X, XD0, XPs),
        domain_remove_greater_than(Y0, XD0, XD)
    },
    fd_put(X, XD, XPs).

% Update to Y
propagate_blt2_y(0, X, Y) -->
    {   fd_get(Y, YD0, YPs),
        domain_remove_greater_than(X, YD0, YD)
    },
    fd_put(Y, YD, YPs).
propagate_blt2_y(1, X, Y) -->
    {   integer_add(1, X, X0),
        fd_get(Y, YD0, YPs),
        domain_remove_less_than(X0, YD0, YD)
    },
    fd_put(Y, YD, YPs).

propagate_blt2(MState, B, X, Y) -->
    (   { var(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), if_(integer_lt(X, Y), B0 = 1, B0 = 0) },
        queue_pgoal(B = B0)
    ;   { nonvar(B), var(X), nonvar(Y) }
    ->  { kill(MState) },
        propagate_blt2_x(B, X, Y)
    ;   { nonvar(B), nonvar(X), var(Y) }
    ->  { kill(MState) },
        propagate_blt2_y(B, X, Y)
    ;   []
    ).

propagate_blt3(MState, B, X, Y) -->
    (   { nonvar(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), if_(integer_lt(X, Y), B = 1, B = 0) }
    ;   []
    ).

propagate_blt(MState, B, X, Y) -->
    propagate_blt0(MState, B, X, Y),
    propagate_blt1(MState, B, X, Y),
    propagate_blt2(MState, B, X, Y),
    propagate_blt3(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #X + #Y #= #Z #<==> #B <=> #X + #Y #\= #Z #<==> #\ #B.

propagate_iadd0_x(MState, B, X, Y, Z) -->
    (   { var(B), var(X), var(Y), var(Z) }
    ->  (   { Y == Z }
        ->  { kill(MState) },
            queue_pgoal(#X #= #0 #<==> #B)
        ;   {   fd_get(X, XD0, _), fd_get(Y, YD0, _), fd_get(Z, ZD0, _),
                domain_infimum(YD0, YL0), domain_supremum(YD0, YU0),
                domain_infimum(ZD0, ZL0), domain_supremum(ZD0, ZU0),
                XL cis ZL0-YU0, XU cis ZU0-YL0,
                domain_from_bounds(XL, XU, XD),
                if_(
                    domain_intersects(XD0, XD),
                    G = true,
                    (kill(MState), G = (B = 0))
                )
            },
            queue_pgoal(G)
        )
    ;   []
    ).

propagate_iadd0_z(MState, B, X, Y, Z) -->
    (   { var(B), var(X), var(Y), var(Z) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(#2 * #X #= #Z #<==> #B)
        ;   {   fd_get(X, XD0, _), fd_get(Y, YD0, _), fd_get(Z, ZD0, _),
                domain_infimum(XD0, XL0), domain_supremum(XD0, XU0),
                domain_infimum(YD0, YL0), domain_supremum(YD0, YU0),
                ZL cis XL0+YL0, ZU cis XU0+YU0,
                domain_from_bounds(ZL, ZU, ZD),
                if_(
                    domain_intersects(ZD0, ZD),
                    G = true,
                    (kill(MState), G = (B = 0))
                )
            },
            queue_pgoal(G)
        )
    ;   []
    ).

propagate_iadd0(MState, B, X, Y, Z) -->
    propagate_iadd0_x(MState, B, X, Y, Z),
    propagate_iadd0_x(MState, B, Y, X, Z),
    propagate_iadd0_z(MState, B, X, Y, Z).

propagate_iadd1_0x(MState, X, Y, Z) -->
    (   { var(X), var(Y), var(Z) }
    ->  (   { Y == Z }
        ->  {   kill(MState),
                fd_get(X, XD0, XPs),
                domain_remove(0, XD0, XD)
            },
            fd_put(X, XD, XPs)
        ;   {   fd_get(X, XD0, _), fd_get(Y, YD0, _), fd_get(Z, ZD0, _),
                domain_infimum(YD0, YL0), domain_supremum(YD0, YU0),
                domain_infimum(ZD0, ZL0), domain_supremum(ZD0, ZU0),
                XL cis ZL0-YU0, XU cis ZU0-YL0,
                domain_from_bounds(XL, XU, XD),
                if_(domain_intersects(XD0, XD), true, kill(MState))
            }
        )
    ;   []
    ).

propagate_iadd1_0z(MState, X, Y, Z) -->
    (   { var(Z), var(X), var(Y) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(#2 * #X #= #Z #<==> #0)
        ;   {   fd_get(X, XD0, _), fd_get(Y, YD0, _), fd_get(Z, ZD0, _),
                domain_infimum(XD0, XL0), domain_supremum(XD0, XU0),
                domain_infimum(YD0, YL0), domain_supremum(YD0, YU0),
                ZL cis XL0+YL0, ZU cis XU0+YU0,
                domain_from_bounds(ZL, ZU, ZD),
                if_(domain_intersects(ZD0, ZD), true, kill(MState))
            }
        )
    ;   []
    ).

% Update to X
propagate_iadd1_1x(MState, X, Y, Z) -->
    (   { var(X), var(Y), var(Z) }
    ->  (   { Y == Z }
        ->  { kill(MState) },
            queue_pgoal(X = 0)
        ;   {   fd_get(X, XD0, XPs),
                fd_get(Z, ZD, _),
                fd_get(Y, YD, _),
                domain_infimum(ZD, ZL),
                domain_supremum(ZD, ZU),
                domain_infimum(YD, YL),
                domain_supremum(YD, YU),
                XL cis ZL-YU, XU cis ZU-YL,
                domain_from_bounds(XL, XU, XD1),
                domain_inter(XD1, XD0, XD)
            },
            fd_put(X, XD, XPs)
        )
    ;   []
    ).

% Update to Z
propagate_iadd1_1z(MState, X, Y, Z) -->
    (   { var(Z), var(X), var(Y) }
    ->  (   { X == Y }
        ->  { kill(MState) },
            queue_pgoal(#2 * #X #= #Z #<==> #1)
        ;   {   fd_get(Z, ZD0, ZPs),
                fd_get(X, XD, _),
                fd_get(Y, YD, _),
                domain_infimum(XD, XL),
                domain_supremum(XD, XU),
                domain_infimum(YD, YL),
                domain_supremum(YD, YU),
                ZL cis XL+YL, ZU cis XU+YU,
                domain_from_bounds(ZL, ZU, ZD1),
                domain_inter(ZD1, ZD0, ZD)
            },
            fd_put(Z, ZD, ZPs)
        )
    ;   []
    ).

propagate_iadd1_b(MState, 0, X, Y, Z) -->
    propagate_iadd1_0x(MState, X, Y, Z),
    propagate_iadd1_0x(MState, Y, X, Z),
    propagate_iadd1_0z(MState, X, Y, Z).
propagate_iadd1_b(MState, 1, X, Y, Z) -->
    propagate_iadd1_1x(MState, X, Y, Z),
    propagate_iadd1_1x(MState, Y, X, Z),
    propagate_iadd1_1z(MState, X, Y, Z).

propagate_iadd1_x(MState, B, X, Y, Z) -->
    (   { X == 0 }
    ->  { kill(MState) },
        queue_pgoal(#Y #= #Z #<==> #B)
    ;   { Y == Z }
    ->  { kill(MState), if_(integer_eq(X, 0), B0 = 1, B0 = 0) },
        queue_pgoal(B = B0)
    ;   []
    ).

propagate_iadd1_z(MState, B, X, Y, Z) -->
    (   { X == Y }
    ->  { kill(MState) },
        queue_pgoal(#2 * #X #= #Z #<==> #B)
    ;   []
    ).

propagate_iadd1(MState, B, X, Y, Z) -->
    (   { nonvar(B), var(X), var(Y), var(Z) }
    ->  propagate_iadd1_b(MState, B, X, Y, Z)
    ;   { var(B), nonvar(X), var(Y), var(Z) }
    ->  propagate_iadd1_x(MState, B, X, Y, Z)
    ;   { var(B), var(X), nonvar(Y), var(Z) }
    ->  propagate_iadd1_x(MState, B, Y, X, Z)
    ;   { var(B), var(X), var(Y), nonvar(Z) }
    ->  propagate_iadd1_z(MState, B, X, Y, Z)
    ;   []
    ).

propagate_iadd2_x(MState, B, X, Y, Z) -->
    {   integer_add(X0, Y, Z),
        fd_get(X, XD, _),
        if_(domain_contains(XD, X0), G = true, (kill(MState), G = (B = 0)))
    },
    queue_pgoal(G).

propagate_iadd2_z(MState, B, X, Y, Z) -->
    {   integer_add(X, Y, Z0),
        fd_get(Z, ZD, _),
        if_(domain_contains(ZD, Z0), G = true, (kill(MState), G = (B = 0)))
    },
    queue_pgoal(G).

% No update to X
propagate_iadd2_bx(MState, 0, X, Y, Z) -->
    (   { Y == Z }
    ->  { kill(MState), integer_ne(X, 0) }
    ;   []
    ).
propagate_iadd2_bx(MState, 1, X, Y, Z) -->
    (   { X == 0 }
    ->  { kill(MState) },
        queue_pgoal(Y = Z)
    ;   { Y == Z }
    ->  { kill(MState), X = 0 }
    ;   (   { var(Z), var(Y) }
        ->  {   SZ = X,
                fd_get(Z, ZD0, ZPs),
                fd_get(Y, YD_, _),
                domain_shift(SZ, YD_, ZD1),
                domain_inter(ZD1, ZD0, ZD)
            },
            fd_put(Z, ZD, ZPs)
        ;   []
        ),
        (   { var(Y), var(Z) }
        ->  {   integer_neg(X, SY),
                fd_get(Y, YD0, YPs),
                fd_get(Z, ZD_, _),
                domain_shift(SY, ZD_, YD1),
                domain_inter(YD1, YD0, YD)
            },
            fd_put(Y, YD, YPs)
        ;   []
        )
    ).

% No update to Z
propagate_iadd2_bz(MState, 0, X, Y, Z) -->
    (   { X == Y }
    ->  { kill(MState) },
        queue_pgoal(#2 * #X #= #Z #<==> #0)
    ;   []
    ).
propagate_iadd2_bz(MState, 1, X, Y, Z) -->
    (   { X == Y }
    ->  { kill(MState) },
        queue_pgoal(#2 * #X #= #Z)
    ;   (   { var(Y), var(X) }
        ->  {   fd_get(Y, YD0, YPs),
                fd_get(X, XD_, _),
                domain_expand(-1, XD_, YD1),
                domain_shift(Z, YD1, YD2),
                domain_inter(YD2, YD0, YD)
            },
            fd_put(Y, YD, YPs)
        ;   []
        ),
        (   { var(X), var(Y) }
        ->  {   fd_get(X, XD0, XPs),
                fd_get(Y, YD_, _),
                domain_expand(-1, YD_, XD1),
                domain_shift(Z, XD1, XD2),
                domain_inter(XD2, XD0, XD)
            },
            fd_put(X, XD, XPs)
        ;   []
        )
    ).

propagate_iadd2(MState, B, X, Y, Z) -->
    (   { var(B), var(X), nonvar(Y), nonvar(Z) }
    ->  propagate_iadd2_x(MState, B, X, Y, Z)
    ;   { var(B), nonvar(X), var(Y), nonvar(Z) }
    ->  propagate_iadd2_x(MState, B, Y, X, Z)
    ;   { var(B), nonvar(X), nonvar(Y), var(Z) }
    ->  propagate_iadd2_z(MState, B, X, Y, Z)
    ;   { nonvar(B), nonvar(X), var(Y), var(Z) }
    ->  propagate_iadd2_bx(MState, B, X, Y, Z)
    ;   { nonvar(B), var(X), nonvar(Y), var(Z) }
    ->  propagate_iadd2_bx(MState, B, Y, X, Z)
    ;   { nonvar(B), var(X), var(Y), nonvar(Z) }
    ->  propagate_iadd2_bz(MState, B, X, Y, Z)
    ;   []
    ).

% Update to X
propagate_iadd3_bx(0, X, Y, Z) -->
    {   integer_add(X0, Y, Z),
        fd_get(X, XD0, XPs),
        domain_remove(X0, XD0, XD)
    },
    fd_put(X, XD, XPs).
propagate_iadd3_bx(1, X, Y, Z) -->
    { integer_add(X0, Y, Z) },
    queue_pgoal(X = X0).

% Update to Z
propagate_iadd3_bz(0, X, Y, Z) -->
    {   integer_add(X, Y, Z0),
        fd_get(Z, ZD0, ZPs),
        domain_remove(Z0, ZD0, ZD)
    },
    fd_put(Z, ZD, ZPs).
propagate_iadd3_bz(1, X, Y, Z) -->
    { integer_add(X, Y, Z0) },
    queue_pgoal(Z = Z0).

propagate_iadd3(MState, B, X, Y, Z) -->
    (   { var(B), nonvar(X), nonvar(Y), nonvar(Z) }
    % ->  { kill(MState), integer_add(X, Y, Z0), if_(Z=Z0, B0 = 1, B0 = 0) },
    ->  {   kill(MState),
            integer_add(X, Y, Z0),
            if_(integer_eq(Z, Z0), B0 = 1, B0 = 0)
            % integer_add(Z1, Z0, Z),
            % integer_abs(Z1, Z2),
            % integer_exp(0, Z2, B0)
        },
        queue_pgoal(B = B0)
    % ->  {   kill(MState),
    %         integer_add(X, Y, Z0),
    %         integer_add(Z1, Z0, Z),
    %         integer_abs(Z1, Z2),
    %         integer_max(1, Z2, Z3),
    %         integer_xor(1, Z3, B0)
    %     },
    %     queue_pgoal(B = B0)
    ;   { nonvar(B), var(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState) },
        propagate_iadd3_bx(B, X, Y, Z)
    ;   { nonvar(B), nonvar(X), var(Y), nonvar(Z) }
    ->  { kill(MState) },
        propagate_iadd3_bx(B, Y, X, Z)
    ;   { nonvar(B), nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState) },
        propagate_iadd3_bz(B, X, Y, Z)
    ;   []
    ).

propagate_iadd4(MState, B, X, Y, Z) -->
    (   { nonvar(B), nonvar(X), nonvar(Y), nonvar(Z) }
    % ->  { kill(MState), integer_add(X, Y, Z0), if_(Z=Z0, B = 1, B = 0) }
    ->  { kill(MState), integer_add(X, Y, Z0), integer_if(B, Z = Z0, Z \= Z0) }
    % ->  {   kill(MState),
    %         integer_add(X, Y, Z0),
    %         integer_add(Z1, Z0, Z),
    %         integer_abs(Z1, Z2),
    %         integer_max(1, Z2, Z3),
    %         integer_xor(1, Z3, B)
    %     }
    ;   []
    ).

propagate_iadd(MState, B, X, Y, Z) -->
    propagate_iadd0(MState, B, X, Y, Z),
    propagate_iadd1(MState, B, X, Y, Z),
    propagate_iadd2(MState, B, X, Y, Z),
    propagate_iadd3(MState, B, X, Y, Z),
    propagate_iadd4(MState, B, X, Y, Z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   X ^ Y = Z <==> B

propagate_bexp_xy(MState, B, X, Y, Z) -->
    (   { var(X), var(Y) }
    ;   { nonvar(X), var(Y) }
    ;   { var(X), nonvar(Y) }
    ;   { nonvar(X), nonvar(Y) }
    ->  {   kill(MState),
            integer_compare(O, 0, Y)
        },
        propagate_bexp_xy(O, B, X, Y, Z)
    ;   []
    ).

% B is an output here and an input in a conjunction elsewhere.
% Z is an output here and an input elsewhere.
propagate_bexp(MState, B, X, Y, Z) -->
    (   { B == 0 }
    ->  { throw(unimplemented(bexp(B,X,Y,Z))) }
    ;   { B == 1 }
    ->  { kill(MState) },
        queue_pgoal(#X ^ #Y #= #Z)
    ;   { var(B) }
    ->  propagate_bexp_xy(MState, B, X, Y, Z)
    ;   { false }
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   #X mod #Y #= #Z #<==> #B.
%   B = 1 <=> #X mod #Y #= #Z
%   B = 0 <=> Y = 0 \/ #X mod #Y #\= #Z

% No update to B
propagate_bmod1_b(_, 0, _, _, _) --> []. % TODO:
propagate_bmod1_b(MState, 1, X, Y, Z) -->
    {   kill(MState),
        fd_get(Y, YD0, YPs),
        domain_remove(0, YD0, YD)
    },
    fd_put(Y, YD, YPs),
    queue_pgoal(#X mod #Y #= #Z).

propagate_bmod1_y(>, MState, B, _, Y, Z) -->
    {   domain_from_bounds(n(Y), n(0), D),
        fd_get(Z, ZD, _),
        if_(domain_intersects(D, ZD), G = true, (kill(MState), G = (B = 0)))
    },
    queue_pgoal(G).
propagate_bmod1_y(=, MState, B, _, 0, _) -->
    { kill(MState) },
    queue_pgoal(B = 0).
propagate_bmod1_y(<, MState, B, _, Y, Z) -->
    {   domain_from_bounds(n(0), n(Y), D),
        fd_get(Z, ZD, _),
        if_(domain_intersects(D, ZD), G = true, (kill(MState), G = (B = 0)))
    },
    queue_pgoal(G).

propagate_bmod1(MState, B, X, Y, Z) -->
    (   { nonvar(B), var(X), var(Y), var(Z) }
    ->  propagate_bmod1_b(MState, B, X, Y, Z)
    ;   { var(B), nonvar(X), var(Y), var(Z) }
    ->  []
    ;   { var(B), var(X), nonvar(Y), var(Z) }
    ->  { integer_compare(O, 0, Y) },
        propagate_bmod1_y(O, MState, B, X, Y, Z)
    ;   { var(B), var(X), var(Y), nonvar(Z) }
    ->  []
    ;   []
    ).

% Update to B
propagate_bmod3_b(B, X, Y, Z) -->
    (   { Y == 0 }
    ->  queue_pgoal(B = 0)
    ;   {   integer_ddqr(floor, X, Y, _, Z0),
            if_(integer_eq(Z0, Z), B0 = 1, B0 = 0)
        },
        queue_pgoal(B = B0)
    ).

% Update to X
propagate_bmod3_x(MState, 0, _, Y, _) -->
    (   { Y == 0 }
    ->  { kill(MState) }
    ;   [] % TODO: Finish this.
    ).
propagate_bmod3_x(1, X, Y, Z) -->
    { integer_compare(O, 0, Y) },
    propagate_imod2_x(O, X, Y, Z).

% Update to Y
propagate_bmod3_y(MState, 0, X, _, Z) -->
    {   if_((   integer_le(0, X), integer_lt(X, Z)
            ;   integer_ge(0, X), integer_gt(X, Z)
            ),
            kill(MState),
            true
        )
    }.
propagate_bmod3_y(MState, 1, X, Y, Z) -->
    { integer_compare(O0, 0, Z), integer_compare(O1, 0, X) },
    propagate_imod2_y(O0, O1, MState, X, Y, Z).

% Update to Z
propagate_bmod3_z(0, X, Y, Z) -->
    (   { Y == 0 }
    ->  []
    ;   {   integer_ddqr(floor, X, Y, _, Z0),
            fd_get(Z, ZD0, ZPs),
            domain_remove(Z0, ZD0, ZD)
        },
        fd_put(Z, ZD, ZPs)
    ).
propagate_bmod3_z(1, X, Y, Z) -->
    {   % call(integer_ne(Y, 0), true),
        integer_ddqr(floor, X, Y, _, Z0)
    },
    queue_pgoal(Z = Z0).

propagate_bmod3(MState, B, X, Y, Z) -->
    (   { var(B), nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState) },
        propagate_bmod3_b(B, X, Y, Z)
    ;   { nonvar(B), var(X), nonvar(Y), nonvar(Z) }
    ->  propagate_bmod3_x(MState, B, X, Y, Z)
    ;   { nonvar(B), nonvar(X), var(Y), nonvar(Z) }
    ->  propagate_bmod3_y(MState, B, X, Y, Z)
    ;   { nonvar(B), nonvar(X), nonvar(Y), var(Z) }
    ->  { kill(MState) },
        propagate_bmod3_z(B, X, Y, Z)
    ;   []
    ).

propagate_bmod4_(0, X, Y, Z) -->
    (   { Y == 0 }
    ->  []
    ;   {   integer_ddqr(floor, X, Y, _, Z0),
            Z0 \== Z
        }
    ).
propagate_bmod4_(1, X, Y, Z) -->
    {   Y \== 0,
        integer_ddqr(floor, X, Y, _, Z)
    }.

propagate_bmod4(MState, B, X, Y, Z) -->
    (   { nonvar(B), nonvar(X), nonvar(Y), nonvar(Z) }
    ->  { kill(MState) },
        propagate_bmod4_(B, X, Y, Z)
    ;   []
    ).

propagate_bmod(MState, B, X, Y, Z) -->
    % propagate_bmod0(MState, B, X, Y, Z),
    propagate_bmod1(MState, B, X, Y, Z),
    % propagate_bmod2(MState, B, X, Y, Z),
    propagate_bmod3(MState, B, X, Y, Z),
    propagate_bmod4(MState, B, X, Y, Z).
    % (   { B == 0 }
    % ->  (   { var(Y) }
    %     ->  {   fd_get(Y, YD, _),
    %             if_(
    %                 domain_contains(YD, 0),
    %                 G = true,
    %                 (kill(MState), G = (#X mod #Y #\= #Z))
    %             )
    %         },
    %         queue_pgoal(G)
    %     ;   { Y == 0 }
    %     ->  { kill(MState) }
    %     ;   queue_pgoal(#X mod #Y #\= #Z)
    %     )
    % ;   { B == 1 }
    % ->  queue_pgoal(#X mod #Y #= #Z)
    % ;   { var(B) },
    %     (   { var(Y) }
    %     ->  []
    %     ;   { Y == 0 }
    %     ->  { kill(MState) },
    %         queue_pgoal(B = 0)
    %     ;   []
    %     )
    % ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   lsb(X) = Y <==> B

'@propagate_blsb3_0'(>, _, _) --> [].
'@propagate_blsb3_0'(=, _, _) --> [].
'@propagate_blsb3_0'(<, X, Y) -->
    { integer_lsb(X, Y0), integer_ne(Y0, Y) }.

propagate_blsb3_(0, X, Y) -->
    % { if_(integer_le(X, 0), true, (integer_lsb(X, Y0), integer_ne(Y0, Y))) }.
    { integer_compare(O, 0, X) },
    '@propagate_blsb3_0'(O, X, Y).
propagate_blsb3_(1, X, Y) -->
    { integer_lsb(X, Y) }.

propagate_blsb3(MState, B, X, Y) -->
    (   { nonvar(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState) },
        propagate_blsb3_(B, X, Y)
    ;   []
    ).

'@propagate_blsb_x_inf'(>, _, _, _, _) --> [].
'@propagate_blsb_x_inf'(=, _, _, _, _) --> [].
'@propagate_blsb_x_inf'(<, MState, B, X, Y) -->
    { kill(MState) },
    queue_pgoal(B = 1),
    queue_pgoal(lsb(#X) #= #Y).

'@propagate_blsb_x_sup'(>, MState, B, _, _) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_blsb_x_sup'(=, MState, B, _, _) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_blsb_x_sup'(<, _, _, _, _) --> [].

'@propagate_blsb_x'(>, B, _, _) -->
    queue_pgoal(B = 0).
'@propagate_blsb_x'(=, B, _, _) -->
    queue_pgoal(B = 0).
'@propagate_blsb_x'(<, B, X, Y) -->
    { integer_lsb(X, Y0) },
    queue_pgoal(B-Y=1-Y0).

% No update to X
propagate_blsb_x(MState, B, X, Y) -->
    (   { var(X) }
    ->  {   fd_get(X, XD, _),
            domain_infimum(XD, XL),
            domain_supremum(XD, XU),
            cis_compare(O_I, n(0), XL),
            cis_compare(O_S, n(0), XU)
        },
        '@propagate_blsb_x_inf'(O_I, MState, B, X, Y),
        '@propagate_blsb_x_sup'(O_S, MState, B, X, Y)
    ;   { kill(MState), integer_compare(O, 0, X) },
        '@propagate_blsb_x'(O, B, X, Y)
    ).

% B is an output here and an input in a conjunction elsewhere.
% Y is an output here and an input elsewhere.
propagate_blsb(MState, B, X, Y) -->
    (   { B == 0 }
    ->  { throw(unimplemented(blsb(B,X,Y))) }
    ;   { B == 1 }
    ->  { kill(MState) },
        queue_pgoal(lsb(#X) #= #Y)
    ;   { var(B) }
    ->  propagate_blsb_x(MState, B, X, Y)
    ;   { false }
    ).
% propagate_blsb(MState, B, X, Y) -->
%     % propagate_blsb0(MState, B, X, Y),
%     % propagate_blsb1(MState, B, X, Y),
%     % propagate_blsb2(MState, B, X, Y),
%     propagate_blsb3(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   msb(X) = Y <==> B

'@propagate_bmsb3_0'(>, _, _) --> [].
'@propagate_bmsb3_0'(=, _, _) --> [].
'@propagate_bmsb3_0'(<, X, Y) -->
    { integer_msb(X, Y0), integer_ne(Y0, Y) }.

propagate_bmsb3_(0, X, Y) -->
    % { if_(integer_le(X, 0), true, (integer_msb(X, Y0), integer_ne(Y0, Y))) }.
    { integer_compare(O, 0, X) },
    '@propagate_bmsb3_0'(O, X, Y).
propagate_bmsb3_(1, X, Y) -->
    { integer_msb(X, Y) }.

propagate_bmsb3(MState, B, X, Y) -->
    (   { nonvar(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState) },
        propagate_bmsb3_(B, X, Y)
    ;   []
    ).

'@propagate_bmsb_x_inf'(>, _, _, _, _) --> [].
'@propagate_bmsb_x_inf'(=, _, _, _, _) --> [].
'@propagate_bmsb_x_inf'(<, MState, B, X, Y) -->
    { kill(MState) },
    queue_pgoal(B = 1),
    queue_pgoal(msb(#X) #= #Y).

'@propagate_bmsb_x_sup'(>, MState, B, _, _) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_bmsb_x_sup'(=, MState, B, _, _) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_bmsb_x_sup'(<, _, _, _, _) --> [].

'@propagate_bmsb_x'(>, B, _, _) -->
    queue_pgoal(B = 0).
'@propagate_bmsb_x'(=, B, _, _) -->
    queue_pgoal(B = 0).
'@propagate_bmsb_x'(<, B, X, Y) -->
    { integer_msb(X, Y0) },
    queue_pgoal(B-Y=1-Y0).

% No update to X
propagate_bmsb_x(MState, B, X, Y) -->
    (   { var(X) }
    ->  {   fd_get(X, XD, _),
            domain_infimum(XD, XL),
            domain_supremum(XD, XU),
            cis_compare(O_I, n(0), XL),
            cis_compare(O_S, n(0), XU)
        },
        '@propagate_bmsb_x_inf'(O_I, MState, B, X, Y),
        '@propagate_bmsb_x_sup'(O_S, MState, B, X, Y)
    ;   { kill(MState), integer_compare(O, 0, X) },
        '@propagate_bmsb_x'(O, B, X, Y)
    ).

% B is an output here and an input in a conjunction elsewhere.
% Y is an output here and an input elsewhere.
propagate_bmsb(MState, B, X, Y) -->
    (   { B == 0 }
    ->  { throw(unimplemented(bmsb(B,X,Y))) }
    ;   { B == 1 }
    ->  { kill(MState) },
        queue_pgoal(msb(#X) #= #Y)
    ;   { var(B) }
    ->  propagate_bmsb_x(MState, B, X, Y)
    ;   { false }
    ).
% propagate_bmsb(MState, B, X, Y) -->
%     % propagate_bmsb0(MState, B, X, Y),
%     % propagate_bmsb1(MState, B, X, Y),
%     % propagate_bmsb2(MState, B, X, Y),
%     propagate_bmsb3(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Properties:
%   popcount(X) = Y <==> B

'@propagate_bct11_0'(>, >, MState, _, _) -->
    { kill(MState) }.
'@propagate_bct11_0'(=, >, MState, _, _) -->
    { kill(MState) }.
'@propagate_bct11_0'(<, >, MState, _, _) -->
    { kill(MState) }.
'@propagate_bct11_0'(>, =, MState, _, _) -->
    { kill(MState) }.
'@propagate_bct11_0'(=, =, _, _, _) --> [].
'@propagate_bct11_0'(<, =, _, _, _) --> [].
'@propagate_bct11_0'(>, <, MState, _, _) -->
    { kill(MState) }.
'@propagate_bct11_0'(=, <, _, _, _) --> [].
'@propagate_bct11_0'(<, <, _, _, _) --> [].

% No update to B
propagate_bct11_b(MState, 0, X, Y) -->
    {   fd_get(X, XD, _),
        fd_get(Y, YD, _),
        domain_supremum(XD, XU),
        domain_supremum(YD, YU),
        cis_compare(O_X, n(0), XU),
        cis_compare(O_Y, n(0), YU)
    },
    '@propagate_bct11_0'(O_X, O_Y, MState, X, Y).
propagate_bct11_b(MState, 1, X, Y) -->
    { kill(MState) },
    queue_pgoal(popcount(#X) #= #Y).

% No update to X
propagate_bct11_x(>, B, _, _) -->
    queue_pgoal(B = 0).
propagate_bct11_x(=, B, 0, Y) -->
    queue_pgoal(#Y #= #0 #<==> #B).
propagate_bct11_x(<, B, X, Y) -->
    { integer_ct1(X, Y0) },
    queue_pgoal(#Y #= #Y0 #<==> #B).

'@propagate_bct11_y'(>, MState, B) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_bct11_y'(=, _, _) --> [].
'@propagate_bct11_y'(<, _, _) --> [].

% No update to Y
propagate_bct11_Y(>, MState, B, _, _) -->
    { kill(MState) },
    queue_pgoal(B = 0).
propagate_bct11_Y(=, MState, B, X, 0) -->
    { kill(MState) },
    queue_pgoal(#X #= #0 #<==> #B).
propagate_bct11_y(<, MState, B, X, _) -->
    { fd_get(X, XD, _), domain_supremum(XD, XU), cis_compare(O, n(0), XU) },
    '@propagate_bct11_y'(O, MState, B).

propagate_bct11(MState, B, X, Y) -->
    (   { nonvar(B), var(X), var(Y) }
    ->  propagate_bct11_b(MState, B, X, Y)
    ;   { var(B), nonvar(X), var(Y) }
    ->  { kill(MState), integer_compare(O, 0, X) },
        propagate_bct11_x(O, B, X, Y)
    ;   { var(B), var(X), nonvar(Y) }
    ->  propagate_bct11_y(MState, B, X, Y)
    ;   []
    ).

% Update to B
propagate_bct12_b(>, B, _, _) -->
    queue_pgoal(B = 0).
propagate_bct12_b(=, B, 0, Y) -->
    { if_(integer_eq(0, Y), B0 = 1, B0 = 0) },
    queue_pgoal(B = B0).
propagate_bct12_b(<, B, X, Y) -->
    { integer_msb(X, Y0), if_(integer_eq(Y0, Y), B0 = 1, B0 = 0) },
    queue_pgoal(B = B0).

'@propagate_bct12_x'(>, MState, _) -->
    { kill(MState) }.
'@propagate_bct12_x'(=, MState, X) -->
    { kill(MState), fd_get(X, XD0, XPs), domain_remove(0, XD0, XD) },
    fd_put(X, XD, XPs).
'@propagate_bct12_x'(<, _) --> [].

% Update to X
propagate_bct12_x(MState, 0, X, Y) -->
    { integer_compare(O_Y, 0, Y) },
    '@propagate_bct12_x'(O_Y, MState, X).
propagate_bct12_x(MState, 1, X, Y) -->
    { kill(MState) },
    queue_pgoal(popcount(#X) #= #Y).

'@propagate_bct12_0y'(>, _, _) --> [].
'@propagate_bct12_0y'(=, 0, Y) -->
    { fd_get(Y, YD0, YPs), domain_remove(0, YD0, YD) },
    fd_put(Y, YD, YPs).
'@propagate_bct12_0y'(<, X, Y) -->
    { integer_ct1(X, Y0), fd_get(Y, YD0, YPs), domain_remove(Y0, YD0, YD) },
    fd_put(Y, YD, YPs).

% Update to Y
propagate_bct12_y(MState, 0, X, Y) -->
    { kill(MState), integer_compare(O, 0, X) },
    '@propagate_bct12_0y'(O, X, Y).
propagate_bct12_y(MState, 1, X, Y) -->
    { kill(MState), integer_ct1(X, Y0) },
    queue_pgoal(Y = Y0).

propagate_bct12(MState, B, X, Y) -->
    (   { var(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState), integer_compare(O, 0, X) },
        propagate_bct12_b(O, B, X, Y)
    ;   { nonvar(B), var(X), nonvar(Y) }
    ->  propagate_bct12_x(B, X, Y)
    ;   { nonvar(B), nonvar(X), var(Y) }
    ->  propagate_bct12_y(B, X, Y)
    ;   []
    ).

'@propagate_bct13_0'(>, _, _) --> [].
'@propagate_bct13_0'(=, 0, Y) --> { integer_ne(0, Y) }.
'@propagate_bct13_0'(<, X, Y) --> { integer_ct1(X, Y0), integer_ne(Y0, Y) }.

propagate_bct13_(0, X, Y) -->
    % { if_(integer_lt(X, 0), true, (integer_ct1(X, Y0), integer_ne(Y0, Y))) }.
    { integer_compare(O, 0, X) },
    '@propagate_bct13_0'(O, X, Y).
propagate_bct13_(1, X, Y) -->
    { integer_ct1(X, Y) }.

propagate_bct13(MState, B, X, Y) -->
    (   { nonvar(B), nonvar(X), nonvar(Y) }
    ->  { kill(MState) },
        propagate_bct13_(B, X, Y)
    ;   []
    ).

propagate_bct1_0_inf(>, _, _, _) --> [].
propagate_bct1_0_inf(=, MState, X, Y) -->
    { kill(MState) },
    queue_pgoal(popcount(#X) #\= #Y).
propagate_bct1_0_inf(<, MState, X, Y) -->
    { kill(MState) },
    queue_pgoal(popcount(#X) #\= #Y). % TODO: is this right?

propagate_bct1_0_sup(>, MState, _, _) -->
    { kill(MState) }.
propagate_bct1_0_sup(=, _, _, _) --> [].
propagate_bct1_0_sup(<, _, _, _) --> [].

propagate_bct1_0x(>, MState) -->
    { kill(MState) }.
propagate_bct1_0x(=, _) --> [].
propagate_bct1_0x(<, _) --> [].

propagate_bct1_0(MState, X, _) -->
    (   { var(X) }
    ->  {   fd_get(X, XD, _),
            domain_infimum(XD, XL),
            domain_supremum(XD, XU),
            cis_compare(O_I, n(0), XL),
            cis_compare(O_S, n(0), XU)
        },
        propagate_bct1_0_inf(O_I, MState),
        propagate_bct1_0_sup(O_S, MState)
    ;   { integer_compare(O, 0, X) },
        propagate_bct1_0x(O, MState)
    ).

'@propagate_bct1_x_inf'(>, _, _, _, _) --> [].
'@propagate_bct1_x_inf'(=, MState, B, X, Y) -->
    { kill(MState) },
    queue_pgoal(B = 1),
    queue_pgoal(popcount(#X) #= #Y).
'@propagate_bct1_x_inf'(<, MState, B, X, Y) -->
    { kill(MState) },
    queue_pgoal(B = 1),
    queue_pgoal(popcount(#X) #= #Y).

'@propagate_bct1_x_sup'(>, MState, B, _, _) -->
    { kill(MState) },
    queue_pgoal(B = 0).
'@propagate_bct1_x_sup'(=, _, _, _, _) --> [].
'@propagate_bct1_x_sup'(<, _, _, _, _) --> [].

'@propagate_bct1_x'(>, B, _, _) -->
    queue_pgoal(B = 0).
'@propagate_bct1_x'(=, B, 0, Y) -->
    queue_pgoal(B-Y=1-0).
'@propagate_bct1_x'(<, B, X, Y) -->
    { integer_ct1(X, Y0) },
    queue_pgoal(B-Y=1-Y0).

% No update to X
propagate_bct1_x(MState, B, X, Y) -->
    (   { var(X) }
    ->  {   fd_get(X, XD, _),
            domain_infimum(XD, XL),
            domain_supremum(XD, XU),
            cis_compare(O_I, n(0), XL),
            cis_compare(O_S, n(0), XU)
        },
        '@propagate_bct1_x_inf'(O_I, MState, B, X, Y),
        '@propagate_bct1_x_sup'(O_S, MState, B, X, Y)
    ;   { kill(MState), integer_compare(O, 0, X) },
        '@propagate_bct1_x'(O, B, X, Y)
    ).

% B is an output here and an input in a conjunction elsewhere.
% Y is an output here and an input elsewhere.
propagate_bct1(MState, B, X, Y) -->
    (   { B == 0 }
    ->  { throw(unimplemented(bct1(B,X,Y))) }
    ;   { B == 1 }
    ->  { kill(MState) },
        queue_pgoal(popcount(#X) #= #Y)
    ;   { var(B) }
    ->  propagate_bct1_x(MState, B, X, Y)
    ;   { false }
    ).
% propagate_bct1(MState, B, X, Y) -->
%     % propagate_bct10(MState, B, X, Y),
%     propagate_bct11(MState, B, X, Y),
%     propagate_bct12(MState, B, X, Y),
%     propagate_bct13(MState, B, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propagate_bdly(MState, B, G) -->
    (   { B == 0 }
    ->  { kill(MState) }
    ;   { B == 1 }
    ->  { kill(MState) },
        queue_pgoal(G)
    ;   { var(B) }
    ).
