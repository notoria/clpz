/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Constraint
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

constraint_wake(pneq, ground).
constraint_wake(x_neq_y_plus_z, ground).
constraint_wake(absdiff_neq, ground).
constraint_wake(pdifferent, ground).
constraint_wake(pexclude, ground).
constraint_wake(scalar_product_neq, ground).
constraint_wake(x_eq_abs_plus_v, ground).

constraint_wake(x_leq_y_plus_c, bounds).
constraint_wake(scalar_product_eq, bounds).
constraint_wake(scalar_product_leq, bounds).
constraint_wake(iadd, bounds).
constraint_wake(imin, bounds).
constraint_wake(imax, bounds).
constraint_wake(pleq, bounds).
constraint_wake(pgcc_single, bounds).
constraint_wake(pgcc_check_single, bounds).

constraint_global(pdistinct).
constraint_global(pnvalue).
constraint_global(pgcc).
constraint_global(pgcc_single).
constraint_global(pcircuit).
%constraint_global(rel_tuple).
%constraint_global(scalar_product_eq).

% constraint_trigger(C) -->
%     { term_variables(C, Vs) },
%     constraint_trigger(Vs, C).
% 
% constraint_trigger(Vs, C) -->
%     [p(P)],
%     {   propagator_from_constraint(C, P), % wrong place.
%         queue_empty(Q0),
%         % phrase(map(propagator_variable(P), Vs), [Q0], [Q]),
%         % queue_unify(Vs),
%         % trigger_once_(P, Q)
%         phrase(
%             (   map(propagator_variable(P), Vs),
%                 { queue_unify(Vs) },
%                 propagator_queue(P),
%                 propagator_catalyze
%             ),
%             [Q0],
%             _
%         )
%     }.
% 
% constraint_trigger(C) :-
%     phrase(constraint_trigger(C), _).
% 
% constraint_trigger(Vs, C) :-
%     phrase(constraint_trigger(Vs, C), _).

