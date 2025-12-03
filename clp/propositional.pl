/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Propositional Logic
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

% This is an implementation of relational semantics
% (cf. `The Proper Treatment of Undefinedness in Constraint Languages`
% by A. M. Frisch and P. J. Stuckey).

pfml_from_term(T, E) :-
    (   acyclic_term(T),
        '@pfml_from_term'(T, E0)
    ->  E = E0
    ;   throw(error(domain_error(clpz_propositional_formula,T),_))
    ).

'@pfml_from_term'(T, E) :-
    (   var(T)
    ->  (   monotonic
        ->  throw(error(instantiation_error,_))
        ;   E = #T
        )
    ;   integer(T)
    ->  integer_le(0, T),
        integer_le(T, 1),
        % integer_compare(<, -1, T),
        % integer_compare(>, 2, T),
        E = #T
    ;   '@@pfml_from_term'(T, E)
    ).

'@@pfml_from_term'(#T, E) :-
    (   var(T)
    ->  true
    ;   integer(T),
        integer_le(0, T),
        integer_le(T, 1)
    ),
    E = #T.
'@@pfml_from_term'(V in D, E) :-
    (   var(V)
    ->  true
    ;   integer(V)
    ),
    drep(D),
    E = (V in D).
'@@pfml_from_term'(E0 #> E1, E) :-
    armt_from_term(E0, E2),
    armt_from_term(E1, E3),
    E = (E2 #> E3).
'@@pfml_from_term'(E0 #>= E1, E) :-
    armt_from_term(E0, E2),
    armt_from_term(E1, E3),
    E = (E2 #>= E3).
'@@pfml_from_term'(E0 #=< E1, E) :-
    armt_from_term(E0, E2),
    armt_from_term(E1, E3),
    E = (E2 #=< E3).
'@@pfml_from_term'(E0 #< E1, E) :-
    armt_from_term(E0, E2),
    armt_from_term(E1, E3),
    E = (E2 #< E3).
'@@pfml_from_term'(E0 #= E1, E) :-
    armt_from_term(E0, E2),
    armt_from_term(E1, E3),
    E = (E2 #= E3).
'@@pfml_from_term'(E0 #\= E1, E) :-
    armt_from_term(E0, E2),
    armt_from_term(E1, E3),
    E = (E2 #\= E3).
'@@pfml_from_term'(#\ E0, E) :-
    '@pfml_from_term'(E0, E1),
    E = (#\ E1).
'@@pfml_from_term'(E0 #==> E1, E) :-
    '@pfml_from_term'(E0, E2),
    '@pfml_from_term'(E1, E3),
    E = (E2 #==> E3).
'@@pfml_from_term'(E0 #<== E1, E) :-
    '@pfml_from_term'(E0, E2),
    '@pfml_from_term'(E1, E3),
    E = (E2 #<== E3).
'@@pfml_from_term'(E0 #<==> E1, E) :-
    '@pfml_from_term'(E0, E2),
    '@pfml_from_term'(E1, E3),
    E = (E2 #<==> E3).
'@@pfml_from_term'(E0 #/\ E1, E) :-
    '@pfml_from_term'(E0, E2),
    '@pfml_from_term'(E1, E3),
    E = (E2 #/\ E3).
'@@pfml_from_term'(E0 #\/ E1, E) :-
    '@pfml_from_term'(E0, E2),
    '@pfml_from_term'(E1, E3),
    E = (E2 #\/ E3).
'@@pfml_from_term'(tuples_in(Ts, Iss), _) :-
    throw(unimplemented(tuples_in(Ts, Iss))).

pfml_aux(B) -->
    (   { var(B) }
    ->  [a(B)]
    ;   []
    ).

pfml_aux(B0, B) -->
    (   { nonvar(B) }
    ->  []
    ;   { var(B0) }
    ->  [a(B0,B)]
    ;   pfml_aux(B)
    ).

pfml_aux(B0, B1, B) -->
    (   { nonvar(B) }
    ->  []
    ;   { var(B0), var(B1) }
    ->  [a(B0,B1,B)]
    ;   { nonvar(B1) }
    ->  pfml_aux(B0, B)
    ;   { nonvar(B0) }
    ->  pfml_aux(B1, B)
    ;   { false }
    ).

pfml_constrain(#B, B) -->
    { B in 0..1 }.
pfml_constrain(V in D0, B) -->
    {   drep_to_domain(D0, D),
        V in inf..sup, % '@in'(inf..sup, V),
        B in 0..1, % '@in'(0..1, B),
        propagator_from_constraint(bin(D,V,B), P),
        term_variables([V,B], Vs),
        propagator_trigger(P, Vs)
    },
    [p(P)],
    pfml_aux(B).
pfml_constrain(tuples_in(_, _), _) -->
    { throw(unimplemented) }.
% pfml_constrain(E0 #==> E1, B) -->
%     pfml_constrain(E0, B0),
%     pfml_constrain(E1, B1),
%     {   B in 0..1, % '@in'(0..1, B),
%         propagator_from_constraint(bimp(B0,B1,B), P),
%         term_variables([B0,B1,B], Vs),
%         propagator_trigger(P, Vs)
%     },
%     [p(P)],
%     pfml_aux(B0, B1, B).
pfml_constrain(E0 #==> E1, B) -->
    pfml_constrain(#\ E0 #\/ E1, B).
pfml_constrain(E0 #<== E1, B) -->
    pfml_constrain(E1 #==> E0, B).
pfml_constrain(E0 #<==> E1, B) -->
    pfml_constrain(E0, B0),
    pfml_constrain(E1, B1),
    {   B in 0..1, % '@in'(0..1, B),
        propagator_from_constraint(beqv(B0,B1,B), P),
        term_variables([B0,B1,B], Vs),
        propagator_trigger(P, Vs)
    },
    [p(P)],
    pfml_aux(B0, B1, B).
pfml_constrain(E0 #/\ E1, B) -->
    pfml_boolean(band, E0, E1, B).
pfml_constrain(E0 #\/ E1, B) -->
    pfml_boolean(bior, E0, E1, B).
pfml_constrain(#\ E0, B) -->
    pfml_constrain(E0, B0),
    {   B in 0..1, % '@in'(0..1, B),
        propagator_from_constraint(bnot(B0,B), P),
        term_variables([B0,B], Vs),
        propagator_trigger(P, Vs)
    },
    [p(P)],
    pfml_aux(B).
pfml_constrain(E0 #> E1, B) -->
    pfml_constrain(E1 #< E0, B).
pfml_constrain(E0 #>= E1, B) -->
    pfml_constrain(E1 #=< E0, B).
pfml_constrain(E0 #=< E1, B) -->
    pfml_arithmetic(ble, E0, E1, B).
pfml_constrain(E0 #< E1, B) -->
    pfml_arithmetic(blt, E0, E1, B).
pfml_constrain(E0 #= E1, B) -->
    pfml_arithmetic(beq, E0, E1, B).
pfml_constrain(E0 #\= E1, B) -->
    pfml_arithmetic(bne, E0, E1, B).

pfml_negate(V in D, #\ V in D).
pfml_negate(#B, #\ #B).
pfml_negate(#\E, E).
pfml_negate(E0 #/\ E1, E2 #\/ E3) :-
    pfml_negate(E0, E2),
    pfml_negate(E1, E3).
pfml_negate(E0 #==> E1, E) :-
    pfml_negate(#\E0 #\/ E1, E).
pfml_negate(E0 #<== E1, E) :-
    pfml_negate(E1 #==> E0, E).
% pfml_negate(E0 #<==> E1, E0 #</> E1).
% pfml_negate(E0 #</> E1, E0 #<==> E1).
pfml_negate(E0 #= E1, E0 #\= E1).
pfml_negate(E0 #\= E1, E0 #= E1).
pfml_negate(E0 #=< E1, E0 #> E1).
pfml_negate(E0 #< E1, E0 #>= E1).
pfml_negate(E0 #>= E1, E0 #< E1).
pfml_negate(E0 #> E1, E0 #=< E1).

pfml_boolean(N, E0, E1, B) -->
    {   phrase(pfml_constrain(E0, B0), Ps0),
        phrase(pfml_constrain(E1, B1), Ps1),
        C =.. [N,B0,Ps0,B1,Ps1,B]
    },
    map(identity, Ps0),
    map(identity, Ps1),
    {   B in 0..1, % '@in'(0..1, B),
        propagator_from_constraint(C, P),
        propagator_trigger(P, [B0,B1,B])
    },
    [p(P)],
    pfml_aux(B0, B1, B).

% pfml_arithmetic(N, E0, E1, B) -->
%     {   phrase(
%             (pfml_armt_constrain(B0, E0, E2), pfml_armt_constrain(B1, E1, E3)),
%             Ps
%         ),
%         C =.. [N,B0,E2,B1,E3,Ps,B],
%         propagator_from_constraint(C, P),
%         propagator_trigger(P, [B0,B1,B])
%     },
%     map(identity, Ps),
%     pfml_aux(B).
pfml_arithmetic(N, E0, E1, B) -->
    {   phrase(pfml_armt_constrain(B0, E0, E2), Ps0),
        phrase(pfml_armt_constrain(B1, E1, E3), Ps1)
    },
    {   B2 in 0..1,
        % propagator_from_constraint(band(B0,Ps0,B1,Ps1,B2), P0),
        propagator_from_constraint(band(B0,[],B1,[],B2), P0), % Alternative.
        propagator_trigger(P0, [B0,B1,B2])
    },
    {   phrase(
            (   map(identity, Ps0),
                map(identity, Ps1),
                [p(P0)],
                pfml_aux(B2)
            ),
            Ps2
        )
    },
    {   B3 in 0..1,
        C =.. [N,B3,E2,E3],
        propagator_from_constraint(C, P1),
        propagator_trigger(P1, [B3,E3,E2])
    },
    { phrase(([p(P1)], pfml_aux(B3)), Ps3) },
    {   B in 0..1,
        list_append(Ps3, Ps2, Ps),
        propagator_from_constraint(band(B2,[],B3,Ps,B), P),
        propagator_trigger(P, [B2,B3,B])
        % In `beq(B2,Ps,E2,E3,B)`, B3 == B
    },
    map(identity, Ps2),
    map(identity, Ps3),
    [p(P)],
    pfml_aux(B).

% pfml_arithmetic(E0, E, B) -->
%     {   phrase(pfml_armt_constrain(B0, E0, E1)), Ps0),
%         B in 0..1
%     },
%     [p

pfml_armt_constraints([
    B #<==> E #= E0+E1      => B-[c(iadd(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= E0-E1      => B-[c(iadd(E,E1,E0)),a(E0,E1,E)],
    B #<==> E #= E0*E1      => B-[c(imul(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= E0/E1      => B-[c(imul(E,E1,E0)),a(E0,E1,E)],
    B #<==> E #= E0^E1      =>
        B0-[
            p(E0 in {-1,1} #\/ E1 in 0..sup,B1),
            c(bdly(B1,#E0 ^ #E1 #= #E)),
            c(band(B0,[],B1,[],B)),
            a(E0,E1,E)
        ],
        % B0-[
        %     B1 in 0..1,
        %     c(bexp(B1,E0,E1,E)),
        %     c(band(B0,[],B1,[],B)),
        %     a(B1),a(E0,E1,E)
        % ],
    B #<==> E #= min(E0,E1) =>
        B-[c(pleq(E,E0)),c(pleq(E,E1)),c(imin(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= max(E0,E1) =>
        B-[c(pleq(E0,E)),c(pleq(E1,E)),c(imax(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= E0 div E1  =>
        B0-[
            e(B1,(#E0 - #E0 mod #E1) / #E1,E),
            c(band(B0,[],B1,[],B)),
            a(B1),a(E0,E1,E)
        ],
    B #<==> E #= E0 mod E1  =>
        B0-[
            p(E1 in \{0},B1),
            c(bdly(B1,#E0 mod #E1 #= #E)),
            c(band(B0,[],B1,[],B)),
            a(E0,E1,E)
        ],
        % B0-[
        %     B1 in 0..1,
        %     c(bmod(B1,E0,E1,E)),
        %     c(band(B0,[],B1,[],B)),
        %     a(B1),a(E0,E1,E)
        % ],
    B #<==> E #= E0//E1     =>
        B0-[
            e(B1,(#E0 - #E0 rem #E1) / #E1,E),
            c(band(B0,[],B1,[],B)),
            a(B1),a(E0,E1,E)
        ],
    B #<==> E #= E0 rem E1  =>
        B0-[
            p(E1 in \{0},B1),
            c(bdly(B1,#E0 rem #E1 #= #E)),
            c(band(B0,[],B1,[],B)),
            a(E0,E1,E)
        ],
        % B0-[
        %     B1 in 0..1,
        %     c(brem(B1,E0,E1,E)),
        %     c(band(B0,[],B1,[],B)),
        %     a(B1),a(E0,E1,E)
        % ],
    B #<==> E #= -E0        =>
        B0-[e(B1,#E + #E0,0),c(band(B0,[],B1,[],B)),a(B1),a(E0,E)],
    B #<==> E #= abs(E0)    => B-[E in 0..sup,c(iabs(E0,E)),a(E0,E)],
    B #<==> E #= sign(E0)   => B-[E in -1..1,c(isgn(E0,E)),a(E0,E)],
    % bitwise operations
    B #<==> E #= E0<<E1     => B-[c(ishl(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= E0>>E1     => B-[c(ishr(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= E0/\E1     => B-[c(iand(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= E0\/E1     => B-[c(iior(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= xor(E0,E1) => B-[c(ixor(E0,E1,E)),a(E0,E1,E)],
    B #<==> E #= \E0        => B-[c(ixor(-1,E0,E)),a(E0,E)],
    B #<==> E #= lsb(E0)    =>
        B0-[
            E in 0..sup,
            p(E0 in 1..sup,B1),
            c(bdly(B1,lsb(#E0) #= #E)),
            c(band(B0,[],B1,[],B)),
            a(E0,E1,E)
        ],
        % B0-[B1 in 0..1,c(blsb(B1,E0,E)),c(band(B0,[],B1,[],B)),a(B1),a(E0,E)],
    B #<==> E #= '@msb'(E0)    => B-[c(imsb(E0,E)),a(E0,E)],
    B #<==> E #= msb(E0)    =>
        B0-[
            E in 0..sup,
            p(E0 in 1..sup,B1),
            c(bdly(B1,msb(#E0) #= #E)),
            c(band(B0,[],B1,[],B)),
            a(E0,E1,E)
        ],
        % B0-[B1 in 0..1,c(bmsb(B1,E0,E)),c(band(B0,[],B1,[],B)),a(B1),a(E0,E)],
    B #<==> E #= popcount(E0) =>
        B0-[
            E in 0..sup,
            p(E0 in 0..sup,B1),
            c(bdly(B1,popcount(#E0) #= #E)),
            c(band(B0,[],B1,[],B)),
            a(E0,E)
        ]
        % B0-[B1 in 0..1,c(bct1(B1,E0,E)),c(band(B0,[],B1,[],B)),a(B1),a(E0,E)]
]).

'@pfml_armt_constraint'(V in D0) -->
    { drep_to_domain(D0, D) },
    [{ '@in'(D, V) }].
'@pfml_armt_constraint'(c(C)) -->
    { term_variables(C, Vs) },
    [{  propagator_from_constraint(C, P),
        propagator_trigger(P, Vs)
    }],
    [({ propagator_dead(P) } -> [] ; [p(P)])].
% '@pfml_armt_constraint'(c(C)) -->
%     { term_variables(C, Vs) },
%     [{  propagator_from_constraint(C, P),
%         % list_map(propagator_variable(P), Vs), % The queue?
%         % queue_unify(Vs),
%         % propagator_trigger(P, [])
%         propagator_trigger(P, Vs) % QUESTION: What is the difference?
%     }],
%     [({ propagator_dead(P) } -> [] ; [p(P)])].
% '@pfml_armt_constraint'(e(B,E0,E)) --> [pfml_constrain(B, E0, E)].
'@pfml_armt_constraint'(p(E,B)) --> [pfml_constrain(E, B)].
'@pfml_armt_constraint'(e(B,E0,E)) --> [pfml_armt_constrain(B, E0, E)].
'@pfml_armt_constraint'(a(E)) --> [pfml_aux(E)].
'@pfml_armt_constraint'(a(E0,E)) --> [pfml_aux(E0,E)].
'@pfml_armt_constraint'(a(E0,E1,E)) --> [pfml_aux(E0,E1,E)].

pfml_conjunction(P0, P, P0#/\P).
pfml_disjunction(P0, P, P0#\/P).

pfml_armt_goal([E1,E0], G, B) :-
    G = pfml_armt_constrain(B, E1, E0).

% pfml_armt_define0(0, _, 0).
% pfml_armt_define0(1, B, B).
% 
% pfml_armt_define(B0, B1, B) -->
%     (   { var(B0), var(B1) }
%     ->  {   B in 0..1,
%             propagator_from_constraint(band(B0,[],B1,[],B), P),
%             propagator_trigger(P, [B0,B1,B])
%         },
%         (   { propagator_dead(P) }
%         ->  []
%         ;   [p(P)]
%         )
%     ;   { nonvar(B0), var(B1) }
%     ->  { pfml_armt_define0(B0, B1, B) }
%     ;   { var(B0), nonvar(B1) }
%     ->  { pfml_armt_define0(B1, B0, B) }
%     ;   { nonvar(B0), nonvar(B1) },
%         { pfml_armt_define0(B0, B1, B) }
%     ).

pfml_defined([B], B) --> [].
pfml_defined([B0,B1], B) -->
    % { drep_to_domain(0..1, D) },
    [   {   B in 0..1,
            propagator_from_constraint(band(B0,[],B1,[],B), P),
            propagator_trigger(P, [B0,B1,B])
        },
        (   { propagator_dead(P) }
        ->  []
        ;   [p(P)]
        )
    ].

pfml_armt_clause1(B #<==> E #= E0 => B0-Is) -->
    {   copy_term(E0, E1),
        E0 =.. [N|Es0],
        E1 =.. [N|Es1],
        % list_equisized(Es0, Bs),
        list_transpose([Bs,Es1,Es0], Ess),
        list_map(armt_goal(pfml_armt_constrain), Ess, Gs0),
        % list_transpose([Es1,Es0], Ess),
        % list_map(pfml_armt_goal, Ess, Gs0, Bs),
        phrase(
            (   map(identity, Gs0),
                pfml_defined(Bs, B0),
                [{ B in 0..1, E in inf..sup }],
                map('@pfml_armt_constraint', Is)
            ),
            Gs
        ),
        % Gs \== [],
        goals_goal(',', Gs, Body)
    },
    [(pfml_armt_constrain(B, E1, E) --> Body)].

term_expansion(pfml_armt_constrain) -->
    { drep_to_domain(inf..sup, D), pfml_armt_constraints(Is) },
    % [(pfml_armt_constrain(1, #E, E) --> { E in inf..sup })],
    [(pfml_armt_constrain(1, #E, E) --> { '@in'(D, E) })],
    map(pfml_armt_clause1, Is).

pfml_armt_constrain.

% ?- term_expansion(pfml_armt_constrain, Cs, []), list_element(Cs, C), portray_clause(user_output, C), false.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Propositional logic
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

delay(B, T) :-
    B in 0..1,
    functor(T, N, A),
    (   member(N/A, [(#=)/2,(#\=)/2,(#=<)/2,(#<)/2,(#>)/2,(#>=)/2]),
        pfml_from_term(T, G)
    ->  true
    ;   throw(error(domain_error(clpz_propositional_formula,T),_))
    ),
    propagator_from_constraint(bdly(B,G), P),
    propagator_trigger(P, [B]).

%% #\(+Q)
%
% The reifiable constraint Q does _not_ hold. For example, to obtain
% the complement of a domain:
%
% ```
% ?- #\ X in -3..0\/10..80.
% X in inf.. -4\/1..9\/81..sup.
% ```

#\ P0 :-
    catch(pfml_from_term(P0, P), error(E,_), throw(error(E,(#\)/1))),
    phrase(pfml_constrain(#\P, 1), _).

%% #<==>(?P, ?Q)
%
% P and Q are equivalent. For example:
%
% ```
% ?- X #= 4 #<==> B, X #\= 4.
% B = 0,
% X in inf..3\/5..sup.
% ```
% The following example uses reified constraints to relate a list of
% finite domain variables to the number of occurrences of a given value:
%
% ```
% vs_n_num(Vs, N, Num) :-
%         list_map(eq_b(N), Vs, Bs),
%         sum(Bs, #=, Num).
%
% eq_b(X, Y, B) :- X #= Y #<==> B.
% ```
%
% Sample queries and their results:
%
% ```
% ?- Vs = [X,Y,Z], Vs ins 0..1, vs_n_num(Vs, 4, Num).
% Vs = [X, Y, Z],
% Num = 0,
% X in 0..1,
% Y in 0..1,
% Z in 0..1.
%
% ?- vs_n_num([X,Y,Z], 2, 3).
% X = 2,
% Y = 2,
% Z = 2.
% ```

P0 #<==> P1 :-
    catch(pfml_from_term(P0, P2), error(E,_), throw(error(E,(#<==>)/2))),
    catch(pfml_from_term(P1, P3), error(E,_), throw(error(E,(#<==>)/2))),
    phrase(pfml_constrain(P2#<==>P3, 1), _).

%% #==>(?P, ?Q)
%
% P implies Q.

P0 #==> P1 :-
    catch(pfml_from_term(P0, P2), error(E,_), throw(error(E,(#==>)/2))),
    catch(pfml_from_term(P1, P3), error(E,_), throw(error(E,(#==>)/2))),
    phrase(pfml_constrain(P2#==>P3, 1), _).

%% #<==(?P, ?Q)
%
% Q implies P.

P0 #<== P1 :- P1 #==> P0.

%% #/\(?P, ?Q)
%
% P and Q hold.

P0 #/\ P1 :-
    catch(pfml_from_term(P0, P2), error(E,_), throw(error(E,(#/\)/2))),
    catch(pfml_from_term(P1, P3), error(E,_), throw(error(E,(#/\)/2))),
    phrase(pfml_constrain(P2#/\P3, 1), _).

%% #\/(?P, ?Q)
%
% P or Q holds. For example, the sum of natural numbers below 1000
% that are multiples of 3 or 5:
%
% ```
% ?- findall(N, (N mod 3 #= 0 #\/ N mod 5 #= 0, N in 0..999,
%                indomain(N)),
%            Ns),
%    sum(Ns, #=, Sum).
% Ns = [0, 3, 5, 6, 9, 10, 12, 15, 18|...],
% Sum = 233168.
% ```

P0 #\/ P1 :-
    catch(pfml_from_term(P0, P2), error(E,_), throw(error(E,(#\/)/2))),
    catch(pfml_from_term(P1, P3), error(E,_), throw(error(E,(#\/)/2))),
    phrase(pfml_constrain(P2#\/P3, 1), _).



% parse_reified_clpz(E0+E1, E, D) -->
%     !,
%     parse_reified_clpz(E0, E2, D0),
%     parse_reified_clpz(E1, E3, D1),
%     (   { D0 == 1, D1 == 1 }
%     ->  { D = 1 }
%     ;   {   propagator_from_constraint(reified_and(D0,[],D1,[],D), P0),
%             list_map(propagator_variable(P0), [D0,D1,D]),
%             queue_unify([D0,D1,D]),
%             propagator_trigger(P0, [])
%         },
%         (   { propagator_dead(P0) }
%         ->  []
%         ;   [p(P0)]
%         )
%     ),
%     {   propagator_from_constraint(iadd(E2,E3,E), P),
%         list_map(propagator_variable(P), [E2,E3,E]),
%         queue_unify([E2,E3,E]),
%         propagator_trigger(P, [])
%     },
%     (   { propagator_dead(P) }
%     ->  []
%     ;   [p(P)]
%     ),
%     a(E2, E3, E),
%     a(D).
% parse_reified_clpz(E0*E1,E,D)-->!,parse_reified_clpz(E0,E2,D0),parse_reified_clpz(E1,E3,D1),({D0==1,D1==1}->{_D=1};{propagator_from_constraint(reified_and(D0,[],D1,[],_D),P0)},{propagator_variable(P0,D0)},{propagator_variable(P0,D1)},{propagator_variable(P0,_D)},{queue_unify([D0,D1,_D]),propagator_trigger(P0,[])},({propagator_dead(P0)}->[];[p(P0)]),true),{propagator_from_constraint(imul(E2,E3,E),P)},{propagator_variable(P,E2)},{propagator_variable(P,E3)},{propagator_variable(P,E)},{queue_unify([E2,E3,E]),propagator_trigger(P,[])},({propagator_dead(P)}->[];[p(P)]),a(E2,E3,E),a(_D),true.
% parse_reified_clpz(E0-E1,E,D)-->!,parse_reified_clpz(E0,E2,D0),parse_reified_clpz(E1,E3,D1),({D0==1,D1==1}->{_D=1};{propagator_from_constraint(reified_and(D0,[],D1,[],_D),P0)},{propagator_variable(P0,D0)},{propagator_variable(P0,D1)},{propagator_variable(P0,_D)},{queue_unify([D0,D1,_D]),propagator_trigger(P0,[])},({propagator_dead(P0)}->[];[p(P0)]),true),{propagator_from_constraint(iadd(E,E3,E2),P)},{propagator_variable(P,E)},{propagator_variable(P,E3)},{propagator_variable(P,E2)},{queue_unify([E,E3,E2]),propagator_trigger(P,[])},({propagator_dead(P)}->[];[p(P)]),a(E2,E3,E),a(_D),true.
% parse_reified_clpz(-E0,E1,E)-->!,parse_reified_clpz(E0,D,E2),{E=E2},{propagator_from_constraint(iadd(_D,E1,0),D0)},{propagator_variable(D0,_D)},{propagator_variable(D0,E1)},{queue_unify([_D,E1]),propagator_trigger(D0,[])},({propagator_dead(D0)}->[];[p(D0)]),a(E1),a(E),true.
% parse_reified_clpz(max(E0,E1),E,D)-->!,parse_reified_clpz(E0,E2,D0),parse_reified_clpz(E1,E3,D1),({D0==1,D1==1}->{_D=1};{propagator_from_constraint(reified_and(D0,[],D1,[],_D),P0)},{propagator_variable(P0,D0)},{propagator_variable(P0,D1)},{propagator_variable(P0,_D)},{queue_unify([D0,D1,_D]),propagator_trigger(P0,[])},({propagator_dead(P0)}->[];[p(P0)]),true),{propagator_from_constraint(pleq(E2,E),P)},{propagator_variable(P,E2)},{propagator_variable(P,E)},{queue_unify([E2,E]),propagator_trigger(P,[])},({propagator_dead(P)}->[];[p(P)]),{propagator_from_constraint(pleq(E3,E),K)},{propagator_variable(K,E3)},{propagator_variable(K,E)},{queue_unify([E3,E]),propagator_trigger(K,[])},({propagator_dead(K)}->[];[p(K)]),{propagator_from_constraint(imax(E2,E3,E),L)},{propagator_variable(L,E2)},{propagator_variable(L,E3)},{propagator_variable(L,E)},{queue_unify([E2,E3,E]),propagator_trigger(L,[])},({propagator_dead(L)}->[];[p(L)]),a(E2,E3,E),a(_D),true.

% parse_reified_clpz(E0^E1, E, D) -->
%     !,
%     parse_reified_clpz(E0, E2, D0),
%     parse_reified_clpz(E1, E3, D1),
%     (   { D0 == 1, D1 == 1 }
%     ->  { D2 = 1 }
%     ;   {   propagator_from_constraint(reified_and(D0,[],D1,[],D2), P0),
%             list_map(propagator_variable(P0), [D0,D1,D2]),
%             queue_unify([D0,D1,D2]),
%             propagator_trigger(P0, [])
%         },
%         (   { propagator_dead(P0) }
%         ->  []
%         ;   [p(P0)]
%         )
%     ),
%     {   propagator_from_constraint(preified_exp(E2,E3,D3,E), P1),
%         list_map(propagator_variable(P1), [E2,E3,D3,E]),
%         queue_unify([E2,E3,D3,E]),
%         propagator_trigger(P1, [])
%     },
%     (   { propagator_dead(P1) }
%     ->  []
%     ;   [p(P1)]
%     ),
%     {   propagator_from_constraint(reified_and(D2,[],D3,[],D), P),
%         list_map(propagator_variable(P), [D2,D3,D]),
%         queue_unify([D2,D3,D]),
%         propagator_trigger(P, [])
%     },
%     (   { propagator_dead(P) }
%     ->  []
%     ;   [p(P)]
%     ),
%     a(D3),
%     a(E2,E3,E),
%     a(D).
