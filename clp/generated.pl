/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Generated predicates
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

generated_clauses(Cs) :-
        make_parse_clpz(Cs1),
        make_parse_reified(Cs2),
        make_matches(Cs3),
        list_append([Cs1,Cs2,Cs3], Cs).

% :- initialization((generated_clauses(Cs),list_map(assertz, Cs))).

cutless(Cs0, Cs) :-
    list_map(pclause, Cs0, Cs1),
    pmerge(Cs1, Cs2),
    list_map(arg(2), Cs2, Cs3),
    list_map(disj, Cs3, Cs).

disj(Cs0, (H:-G)) :-
    list_map(if_then, Cs0, Cs1),
    list_map(arg(2), Cs1, Gs),
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
    (   list_foldl(list_select, [H-C0,H-C1], Cs0, Cs1)
    ->  list_append(C0, C1, C),
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

term_expansion(make_parse_clpz, Ts0, Ts) :-
    make_parse_clpz(Cs0), cutless(Cs0, Cs), list_append(Cs, Ts, Ts0).
term_expansion(make_parse_reified, Ts0, Ts) :-
    make_parse_reified(Cs0), cutless(Cs0, Cs), list_append(Cs, Ts, Ts0).
term_expansion(make_matches, Ts0, Ts) :-
    make_matches(Cs0), cutless(Cs0, Cs), list_append(Cs, Ts, Ts0).

make_parse_clpz.
make_parse_reified.
make_matches.