% constraint projection
constraint_goals(presidual(Goal))        --> [Goal].
constraint_goals(pleq(X,Y))              --> [#X #=< #Y].
constraint_goals(pneq(X,Y))              --> [#X #\= #Y].
constraint_goals(iadd(X,Y,Z))            --> [#X + #Y #= #Z].
constraint_goals(imul(X,Y,Z))            --> [#X * #Y #= #Z].
constraint_goals(iexp(X,Y,Z))            --> [#X ^ #Y #= #Z].
constraint_goals(imin(X,Y,Z))            --> [min(#X,#Y) #= #Z].
constraint_goals(imax(X,Y,Z))            --> [max(#X,#Y) #= #Z].
constraint_goals(imod(X,Y,Z))            --> [#X mod #Y #= #Z].
constraint_goals(irem(X,Y,Z))            --> [#X rem #Y #= #Z].
constraint_goals(iabs(X,Y))              --> [abs(#X) #= #Y].
constraint_goals(isgn(X,Y))              --> [sign(#X) #= #Y].
constraint_goals(ishl(X,Y,Z))            --> [#X << #Y #= #Z].
constraint_goals(ishr(X,Y,Z))            --> [#X >> #Y #= #Z].
constraint_goals(iand(X,Y,Z))            --> [#X /\ #Y #= #Z].
constraint_goals(iior(X,Y,Z))            --> [#X \/ #Y #= #Z].
constraint_goals(ixor(X,Y,Z))            --> [xor(#X,#Y) #= #Z].
constraint_goals(imsb(X,Y))              --> [msb(#X) #= #Y].
constraint_goals(ilsb(X,Y))              --> [lsb(#X) #= #Y].
constraint_goals(ict1(X,Y))              --> [popcount(#X) #= #Y].
constraint_goals(bin(D0,V,B))            -->
        [V in D #<==> #B],
        { drep_from_domain(D0, D) }.
constraint_goals(band(X,_,Y,_,Z))        --> [#X #/\ #Y #<==> #Z].
constraint_goals(bior(X,_,Y,_,Z))        --> [#X #\/ #Y #<==> #Z].
constraint_goals(bnot(X,Y))              --> [#\ #X #<==> #Y].
constraint_goals(bexp(B,X,Y,Z))          --> [abs(#X) #\= #1 #\/ Y in 0..sup #==> #B,#X ^ #Y #= #Z].
constraint_goals(bmod(B,X,Y,Z))          --> [#Y #\= #0 #==> #B,#X mod #Y #= #Z].
constraint_goals(blsb(B,X,Y))            --> [X in 1..sup #==> #B,lsb(#X) #= #Y].
constraint_goals(bmsb(B,X,Y))            --> [X in 1..sup #==> #B,msb(#X) #= #Y].
constraint_goals(bct1(B,X,Y))            --> [X in 0..sup #==> #B,popcount(#X) #= #Y].
constraint_goals(bdly(B,G))              --> [delay(B,G)].
constraint_goals(beqv(B0,B1,B))          --> [(#B0 #<==> #B1) #<==> #B].
constraint_goals(beq(B,X,Y))             --> [#X #= #Y #<==> #B].
constraint_goals(bne(B,X,Y))             --> [#X #\= #Y #<==> #B].
constraint_goals(ble(B,X,Y))             --> [#X #=< #Y #<==> #B].
constraint_goals(blt(B,X,Y))             --> [#X #< #Y #<==> #B].
constraint_goals(absdiff_neq(X,Y,C))     --> [abs(#X - #Y) #\= C].
constraint_goals(x_eq_abs_plus_v(X,V))   --> [#X #= abs(#X) + #V].
constraint_goals(x_neq_y_plus_z(X,Y,Z))  --> [#X #\= #Y + #Z].
constraint_goals(x_leq_y_plus_c(X,Y,C))  --> [#X #=< #Y + C].
constraint_goals(ptzdiv(X,Y,Z))          --> [#X // #Y #= #Z].
constraint_goals(scalar_product_neq(Cs,Vs,C)) -->
        [Left #\= Right],
        { scalar_product_left_right([-1|Cs], [C|Vs], Left, Right) }.
constraint_goals(scalar_product_eq(Cs,Vs,C)) -->
        [Left #= Right],
        { scalar_product_left_right([-1|Cs], [C|Vs], Left, Right) }.
constraint_goals(scalar_product_leq(Cs,Vs,C)) -->
        [Left #=< Right],
        { scalar_product_left_right([-1|Cs], [C|Vs], Left, Right) }.
constraint_goals(pdifferent(_,_,_,O))    --> constraint_goals_original(O).
constraint_goals(weak_distinct(_,_,_,O)) --> constraint_goals_original(O).
constraint_goals(pdistinct(Vs))          --> [all_distinct(Vs)].
constraint_goals(pnvalue(N,Vs))          --> [nvalue(N, Vs)].
constraint_goals(pexclude(_,_,_))        --> [].
constraint_goals(pelement(N,Is,V))       --> [element(N, Is, V)].
constraint_goals(pgcc(Vs,Pairs,_))       --> [global_cardinality(Vs, Pairs)].
constraint_goals(pgcc_single(_,_))       --> [].
constraint_goals(pgcc_check_single(_))   --> [].
constraint_goals(pgcc_check(Pairs))      -->
        { pairs_values(Pairs, Nums),
          list_map(gcc_done, Nums) }.
constraint_goals(pcircuit(Vs))           --> [circuit(Vs)].
constraint_goals(pserialized(_,_,_,_,O)) --> constraint_goals_original(O).
constraint_goals(rel_tuple(R,Tuple))     -->
        { get_attr(R, clpz_relation, Rel) },
        [tuples_in([Tuple], Rel)],
        { del_attr(R, clpz_relation) }.
constraint_goals(pzcompare(O,A,B))       --> [zcompare(O,A,B)].
% reified constraints
constraint_goals(reified_in(V,D,B))      -->
        [V in Drep #<==> #B],
        { drep_from_domain(D, Drep) }.
constraint_goals(reified_tuple_in(Tuple,R,B)) -->
        { get_attr(R, clpz_relation, Rel) },
        [tuples_in([Tuple], Rel) #<==> #B].
constraint_goals(kill_reified_tuples(_,_,_)) --> [].
constraint_goals(tuples_not_in(_,_,_))   --> [].
constraint_goals(reified_fd(V,B))        --> [finite_domain(V) #<==> #B].
constraint_goals(pskeleton(X,Y,D,_,Z,F)) -->
        { C =.. [F,X,Y,Z],
          phrase(constraint_goals(C), Goals),
          goals_goal(',', Goals, Goal) },
        [#D #= 1 #==> Goal, #Y #\= 0 #==> #D #= 1].
constraint_goals(reified_neq(DX,X,DY,Y,_,B)) -->
        constraint_goals_conjunction(DX, DY, #X #\= #Y, B).
constraint_goals(reified_eq(DX,X,DY,Y,_,B))  -->
        constraint_goals_conjunction(DX, DY, #X #= #Y, B).
constraint_goals(reified_geq(DX,X,DY,Y,_,B)) -->
        constraint_goals_conjunction(DX, DY, #X #>= #Y, B).
constraint_goals(reified_and(X,_,Y,_,B)) --> [#X #/\ #Y #<==> #B].
constraint_goals(reified_or(X,_,Y,_,B))  --> [#X #\/ #Y #<==> #B].
constraint_goals(reified_not(X,Y))       --> [#\ #X #<==> #Y].
constraint_goals(preified_slash(X,Y,_,R)) --> [#X/ #Y #= R].
constraint_goals(preified_exp(X,Y,_,R))  --> [#X^ #Y #= R].
constraint_goals(pimpl(X,Y,_))           --> [#X #==> #Y].
constraint_goals(pfunction(Op,A,B,R))    -->
        { Expr =.. [Op,#A,#B] },
        [#R #= Expr].
constraint_goals(pfunction(Op,A,R))      -->
        { Expr =.. [Op,#A] },
        [#R #= Expr].

constraint_goals_conjunction(A, B, G, D) -->
        (   { A == 1, B == 1 } -> [G #<==> #D]
        ;   { A == 1 } -> [(#B #/\ G) #<==> #D]
        ;   { B == 1 } -> [(#A #/\ G) #<==> #D]
        ;   [(#A #/\ #B #/\ G) #<==> #D]
        ).

constraint_goals_original(original_goal(State,Goal)) -->
    (   { var(State) }
    ->  { State = processed },
        [Goal]
    ;   []
    ).

constraint_once(rel_tuple(_,_)).
constraint_once(pdistinct(_)).
constraint_once(pnvalue(_)).
constraint_once(pgcc(_,_,_)).
constraint_once(pgcc_single(_,_)).
%constraint_once(scalar_product(_,_,_,_)).
