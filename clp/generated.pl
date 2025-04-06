/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Generated predicates
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

generated_clauses(Cs) :-
        make_parse_clpz(Cs1),
        make_parse_reified(Cs2),
        make_matches(Cs3),
        append([Cs1,Cs2,Cs3], Cs).

% :- initialization((generated_clauses(Cs),maplist(assertz, Cs))).

cutless(Cs0, Cs) :-
    maplist(pclause, Cs0, Cs1),
    pmerge(Cs1, Cs2),
    maplist(arg(2), Cs2, Cs3),
    maplist(disj, Cs3, Cs).

disj(Cs0, (H:-G)) :-
    maplist(if_then, Cs0, Cs1),
    maplist(arg(2), Cs1, Gs),
    goals_goal(';', Gs, G),
    [(H:-_)|_] = Cs0.

unfold(G) -->
    (   { \+ subsumes_term((_,_), G) }
    ->  [G]
    ;   { G = (G0,G1) },
        unfold(G0), unfold(G1)
    ).

pclause((H0:-G), H-[(H:-(H0=H),G)]) :-
    functor(H0, N, A),
    functor(H, N, A).

pmerge(Cs0, Cs) :-
    (   foldl(select, [H-C0,H-C1], Cs0, Cs1)
    ->  append(C0, C1, C),
        pmerge([H-C|Cs1], Cs)
    ;   Cs = Cs0
    ).

if_then((H:-G0), (H:-G)) :-
    (   phrase(unfold(G0), Gs0),
        phrase((seq(Gs1), [!], seq(Gs2)), Gs0)
    ->  goals_goal(',', Gs1, G1),
        goals_goal(',', Gs2, G2),
        G = (G1->G2)
    ;   G = G0
    ).

goals_goal(',', Gs0, G) :-
    reverse(Gs0, Gs1),
    foldl(goal(','), Gs1, true, G).
goals_goal(';', Gs0, G) :-
    reverse(Gs0, Gs1),
    foldl(goal(';'), Gs1, false, G).

goal(',', G, S, (G,S)).
goal(';', G, S, (G;S)).

term_expansion(make_parse_clpz, Ts0, Ts)    :- make_parse_clpz(Cs0), cutless(Cs0, Cs), append(Cs, Ts, Ts0).
term_expansion(make_parse_reified, Ts0, Ts) :- make_parse_reified(Cs0), cutless(Cs0, Cs), append(Cs, Ts, Ts0).
term_expansion(make_matches, Ts0, Ts)       :- make_matches(Cs0), cutless(Cs0, Cs), append(Cs, Ts, Ts0).

make_parse_clpz.
make_parse_reified.
make_matches.
