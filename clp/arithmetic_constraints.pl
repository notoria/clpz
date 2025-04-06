%run_propagator(P, _) --> { portray_clause(run_propagator(P)), false }.
% trivial propagator, used only to remember pending constraints
run_propagator(presidual(_), _) --> [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_propagator(pdifferent(Left,Right,X,_), MState) -->
        run_propagator(pexclude(Left,Right,X), MState).

run_propagator(pexclude(Left,Right,X), _) -->
        (   ground(X) ->
            disable_queue,
            exclude_fire(Left, Right, X),
            enable_queue
        ;   true
        ).

run_propagator(pdistinct(Ls), _MState) --> distinct(Ls).

run_propagator(pnvalue(N, Vars), _MState) --> { propagate_nvalue(N, Vars) }.

run_propagator(check_distinct(Left,Right,X), _) -->
        { \+ list_contains(Left, X),
          \+ list_contains(Right, X) }.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_propagator(pelement(N, Is, V), MState) -->
        (   { fd_get(N, NDom, _) } ->
            (   { fd_get(V, VDom, VPs) } ->
                { integers_remaining(Is, 1, NDom, empty, VDom1),
                  domains_intersection(VDom, VDom1, VDom2) },
                fd_put(V, VDom2, VPs)
            ;   []
            )
        ;   { kill(MState), nth1(N, Is, V) }
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_propagator(pgcc_single(Vs, Pairs), _) --> gcc_global(Vs, Pairs).

run_propagator(pgcc_check_single(Pairs), _) --> gcc_check(Pairs).

run_propagator(pgcc_check(Pairs), _) --> gcc_check(Pairs).

run_propagator(pgcc(Vs, _, Pairs), _) --> gcc_global(Vs, Pairs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_propagator(pcircuit(Vs), _MState) -->
        distinct(Vs),
        { propagate_circuit(Vs) }.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_propagator(pgeq(A,B), MState) -->
        (   A == B -> kill(MState)
        ;   nonvar(A) ->
            (   nonvar(B) -> kill(MState), A >= B
            ;   { fd_get(B, BD, BPs),
                  domain_remove_greater_than(BD, A, BD1) },
                kill(MState),
                fd_put(B, BD1, BPs)
            )
        ;   nonvar(B) ->
            { fd_get(A, AD, APs),
              domain_remove_smaller_than(AD, B, AD1) },
            kill(MState),
            fd_put(A, AD1, APs)
        ;   { fd_get(A, AD, AL, AU, APs),
              fd_get(B, _, BL, BU, _),
              AU cis_geq BL },
            (   { AL cis_geq BU } -> kill(MState)
            ;   AU == BL -> kill(MState), A = B
            ;   { NAL cis max(AL,BL),
                  domains_intersection(AD, from_to(NAL,AU), NAD) },
                fd_put(A, NAD, APs),
                (   { fd_get(B, BD2, BL2, BU2, BPs2) } ->
                    { NBU cis min(BU2, AU),
                      domains_intersection(BD2, from_to(BL2,NBU), NBD) },
                    fd_put(B, NBD, BPs2)
                ;   []
                )
            )
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_propagator(rel_tuple(R, Tuple), MState) -->
        { get_attr(R, clpz_relation, Relation) },
        (   { ground(Tuple) } ->
            kill(MState),
            { del_attr(R, clpz_relation),
              memberchk(Tuple, Relation) }
        ;   { relation_unifiable(Relation, Tuple, Us, false, Changed),
              Us = [_|_] },
            (   { Tuple = [First,Second], ( ground(First) ; ground(Second) ) } ->
                kill(MState)
            ;   []
            ),
            (   { Us = [Single] } ->
                kill(MState),
                { del_attr(R, clpz_relation) },
                Single = Tuple
            ;   { call(Changed) } ->
                { put_attr(R, clpz_relation, Us) },
                disable_queue,
                tuple_domain(Tuple, Us),
                enable_queue
            ;   []
            )
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_propagator(pserialized(S_I, D_I, S_J, D_J, _), MState) -->
        (   nonvar(S_I), nonvar(S_J) ->
            kill(MState),
            (   S_I + D_I =< S_J -> []
            ;   S_J + D_J =< S_I -> []
            ;   false
            )
        ;   serialize_lower_upper(S_I, D_I, S_J, D_J, MState),
            serialize_lower_upper(S_J, D_J, S_I, D_I, MState)
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X #\= Y
run_propagator(pneq(A, B), MState) -->
        (   nonvar(A) ->
            (   nonvar(B) -> A =\= B, kill(MState)
            ;   { fd_get(B, BD0, BExp0),
                  domain_remove(BD0, A, BD1),
                  kill(MState) },
                fd_put(B, BD1, BExp0)
            )
        ;   nonvar(B) -> run_propagator(pneq(B, A), MState)
        ;   A \== B,
            { fd_get(A, _, AI, AS, _),
              fd_get(B, _, BI, BS, _) },
            (   { AS cis_lt BI } -> kill(MState)
            ;   { AI cis_gt BS } -> kill(MState)
            ;   []
            )
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Y = abs(X)
run_propagator(pabs(X,Y), MState) -->
        (   nonvar(X) -> kill(MState), Y is abs(X)
        ;   nonvar(Y) ->
            kill(MState),
            Y >= 0,
            YN is -Y,
            { X in YN \/ Y }
        ;   X == Y -> kill(MState)
        ;   { fd_get(X, XD, XPs),
              fd_get(Y, YD, _),
              domain_negate(YD, YDNegative),
              domains_union(YD, YDNegative, XD1),
              domains_intersection(XD, XD1, XD2) },
            fd_put(X, XD2, XPs),
            (   { fd_get(Y, YD1, YPs1) } ->
                { domain_negate(XD2, XD2Neg),
                  domains_union(XD2, XD2Neg, YD2),
                  domain_remove_smaller_than(YD2, 0, YD3),
                  domains_intersection(YD1, YD3, YD4) },
                fd_put(Y, YD4, YPs1)
            ;   []
            )
        ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% abs(X-Y) #\= C
run_propagator(absdiff_neq(X,Y,C), MState) -->
        (   C < 0 -> kill(MState)
        ;   nonvar(X) ->
            kill(MState),
            (   nonvar(Y) -> abs(X - Y) =\= C
            ;   V1 is X - C, neq_num(Y, V1),
                V2 is C + X, neq_num(Y, V2)
            )
        ;   nonvar(Y) -> kill(MState),
            V1 is C + Y, neq_num(X, V1),
            V2 is Y - C, neq_num(X, V2)
        ;   []
        ).


% X #= abs(X) + V
run_propagator(x_eq_abs_plus_v(X,V), MState) -->
        (   nonvar(V) ->
            (   V =:= 0 -> kill(MState), { X in 0..sup }
            ;   V < 0 -> kill(MState), { X #= V / 2 }
            ;   false % V > 0
            )
        ;   nonvar(X) ->
            kill(MState),
            { V #= X - abs(X) }
        ;   true
        ).

% X #\= Y + Z
run_propagator(x_neq_y_plus_z(X,Y,Z), MState) -->
        (   nonvar(X) ->
            (   nonvar(Y) ->
                (   nonvar(Z) -> kill(MState), X =\= Y + Z
                ;   kill(MState), XY is X - Y, neq_num(Z, XY)
                )
            ;   nonvar(Z) -> kill(MState), XZ is X - Z, neq_num(Y, XZ)
            ;   []
            )
        ;   nonvar(Y) ->
            (   nonvar(Z) ->
                kill(MState), YZ is Y + Z, neq_num(X, YZ)
            ;   Y =:= 0 -> kill(MState), { neq(X, Z) }
            ;   []
            )
        ;   Z == 0 -> kill(MState), { neq(X, Y) }
        ;   true
        ).

% X #=< Y + C
run_propagator(x_leq_y_plus_c(X,Y,C), MState) -->
        (   nonvar(X) ->
            (   nonvar(Y) -> kill(MState), X =< Y + C
            ;   kill(MState),
                R is X - C,
                { fd_get(Y, YD, YPs),
                  domain_remove_smaller_than(YD, R, YD1) },
                fd_put(Y, YD1, YPs)
            )
        ;   nonvar(Y) ->
            kill(MState),
            R is Y + C,
            { fd_get(X, XD, XPs),
              domain_remove_greater_than(XD, R, XD1) },
            fd_put(X, XD1, XPs)
        ;   (   X == Y -> C >= 0, kill(MState)
            ;   { fd_get(Y, YD, _) },
                (   { domain_supremum(YD, n(YSup)) } ->
                    YS1 is YSup + C,
                    { fd_get(X, XD, XPs),
                      domain_remove_greater_than(XD, YS1, XD1) },
                    fd_put(X, XD1, XPs)
                ;   []
                ),
                (   { fd_get(X, XD2, _), domain_infimum(XD2, n(XInf)) } ->
                    XI1 is XInf - C,
                    (   { fd_get(Y, YD1, YPs1) } ->
                        { domain_remove_smaller_than(YD1, XI1, YD2),
                          (   domain_infimum(YD2, n(YInf)),
                              domain_supremum(XD2, n(XSup)),
                              XSup =< YInf + C ->
                              kill(MState)
                          ;   true
                          ) },
                        fd_put(Y, YD2, YPs1)
                    ;   []
                    )
                ;   []
                )
            )
        ).

run_propagator(scalar_product_neq(Cs0,Vs0,P0), MState) -->
        { coeffs_variables_const(Cs0, Vs0, Cs, Vs, 0, I),
          P is P0 - I,
          (   Vs = [] -> kill(MState), P =\= 0
          ;   Vs = [V], Cs = [C] ->
              kill(MState),
              (   C =:= 1 -> neq_num(V, P)
              ;   C*V #\= P
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

run_propagator(scalar_product_leq(Cs0,Vs0,P0), MState) -->
        { coeffs_variables_const(Cs0, Vs0, Cs, Vs, 0, I) },
        P is P0 - I,
        (   Vs = [] -> kill(MState), P >= 0
        ;   { duophrase(sum_finite_domains(Cs, Vs, 0, 0, Inf, Sup), Infs, Sups) },
            D1 is P - Inf,
            disable_queue,
            (   Infs == [], Sups == [] ->
                Inf =< P,
                (   Sup =< P -> kill(MState)
                ;   remove_dist_upper_leq(Cs, Vs, D1)
                )
            ;   Infs == [] -> Inf =< P, remove_dist_upper(Sups, D1)
            ;   Infs = [_] -> remove_upper(Infs, D1)
            ;   true
            ),
            enable_queue
        ).

run_propagator(scalar_product_eq(Cs0,Vs0,P0), MState) -->
        { coeffs_variables_const(Cs0, Vs0, Cs, Vs, 0, I) },
        P is P0 - I,
        (   Vs = [] -> kill(MState), P =:= 0
        ;   Vs = [V], Cs = [C] -> kill(MState), P mod C =:= 0, V is P // C
        ;   Cs == [1,1] -> kill(MState), Vs = [A,B], { A + B #= P }
        ;   Cs == [1,-1] -> kill(MState), Vs = [A,B], { A #= P + B }
        ;   Cs == [-1,1] -> kill(MState), Vs = [A,B], { B #= P + A }
        ;   Cs == [-1,-1] -> kill(MState), Vs = [A,B], P1 is -P, { A + B #= P1 }
        ;   P =:= 0, Cs == [1,1,-1] -> kill(MState), Vs = [A,B,C], { A + B #= C }
        ;   P =:= 0, Cs == [1,-1,1] -> kill(MState), Vs = [A,B,C], { A + C #= B }
        ;   P =:= 0, Cs == [-1,1,1] -> kill(MState), Vs = [A,B,C], { B + C #= A }
        ;   { duophrase(sum_finite_domains(Cs, Vs, 0, 0, Inf, Sup), Infs, Sups) },
            % { nl, writeln(Infs-Sups-Inf-Sup) },
            D1 is P - Inf,
            D2 is Sup - P,
            disable_queue,
            (   Infs == [], Sups == [] ->
                { between(Inf, Sup, P) },
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
            enable_queue
        ).

% X + Y = Z
run_propagator(pplus(X,Y,Z), MState) -->
        (   nonvar(X) ->
            (   X =:= 0 -> kill(MState), Y = Z
            ;   Y == Z -> kill(MState), X =:= 0
            ;   nonvar(Y) -> kill(MState), Z is X + Y
            ;   nonvar(Z) -> kill(MState), Y is Z - X
            ;   { fd_get(Z, ZD, ZPs),
                  fd_get(Y, YD, _),
                  domain_shift(YD, X, Shifted_YD),
                  domains_intersection(ZD, Shifted_YD, ZD1) },
                fd_put(Z, ZD1, ZPs),
                (   { fd_get(Y, YD1, YPs) } ->
                    O is -X,
                    { domain_shift(ZD1, O, YD2),
                      domains_intersection(YD1, YD2, YD3) },
                    fd_put(Y, YD3, YPs)
                ;   []
                )
            )
        ;   nonvar(Y) -> run_propagator(pplus(Y,X,Z), MState)
        ;   nonvar(Z) ->
            (   X == Y -> kill(MState), { even(Z), X is Z // 2 }
            ;   { fd_get(X, XD, _),
                  fd_get(Y, YD, YPs),
                  domain_negate(XD, XDN),
                  domain_shift(XDN, Z, YD1),
                  domains_intersection(YD, YD1, YD2) },
                fd_put(Y, YD2, YPs),
                (   { fd_get(X, XD1, XPs) } ->
                    { domain_negate(YD2, YD2N),
                      domain_shift(YD2N, Z, XD2),
                      domains_intersection(XD1, XD2, XD3) },
                      fd_put(X, XD3, XPs)
                ;   []
                )
            )
        ;   (   X == Y -> { kill(MState), 2*X #= Z }
            ;   X == Z -> kill(MState), Y = 0
            ;   Y == Z -> kill(MState), X = 0
            ;   { fd_get(X, XD, XL, XU, XPs),
                  fd_get(Y, _, YL, YU, _),
                  fd_get(Z, _, ZL, ZU, _),
                  NXL cis max(XL, ZL-YU),
                  NXU cis min(XU, ZU-YL) },
                  update_bounds(X, XD, XPs, XL, XU, NXL, NXU),
                (   { fd_get(Y, YD2, YL2, YU2, YPs2) } ->
                    { NYL cis max(YL2, ZL-NXU),
                      NYU cis min(YU2, ZU-NXL) },
                    update_bounds(Y, YD2, YPs2, YL2, YU2, NYL, NYU)
                ;   NYL = n(Y), NYU = n(Y)
                ),
                (   { fd_get(Z, ZD2, ZL2, ZU2, ZPs2) } ->
                    { NZL cis max(ZL2,NXL+NYL),
                      NZU cis min(ZU2,NXU+NYU) },
                    update_bounds(Z, ZD2, ZPs2, ZL2, ZU2, NZL, NZU)
                ;   []
                )
            )
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_propagator(ptimes(X,Y,Z), MState) -->
        (   nonvar(X) ->
            (   nonvar(Y) -> kill(MState), Z is X * Y
            ;   X =:= 0 -> kill(MState), Z = 0
            ;   X =:= 1 -> kill(MState), Z = Y
            ;   nonvar(Z) -> kill(MState), 0 =:= Z mod X, Y is Z // X
            ;   (   Y == Z -> kill(MState), Y = 0
                ;   { fd_get(Y, YD, _),
                      fd_get(Z, ZD, ZPs),
                      domain_expand(YD, X, Scaled_YD),
                      domains_intersection(ZD, Scaled_YD, ZD1) },
                    fd_put(Z, ZD1, ZPs),
                    (   { fd_get(Y, YDom2, YPs2) } ->
                        { domain_contract(ZD1, X, Contract),
                          domains_intersection(YDom2, Contract, NYDom) },
                        fd_put(Y, NYDom, YPs2)
                    ;   kill(MState), Z is X * Y
                    )
                )
            )
        ;   nonvar(Y) -> run_propagator(ptimes(Y,X,Z), MState)
        ;   nonvar(Z) ->
            (   X == Y ->
                kill(MState),
                { integer_kth_root(Z, 2, R),
                  NR is -R,
                  X in NR \/ R }
            ;   { fd_get(X, XD, XL, XU, XPs),
                  fd_get(Y, YD, YL, YU, _),
                  min_max_factor(n(Z), n(Z), YL, YU, XL, XU, NXL, NXU) },
                update_bounds(X, XD, XPs, XL, XU, NXL, NXU),
                (   { fd_get(Y, YD2, YL2, YU2, YPs2) } ->
                    { min_max_factor(n(Z), n(Z), NXL, NXU, YL2, YU2, NYL, NYU) },
                    update_bounds(Y, YD2, YPs2, YL2, YU2, NYL, NYU)
                ;   (   Y =\= 0 -> 0 =:= Z mod Y, kill(MState), X is Z // Y
                    ;   kill(MState), Z = 0
                    )
                ),
                (   Z =:= 0 ->
                    (   { \+ domain_contains(XD, 0) } -> kill(MState), Y = 0
                    ;   { \+ domain_contains(YD, 0) } -> kill(MState), X = 0
                    ;   []
                    )
                ;  neq_num(X, 0), neq_num(Y, 0)
                )
            )
        ;   (   X == Y -> kill(MState), { X^2 #= Z }
            ;   { fd_get(X, XD, XL, XU, XPs),
                  fd_get(Y, _, YL, YU, _),
                  fd_get(Z, ZD, ZL, ZU, _) },
                (   { Y == Z, \+ domain_contains(ZD, 0) } -> kill(MState), X = 1
                ;   { X == Z, \+ domain_contains(ZD, 0) } -> kill(MState), Y = 1
                ;   { min_max_factor(ZL, ZU, YL, YU, XL, XU, NXL, NXU) },
                    update_bounds(X, XD, XPs, XL, XU, NXL, NXU),
                    (   { fd_get(Y, YD2, YL2, YU2, YPs2) } ->
                        { min_max_factor(ZL, ZU, NXL, NXU, YL2, YU2, NYL, NYU) },
                        update_bounds(Y, YD2, YPs2, YL2, YU2, NYL, NYU)
                    ;   NYL = n(Y), NYU = n(Y)
                    ),
                    (   { fd_get(Z, ZD2, ZL2, ZU2, ZPs2) } ->
                        { min_product(NXL, NXU, NYL, NYU, NZL),
                          max_product(NXL, NXU, NYL, NYU, NZU) },
                        (   { NZL cis_leq ZL2, NZU cis_geq ZU2 } -> ZD3 = ZD2
                        ;   { domains_intersection(ZD2, from_to(NZL,NZU), ZD3) },
                            fd_put(Z, ZD3, ZPs2)
                        ),
                        (   { domain_contains(ZD3, 0) } -> []
                        ;   neq_num(X, 0), neq_num(Y, 0)
                        )
                    ;   []
                    )
                )
            )
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X // Y = Z (round towards zero)
run_propagator(ptzdiv(X,Y,Z), MState) -->
        (   nonvar(X) ->
            (   nonvar(Y) -> kill(MState), Y =\= 0, Z is X // Y
            ;   { fd_get(Y, YD, YL, YU, YPs) },
                (   nonvar(Z) ->
                    (   Z =:= 0 ->
                        NYL is -abs(X) - 1,
                        NYU is abs(X) + 1,
                        { domains_intersection(YD, split(0, from_to(inf,n(NYL)),
                                                       from_to(n(NYU), sup)),
                                             NYD) },
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
                          domains_intersection(YD1, from_to(NYL, NYU), NYD1) },
                        fd_put(Y, NYD1, YPs1)
                    ;   true
                    )
                )
            )
        ;   nonvar(Y) ->
            Y =\= 0,
            (   Y =:= 1 -> kill(MState), X = Z
            ;   Y =:= -1 -> kill(MState), { Z #= -X }
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
                      domains_intersection(ZD, Contracted, NZD) },
                    fd_put(Z, NZD, ZPs),
                    (   { fd_get(X, XD2, XPs2) } ->
                        { domain_expand_more(NZD, Y, Expanded),
                          domains_intersection(XD2, Expanded, NXD2) },
                        fd_put(X, NXD2, XPs2)
                    ;   true
                    )
                )
            )
        ;   nonvar(Z) ->
            { fd_get(X, XD, XL, XU, XPs),
              fd_get(Y, _, YL, YU, _),
              (   YL cis_geq n(0), XL cis_geq n(0) ->
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
                  domains_intersection(ZD, from_to(NZL,NZU), NZD0),
                  (   XL cis_geq n(0), YL cis_geq n(0) ->
                      domain_remove_smaller_than(NZD0, 0, NZD1)
                  ;   % TODO: cover more cases
                      NZD1 = NZD0
                  ) },
                fd_put(Z, NZD1, ZPs)
            )
        ).


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% % Z = X mod Y

run_propagator(pmod(X,Y,Z), MState) -->
        (   Y == 0 -> false
        ;   Y == Z -> false
        ;   X == Y -> kill(MState), queue_goal(Z = 0)
        ;   true
        ),
        (   nonvar(X), nonvar(Y) ->
            kill(MState),
            Z is X mod Y
        ;   nonvar(Y), nonvar(Z) ->
            (   Y > 0 -> Z >= 0, Z < Y
            ;   Z =< 0, Z > Y    % Y < 0
            ),
            (   { fd_get(X, _, n(XL), _, _) } ->
                (   (XL - Z) mod Y =\= 0 ->
                    XMin is Z + Y * ((XL - Z) div Y + 1)
                ;   XMin is XL
                ),
                { fd_get(X, XD0, XPs),
                  domain_remove_smaller_than(XD0, XMin, XD2) },
                fd_put(X, XD2, XPs)
                % queue_goal(X #>= XMin)
            ;   true
            ),
            (   { fd_get(X, _, _, n(XU), _) } ->
                XMax is Z + Y * ((XU - Z) div Y),
                { fd_get(X, XD1, XPs),
                  domain_remove_greater_than(XD1, XMax, XD3) },
                fd_put(X, XD3, XPs)
                % queue_goal(X #=< XMax)
            ;   true
            )
        ;   nonvar(Z), nonvar(X) ->
            (   Z > 0 ->
                (   X < 0 -> true
                ;   X >= Z
                )
            ;   Z < 0 ->
                (   X > 0 -> true
                ;   X =< Z
                )
            ;   Z =:= 0 % Multiple solutions so do nothing special.
            ),
            (   { fd_get(Y, _, _, n(YU), _),
                  YU < X, X =< 0 } -> kill(MState), Z =:= X
            ;   { fd_get(Y, _, n(YL), _, _),
                  YL > X, X >= 0 } -> kill(MState), Z =:= X
            ;   (   Z > 0 ->
                    { fd_get(Y, YD, YPs),
                      YMin is Z + 1,
                      domain_remove_smaller_than(YD, YMin, YD1) },
                    fd_put(Y, YD1, YPs)
                    % queue_goal(Y #> Z)
                ;   Z < 0 ->
                    { fd_get(Y, YD, YPs),
                      YMax is Z - 1,
                      domain_remove_greater_than(YD, YMax, YD1) },
                    fd_put(Y, YD1, YPs)
                    % queue_goal(Y #< Z)
                ;   true
                )
            )
        ;   run_propagator(pmodz(X,Y,Z), MState),
            run_propagator(pmody(X,Y,Z), MState),
            true
        ).

run_propagator(pmodz(X,Y,Z), MState) -->
        (   nonvar(Z) -> true % Nothing to do.
        ;   nonvar(X) ->
            (   X =:= 0 -> kill(MState), queue_goal(Z = X)
            ;   (   X > 0 ->
                    (   { fd_get(Y, _, n(YL), _, _), YL > X } ->
                        kill(MState),
                        queue_goal(Z = X)
                    ;   { fd_get(Z, ZD0, ZPs),
                          domain_remove_greater_than(ZD0, X, ZD2) },
                        fd_put(Z, ZD2, ZPs)
                        % queue_goal(Z #=< X)
                    )
                ;   X < 0,
                    (   { fd_get(Y, _, _, n(YU), _), YU < X } ->
                        kill(MState),
                        queue_goal(Z = X)
                    ;   { fd_get(Z, ZD0, ZPs),
                          domain_remove_smaller_than(ZD0, X, ZD2) },
                        fd_put(Z, ZD2, ZPs)
                        % queue_goal(Z #>= X)
                    )
                ),
                (   { fd_get(Y, _, n(YL), n(YU), _), YL > 0 } ->
                    ZMax is YU - 1,
                    { fd_get(Z, ZD1, ZPs),
                      domain_remove_smaller_than(ZD1, 0, ZD3),
                      domain_remove_greater_than(ZD3, ZMax, ZD5) },
                    fd_put(Z, ZD5, ZPs)
                    % queue_goal(Z in 0..ZMax)
                ;   { fd_get(Y, _, n(YL), n(YU), _), YU < 0 } ->
                    ZMin is YL + 1,
                    { fd_get(Z, ZD1, ZPs),
                      domain_remove_greater_than(ZD1, 0, ZD3),
                      domain_remove_smaller_than(ZD3, ZMin, ZD5) },
                    fd_put(Z, ZD5, ZPs)
                    % queue_goal(Z in ZMin..0)
                ;   true
                )
            )
        ;   nonvar(Y) ->
            (   abs(Y) =:= 1 -> kill(MState), queue_goal(Z = 0)
            ;   Y < 0 ->
                (   { fd_get(X, _, n(XL), n(XU), _), XU =< 0, Y < XL } ->
                    kill(MState),
                    queue_goal(Z = X)
                ;   ZMin is Y + 1,
                    { fd_get(Z, ZD1, ZPs),
                      domain_remove_greater_than(ZD1, 0, ZD3),
                      domain_remove_smaller_than(ZD3, ZMin, ZD5) },
                    fd_put(Z, ZD5, ZPs)
                    % queue_goal(Z in ZMin..0)
                )
            ;   Y > 0,
                (   { fd_get(X, _, n(XL), n(XU), _), XL >= 0, Y > XU } ->
                    kill(MState),
                    queue_goal(Z = X)
                ;   ZMax is Y - 1,
                    { fd_get(Z, ZD1, ZPs),
                      domain_remove_smaller_than(ZD1, 0, ZD3),
                      domain_remove_greater_than(ZD3, ZMax, ZD5) },
                    fd_put(Z, ZD5, ZPs)
                    % queue_goal(Z in 0..ZMax)
                )
            )
        ;   (   { fd_get(X, _, n(XL), n(XU), _), XL >= 0,
                  fd_get(Y, _, n(YL), _, _), XU < YL } ->
                kill(MState),
                queue_goal(Z = X)
            ;   { fd_get(X, _, n(XL), n(XU), _), XU =< 0,
                  fd_get(Y, _, _, n(YU), _), XL > YU } ->
                kill(MState),
                queue_goal(Z = X)
            ;   (   { fd_get(X, _, n(XL), n(XU), _), XL >= 0 } ->
                    { fd_get(Z, ZD0, ZPs),
                      domain_remove_greater_than(ZD0, XU, ZD2) },
                    fd_put(Z, ZD2, ZPs)
                    % queue_goal(Z #=< XU)
                ;   { fd_get(X, _, n(XL), n(XU), _), XU =< 0 } ->
                    { fd_get(Z, ZD0, ZPs),
                      domain_remove_smaller_than(ZD0, XL, ZD2) },
                    fd_put(Z, ZD2, ZPs)
                    % queue_goal(Z #>= XL)
                ;   true
                ),
                (   { fd_get(Y, _, n(YL), n(YU), _), YL > 0 } ->
                    ZMax is YU - 1,
                    { fd_get(Z, ZD1, ZPs),
                      domain_remove_smaller_than(ZD1, 0, ZD3),
                      domain_remove_greater_than(ZD3, ZMax, ZD5) },
                    fd_put(Z, ZD5, ZPs)
                    % queue_goal(Z in 0..ZMax)
                ;   { fd_get(Y, _, n(YL), n(YU), _), YU < 0 } ->
                    ZMin is YL + 1,
                    { fd_get(Z, ZD1, ZPs),
                      domain_remove_greater_than(ZD1, 0, ZD3),
                      domain_remove_smaller_than(ZD3, ZMin, ZD5) },
                    fd_put(Z, ZD5, ZPs)
                    % queue_goal(Z in ZMin..0)
                ;   { fd_get(Y, _, n(YL), n(YU), _), YL < 0, YU > 0 } ->
                    ZMin is YL + 1,
                    ZMax is YU - 1,
                    { fd_get(Z, ZD1, ZPs),
                      domain_remove_greater_than(ZD1, ZMax, ZD3),
                      domain_remove_smaller_than(ZD3, ZMin, ZD5) },
                    fd_put(Z, ZD5, ZPs)
                    % queue_goal(Z in ZMin..ZMax)
                ;   { fd_get(Y, _, _, n(YU), _), YU > 0 } ->
                    { fd_get(Z, ZD1, ZPs),
                      ZMax is YU - 1,
                      domain_remove_greater_than(ZD1, ZMax, ZD3) },
                    fd_put(Z, ZD3, ZPs)
                    % queue_goal(Z #< YU)
                ;   { fd_get(Y, _, n(YL), _, _), YL < 0 } ->
                    { fd_get(Z, ZD1, ZPs),
                      ZMin is YL + 1,
                      domain_remove_smaller_than(ZD1, ZMin, ZD3) },
                    fd_put(Z, ZD3, ZPs)
                    % queue_goal(Z #> YL)
                ;   true
                )
            )
        ).

run_propagator(pmody(_X,Y,Z), _MState) -->
        (   nonvar(Y) -> true % Nothing to do.
        % ;   nonvar(X) -> true
        ;   nonvar(Z) ->
            (   Z > 0 ->
                { fd_get(Y, YD, YPs),
                  YMin is Z + 1,
                  domain_remove_smaller_than(YD, YMin, YD1) },
                fd_put(Y, YD1, YPs)
                % queue_goal(Y #> Z)
            ;   Z < 0 ->
                { fd_get(Y, YD, YPs),
                  YMax is Z - 1,
                  domain_remove_greater_than(YD, YMax, YD1) },
                fd_put(Y, YD1, YPs)
                % queue_goal(Y #< Z)
            ;   Z =:= 0 % Multiple solutions so do nothing special.
            )
        ;   (   { fd_get(Z, _, n(ZL), _, _), ZL > 0 } ->
                { fd_get(Y, YD, YPs),
                  YMin is ZL + 1,
                  domain_remove_smaller_than(YD, YMin, YD1) },
                fd_put(Y, YD1, YPs)
                % queue_goal(Y #> ZL)
            ;   { fd_get(Z, _, _, n(ZU), _), ZU < 0 } ->
                { fd_get(Y, YD, YPs),
                  YMax is ZU - 1,
                  domain_remove_greater_than(YD, YMax, YD1) },
                fd_put(Y, YD1, YPs)
                % queue_goal(Y #< ZU)
            ;   true
            )
        ).


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% % Z = X rem Y

run_propagator(prem(X,Y,Z), MState) -->
        (   nonvar(X) ->
            (   nonvar(Y) -> kill(MState), Y =\= 0, Z is X rem Y
            ;   U is abs(X),
                { fd_get(Y, YD, _) },
                (   X >=0, { domain_infimum(YD, n(Min)), Min >= 0 } -> L = 0
                ;   L is -U
                ),
                { Z in L..U }
            )
        ;   nonvar(Y) ->
            Y =\= 0,
            (   abs(Y) =:= 1 -> kill(MState), Z = 0
            ;   var(Z) ->
                YP is abs(Y) - 1,
                YN is -YP,
                (   Y > 0, { fd_get(X, _, n(XL), n(XU), _) } ->
                    (   abs(XL) < Y, XU < Y -> kill(MState), Z = X, ZL = XL
                    ;   XL < 0, abs(XL) < Y -> ZL = XL
                    ;   XL >= 0 -> ZL = 0
                    ;   ZL = YN
                    ),
                    (   XU > 0, XU < Y -> ZU = XU
                    ;   XU < 0 -> ZU = 0
                    ;   ZU = YP
                    )
                ;   ZL = YN, ZU = YP
                ),
                (   { fd_get(Z, ZD, ZPs) } ->
                    { domains_intersection(ZD, from_to(n(ZL), n(ZU)), ZD1) },
                    fd_put(Z, ZD1, ZPs)
                ;   ZD1 = from_to(n(Z), n(Z))
                ),
                (   { fd_get(X, XD, _), domain_infimum(XD, n(Min)) } ->
                    Z1 is Min rem Y,
                    (   { domain_contains(ZD1, Z1) } -> true
                    ;   neq_num(X, Min)
                    )
                ;   true
                ),
                (   { fd_get(X, XD1, _), domain_supremum(XD1, n(Max)) } ->
                    Z2 is Max rem Y,
                    (   { domain_contains(ZD1, Z2) } -> true
                    ;   neq_num(X, Max)
                    )
                ;   true
                )
            ;   { fd_get(X, XD1, XPs1) },
                % if possible, propagate at the boundaries
                (   { domain_infimum(XD1, n(Min)) } ->
                    (   Min rem Y =:= Z -> true
                    ;   Y > 0, Min > 0 ->
                        Next is ((Min - Z + Y - 1) div Y)*Y + Z,
                        { domain_remove_smaller_than(XD1, Next, XD2) },
                        fd_put(X, XD2, XPs1)
                    ;   % TODO: bigger steps in other cases as well
                        neq_num(X, Min)
                    )
                ;   true
                ),
                (   { fd_get(X, XD3, XPs3) } ->
                    (   { domain_supremum(XD3, n(Max)) } ->
                        (   Max rem Y =:= Z -> true
                        ;   Y > 0, Max > 0  ->
                            Prev is ((Max - Z) div Y)*Y + Z,
                            { domain_remove_greater_than(XD3, Prev, XD4) },
                            fd_put(X, XD4, XPs3)
                        ;   % TODO: bigger steps in other cases as well
                            neq_num(X, Max)
                        )
                    ;   true
                    )
                ;   true
                )
            )
        ;   X == Y -> kill(MState), Z = 0
        ;   { fd_get(Z, ZD, ZPs) } ->
            { fd_get(Y, _, YInf, YSup, _),
              fd_get(X, _, XInf, XSup, _),
              M cis max(abs(YInf),YSup),
              (   XInf cis_geq n(0) -> Inf0 = n(0)
              ;   Inf0 = XInf
              ),
              (   XSup cis_leq n(0) -> Sup0 = n(0)
              ;   Sup0 = XSup
              ),
              NInf cis max(max(Inf0, -M + n(1)), min(XInf,-XSup)),
              NSup cis min(min(Sup0, M - n(1)), max(abs(XInf),XSup)),
              domains_intersection(ZD, from_to(NInf,NSup), ZD1) },
            fd_put(Z, ZD1, ZPs)
        ;   true % TODO: propagate more
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z = max(X,Y)

run_propagator(pmax(X,Y,Z), MState) -->
        false,
        (   nonvar(X) ->
            (   nonvar(Y) -> kill(MState), queue_goal(Z is max(X,Y))
            ;   nonvar(Z) ->
                (   Z =:= X -> kill(MState), queue_goal(X #>= Y)
                ;   Z > X -> queue_goal(Z = Y)
                ;   false % Z < X
                )
            ;   Y == Z -> kill(MState), queue_goal(Y #>= X)
            ;   { fd_get(Y, _, YInf, YSup, _) },
                (   { YInf cis_gt n(X) } -> queue_goal(Z = Y)
                ;   { YSup cis_lt n(X) } -> queue_goal(Z = X)
                ;   YSup = n(M) ->
                    { fd_get(Z, ZD, ZPs),
                      domain_remove_greater_than(ZD, M, ZD1) },
                    fd_put(Z, ZD1, ZPs)
                ;   []
                )
            )
        ;   nonvar(Y) -> run_propagator(pmax(Y,X,Z), MState)
        ;   { fd_get(Z, ZD, ZPs) } ->
            { fd_get(X, _, XInf, XSup, _),
              fd_get(Y, _, YInf, YSup, _) },
            (   { YInf cis_gt XSup } -> kill(MState), queue_goal(Z = Y)
            ;   { YSup cis_lt XInf } -> kill(MState), queue_goal(Z = X)
            ;   { n(M) cis max(XSup, YSup) } ->
                { domain_remove_greater_than(ZD, M, ZD1) },
                fd_put(Z, ZD1, ZPs)
            ;   []
            )
        ;   []
        ).

% Z=max(X, Y)
% max(X, Y) = max(Y, X), X >= Y <=> X = max(X, Y)
%
% X >= Y => Z = X
% Z = X => Z >= Y
% Z > X => Z = Y
run_propagator(pmax(X,Y,Z), MState) -->
        (   nonvar(X), nonvar(Y), nonvar(Z)
        ->  kill(MState),
            Z =:= max(X, Y)
        ;   X == Y
        ->  kill(MState),
            queue_goal(Z = X)
        ;   run_propagator(pmax2(X,Y,Z), MState),
            run_propagator(pmax2(Y,X,Z), MState),
            run_propagator(pmax1(X,Y,Z), MState),
            run_propagator(pmax1(Y,X,Z), MState),
            run_propagator(pmax0(X,Y,Z), MState),
            run_propagator(pmax0(Y,X,Z), MState)
        ).

run_propagator(pmax2(X,Y,Z), MState) -->
        (   nonvar(X), nonvar(Y), nonvar(Z)
        ->  true
        ;   (   nonvar(X), nonvar(Y), X >= Y
            ->  kill(MState),
                queue_goal(Z = X)
            ;   true
            ),
            (   nonvar(Z), nonvar(X)
            ->  (   Z = X
                ->  kill(MState),
                    % queue_goal(#Z #>= #Y)
                    { fd_get(Y, YD0, YPs0),
                      domain_remove_greater_than(YD0, Z, YD1) },
                    fd_put(Y, YD1, YPs0)
                ;   Z > X
                ->  kill(MState),
                    queue_goal(Z = Y)
                ;   false % Z < X
                )
            ;   true
            )
        ).

run_propagator(pmax1(X,Y,Z), MState) -->
        (   nonvar(X), nonvar(Y)
        ->  true
        ;   nonvar(Y), nonvar(Z)
        ->  true
        ;   nonvar(Z), nonvar(X)
        ->  true
        ;   (   { nonvar(X), fd_get(Y, _, _, n(YU), _), X >= YU }
            ->  kill(MState),
                queue_goal(Z = X)
            ;   { fd_get(X, _, n(XL), _, _), nonvar(Y), XL >= Y }
            ->  kill(MState),
                queue_goal(Z = X)
            ;   true
            ),
            (   Z == X, nonvar(Y)
            ->  kill(MState),
                % queue_goal(#Z #>= #Y)
                { fd_get(Z, ZD0, ZPs0),
                  domain_remove_smaller_than(ZD0, Y, ZD1) },
                fd_put(Z, ZD1, ZPs0)
            ;   { nonvar(Z), fd_get(X, _, _, n(XU), _), Z > XU }
            ->  kill(MState),
                queue_goal(Z = Y)
            ;   { fd_get(Z, _, n(ZL), _, _), nonvar(X), ZL > X }
            ->  kill(MState),
                queue_goal(Z = Y)
            % ;   nonvar(Z)
            % ->  true % queue_goal((#Z #>= #X, #Z #>= #Y))
            ;   true
            ),
            (   { fd_get(X, _, _, n(XU), _), nonvar(Y), XU >= Y }
            ->  % queue_goal(#Z #=< #XU)
                { fd_get(Z, ZD2, ZPs1),
                  domain_remove_greater_than(ZD2, XU, ZD3) },
                fd_put(Z, ZD3, ZPs1)
            ;   true
            )
        ).

run_propagator(pmax0(X,Y,Z), MState) -->
        (   nonvar(X)
        ->  true
        ;   nonvar(Y)
        ->  true
        ;   nonvar(Z)
        ->  true
        ;   (   { fd_get(X, _, n(XL), _, _), fd_get(Y, _, _, n(YU), _), XL >= YU }
            ->  kill(MState),
                queue_goal(Z = X)
            ;   true
            ),
            (   Z == X
            ->  kill(MState),
                queue_goal(#Z #>= #Y)
            ;   { fd_get(Z, _, n(ZL), _, _), fd_get(X, _, _, n(XU), _), ZL > XU }
            ->  kill(MState),
                queue_goal(Z = Y)
            ;   true
            ),
            (   { fd_get(X, _, _, n(XU), _), fd_get(Y, _, _, n(YU), _), XU >= YU }
            ->  % queue_goal(#Z #=< #XU)
                { fd_get(Z, ZD2, ZPs1),
                  domain_remove_greater_than(ZD2, XU, ZD3) },
                fd_put(Z, ZD3, ZPs1)
            ;   true
            )
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z = min(X,Y)

run_propagator(pmin(X,Y,Z), MState) -->
        false,
        (   nonvar(X) ->
            (   nonvar(Y) -> kill(MState), Z is min(X,Y)
            ;   nonvar(Z) ->
                (   Z =:= X -> kill(MState), { X #=< Y }
                ;   Z < X -> Z = Y
                ;   false % Z > X
                )
            ;   Y == Z -> kill(MState), queue_goal(Y #=< X)
            ;   { fd_get(Y, _, YInf, YSup, _) },
                (   { YSup cis_lt n(X) } -> Z = Y
                ;   { YInf cis_gt n(X) } -> Z = X
                ;   YInf = n(M) ->
                    { fd_get(Z, ZD, ZPs),
                      domain_remove_smaller_than(ZD, M, ZD1) },
                    fd_put(Z, ZD1, ZPs)
                ;   []
                )
            )
        ;   nonvar(Y) -> run_propagator(pmin(Y,X,Z), MState)
        ;   { fd_get(Z, ZD, ZPs) } ->
            { fd_get(X, _, XInf, XSup, _),
              fd_get(Y, _, YInf, YSup, _) },
            (   { YSup cis_lt XInf } -> kill(MState), Z = Y
            ;   { YInf cis_gt XSup } -> kill(MState), Z = X
            ;   { n(M) cis min(XInf, YInf) } ->
                { domain_remove_smaller_than(ZD, M, ZD1) },
                fd_put(Z, ZD1, ZPs)
            ;   []
            )
        ;   []
        ).

% Z=min(X, Y)
% min(X, Y) = min(Y, X), X =< Y <=> X = min(X, Y)
%
% X =< Y => Z = X
% Z = X => Z =< Y
% Z < X => Z = Y
run_propagator(pmin(X,Y,Z), MState) -->
        (   nonvar(X), nonvar(Y), nonvar(Z)
        ->  kill(MState),
            Z =:= min(X, Y)
        ;   X == Y
        ->  kill(MState),
            queue_goal(Z = X)
        ;   run_propagator(pmin2(X,Y,Z), MState),
            run_propagator(pmin2(Y,X,Z), MState),
            run_propagator(pmin1(X,Y,Z), MState),
            run_propagator(pmin1(Y,X,Z), MState),
            run_propagator(pmin0(X,Y,Z), MState),
            run_propagator(pmin0(Y,X,Z), MState)
        ).

run_propagator(pmin2(X,Y,Z), MState) -->
        (   nonvar(X), nonvar(Y), nonvar(Z)
        ->  true
        ;   (   nonvar(X), nonvar(Y), X =< Y
            ->  kill(MState),
                queue_goal(Z = X)
            ;   true
            ),
            (   nonvar(Z), nonvar(X)
            ->  (   Z = X
                ->  kill(MState),
                    % queue_goal(#Z #=< #Y)
                    { fd_get(Y, YD0, YPs0),
                      domain_remove_smaller_than(YD0, Z, YD1) },
                    fd_put(Y, YD1, YPs0)
                ;   Z < X
                ->  kill(MState),
                    queue_goal(Z = Y)
                ;   false % Z > X
                )
            ;   true
            )
        ).

run_propagator(pmin1(X,Y,Z), MState) -->
        (   nonvar(X), nonvar(Y)
        ->  true
        ;   nonvar(Y), nonvar(Z)
        ->  true
        ;   nonvar(Z), nonvar(X)
        ->  true
        ;   (   { nonvar(X), fd_get(Y, _, n(YL), _, _), X =< YL }
            ->  kill(MState),
                queue_goal(Z = X)
            ;   { fd_get(X, _, _, n(XU), _), nonvar(Y), XU =< Y }
            ->  kill(MState),
                queue_goal(Z = X)
            ;   true
            ),
            (   Z == X, nonvar(Y)
            ->  kill(MState),
                % queue_goal(#Z #=< #Y)
                { fd_get(Z, ZD0, ZPs0),
                  domain_remove_greater_than(ZD0, Y, ZD1) },
                fd_put(Z, ZD1, ZPs0)
            ;   { nonvar(Z), fd_get(X, _, n(XL), _, _), Z < XL }
            ->  kill(MState),
                queue_goal(Z = Y)
            ;   { fd_get(Z, _, _, n(ZU), _), nonvar(X), ZU < X }
            ->  kill(MState),
                queue_goal(Z = Y)
            % ;   nonvar(Z)
            % ->  true % queue_goal((#Z #=< #X, #Z #=< #Y))
            ;   true
            ),
            (   { fd_get(X, _, n(XL), _, _), nonvar(Y), XL =< Y }
            ->  % queue_goal(#Z #>= #XL)
                { fd_get(Z, ZD2, ZPs1),
                  domain_remove_smaller_than(ZD2, XL, ZD3) },
                fd_put(Z, ZD3, ZPs1)
            ;   true
            )
        ).

run_propagator(pmin0(X,Y,Z), MState) -->
        (   nonvar(X)
        ->  true
        ;   nonvar(Y)
        ->  true
        ;   nonvar(Z)
        ->  true
        ;   (   { fd_get(X, _, _, n(XU), _), fd_get(Y, _, n(YL), _, _), XU =< YL }
            ->  kill(MState),
                queue_goal(Z = X)
            ;   true
            ),
            (   Z == X
            ->  kill(MState),
                queue_goal(#Z #=< #Y)
            ;   { fd_get(Z, _, _, n(ZU), _), fd_get(X, _, n(XL), _, _), ZU < XL }
            ->  kill(MState),
                queue_goal(Z = Y)
            ;   true
            ),
            (   { fd_get(X, _, n(XL), _, _), fd_get(Y, _, n(YL), _, _), XL =< YL }
            ->  % queue_goal(#Z #>= #XL)
                { fd_get(Z, ZD2, ZPs1),
                  domain_remove_smaller_than(ZD2, XL, ZD3) },
                fd_put(Z, ZD3, ZPs1)
            ;   true
            )
        ).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% % Z = X ^ Y

run_propagator(pexp(X,Y,Z), MState) -->
        (   X == 1 -> kill(MState), Z = 1
        ;   X == 0 -> kill(MState), queue_goal((Z in 0..1, Y #>= 0, Z #<==> Y #= 0))
        ;   Y == 0 -> kill(MState), Z = 1
        ;   Y == 1 -> kill(MState), Z = X
        ;   Y == Z -> kill(MState), X = Y, queue_goal(X in -1\/1)
        ;   nonvar(X) ->
            (   nonvar(Y) ->
                (   Y >= 0 -> true ; X =:= -1 ),
                kill(MState),
                Z is X^Y
            ;   nonvar(Z) ->
                (   Z > 1 ->
                    abs(X) > 1,
                    kill(MState),
                    { integer_log_b(Z, X, 1, Y) }
                ;   true
                )
            ;   { fd_get(Y, _, YL, YU, _),
                  fd_get(Z, ZD, ZPs) },
                (   { X > 0, YL cis_geq n(0) } ->
                    { NZL cis n(X)^YL,
                      NZU cis n(X)^YU,
                      domains_intersection(ZD, from_to(NZL,NZU), NZD) },
                    fd_put(Z, NZD, ZPs)
                ;   true
                ),
                (   { X > 0,
                      fd_get(Z, _, _, n(ZMax), _),
                      ZMax > 0 } ->
                    { floor_integer_log_b(ZMax, X, 1, YCeil) },
                    queue_goal(Y in inf..YCeil)
                ;   true
                )
            )
        ;   nonvar(Z) ->
            (   nonvar(Y) ->
                { integer_kth_root(Z, Y, R) },
                kill(MState),
                (   { even(Y) } ->
                    N is -R,
                    { X in N \/ R }
                ;   X = R
                )
            ;   { fd_get(X, _, n(NXL), _, _), NXL > 1 } ->
                (   { Z > 1, between(NXL, Z, Exp), NXL^Exp > Z } ->
                    Exp1 is Exp - 1,
                    { fd_get(Y, YD, YPs),
                      domains_intersection(YD, from_to(n(1),n(Exp1)), YD1) },
                    fd_put(Y, YD1, YPs),
                    (   { fd_get(X, XD, XPs) } ->
                        { domain_infimum(YD1, n(YL)),
                          integer_kth_root_leq(Z, YL, RU),
                          domains_intersection(XD, from_to(n(NXL),n(RU)), XD1) },
                        fd_put(X, XD1, XPs)
                    ;   true
                    )
                ;   true
                )
            ;   true
            )
        ;   nonvar(Y), Y > 0 ->
            (   { even(Y) } ->
                { fd_get(Z, ZD0, ZPs0),
                  domain_remove_smaller_than(ZD0, 0, ZDG0) },
                fd_put(Z, ZDG0, ZPs0)
            ;   true
            ),
            (   { fd_get(X, XD, XL, XU, _), fd_get(Z, ZD, ZL, ZU, ZPs) } ->
                (   { domain_contains(ZD, 0) } -> XD1 = XD
                ;   { domain_remove(XD, 0, XD1) }
                ),
                (   { domain_contains(XD, 0) } -> ZD1 = ZD
                ;   { domain_remove(ZD, 0, ZD1) }
                ),
                (   { even(Y) } ->
                    (   { XL cis_geq n(0) } ->
                        { NZL cis XL^n(Y) }
                    ;   { XU cis_leq n(0) } ->
                        { NZL cis XU^n(Y) }
                    ;   NZL = n(0)
                    ),
                    { NZU cis max(abs(XL),abs(XU))^n(Y),
                      domains_intersection(ZD1, from_to(NZL,NZU), ZD2) }
                ;   (   { finite(XL) } ->
                        { NZL cis XL^n(Y),
                          NZU cis XU^n(Y) },
                        { domains_intersection(ZD1, from_to(NZL,NZU), ZD2) }
                    ;   ZD2 = ZD1
                    )
                ),
                fd_put(Z, ZD2, ZPs),
                { (   even(Y), ZU = n(Num) ->
                    integer_kth_root_leq(Num, Y, RU),
                    (   XL cis_geq n(0), ZL = n(Num1), Num1 >= 0 ->
                        integer_kth_root_leq(Num1, Y, RL0),
                        (   RL0^Y < Num1 -> RL is RL0 + 1
                        ;   RL = RL0
                        )
                    ;   RL is -RU
                    ),
                    RL =< RU,
                    NXD = from_to(n(RL),n(RU))
                ;   odd(Y), ZL cis_geq n(0), ZU = n(Num) ->
                    integer_kth_root_leq(Num, Y, RU),
                    ZL = n(Num1),
                    integer_kth_root_leq(Num1, Y, RL0),
                    (   RL0^Y < Num1 -> RL is RL0 + 1
                    ;   RL = RL0
                    ),
                    RL =< RU,
                    NXD = from_to(n(RL),n(RU))
                ;   NXD = XD1   % TODO: propagate more
                ) },
                (   { fd_get(X, XD2, XPs) } ->
                    { domains_intersection(XD2, XD1, XD3),
                      domains_intersection(XD3, NXD, XD4) },
                    fd_put(X, XD4, XPs)
                ;   true
                )
            ;   true
            )
        ;   { fd_get(X, _, XL, _, _),
              XL cis_gt n(0),
              fd_get(Y, _, YL, _, _),
              YL cis_gt n(0),
              fd_get(Z, ZD, ZPs) } ->
            { n(NZL) cis XL^YL,
              domain_remove_smaller_than(ZD, NZL, ZD1) },
            fd_put(Z, ZD1, ZPs)
        ;   true
        ).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% % Y = sign(X)

run_propagator(psign(X,Y), MState) -->
        (   nonvar(X) -> kill(MState), queue_goal(Y is sign(X))
        ;   Y == -1 -> kill(MState), queue_goal(X #< 0)
        ;   Y == 0 -> kill(MState), queue_goal(X = 0)
        ;   Y == 1 -> kill(MState), queue_goal(X #> 0)
        ;   { fd_get(X, _, XL, XU, _) },
            (   { XL = n(L), L > 0 } -> kill(MState), queue_goal(Y = 1)
            ;   { XU = n(U), U < 0 } -> kill(MState), queue_goal(Y = -1)
            ;   true
            )
        ).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% % Z = X xor Y

run_propagator(pxor(X,Y,Z), MState) -->
        (   nonvar(X), nonvar(Y) ->
            kill(MState),
            Z is xor(X, Y)
        ;   nonvar(Y), nonvar(Z) ->
            kill(MState),
            X is xor(Y, Z)
        ;   nonvar(Z), nonvar(X) ->
            kill(MState),
            Y is xor(Z, X)
        ;   X == Y ->
            kill(MState),
            queue_goal(Z = 0)
        ;   Y == Z ->
            kill(MState),
            queue_goal(X = 0)
        ;   Z == X ->
            kill(MState),
            queue_goal(Y = 0)
        ;   X == 0 ->
            kill(MState),
            queue_goal(Y = Z)
        ;   Y == 0 ->
            kill(MState),
            queue_goal(Z = X)
        ;   Z == 0 ->
            kill(MState),
            queue_goal(X = Y)
        ;   true
        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_propagator(pzcompare(Order, A, B), MState) -->
        (   A == B -> kill(MState), Order = (=)
        ;   (   nonvar(A) ->
                (   nonvar(B) ->
                    kill(MState),
                    (   A > B -> Order = (>)
                    ;   Order = (<)
                    )
                ;   { fd_get(B, _, BL, BU, _) },
                    (   { BL cis_gt n(A) } -> kill(MState), Order = (<)
                    ;   { BU cis_lt n(A) } -> kill(MState), Order = (>)
                    ;   []
                    )
                )
            ;   nonvar(B) ->
                { fd_get(A, _, AL, AU, _) },
                (   { AL cis_gt n(B) } -> kill(MState), Order = (>)
                ;   { AU cis_lt n(B) } -> kill(MState), Order = (<)
                ;   []
                )
            ;   { fd_get(A, _, AL, AU, _),
                  fd_get(B, _, BL, BU, _) },
                (   { AL cis_gt BU } -> kill(MState), Order = (>)
                ;   { AU cis_lt BL } -> kill(MState), Order = (<)
                ;   []
                )
            )
        ).
