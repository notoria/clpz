/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A domain is a finite set of disjoint intervals. Internally, domains
   are represented as trees. Each node is one of:

   empty: empty domain.

   split(N, Left, Right)
      - split on integer N, with Left and Right domains whose elements are
        all less than and greater than N, respectively. The domain is the
        union of Left and Right, i.e., N is a hole.

   from_to(From, To)
      - interval (From-1, To+1); From and To are bounds

   Desiderata: rebalance domains; singleton intervals.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Type definition and inspection of domains.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

check_domain(D) :-
        (   var(D) -> instantiation_error(D)
        ;   is_domain(D) -> true
        ;   domain_error(clpz_domain, D)
        ).

is_domain(empty).
is_domain(from_to(From,To)) :-
        is_bound(From), is_bound(To),
        From cis_leq To.
is_domain(split(S, Left, Right)) :-
        integer(S),
        is_domain(Left), is_domain(Right),
        all_less_than(Left, S),
        all_greater_than(Right, S).

all_less_than(empty, _).
all_less_than(from_to(From,To), S) :-
        From cis_lt n(S), To cis_lt n(S).
all_less_than(split(S0,Left,Right), S) :-
        S0 < S,
        all_less_than(Left, S),
        all_less_than(Right, S).

all_greater_than(empty, _).
all_greater_than(from_to(From,To), S) :-
        From cis_gt n(S), To cis_gt n(S).
all_greater_than(split(S0,Left,Right), S) :-
        S0 > S,
        all_greater_than(Left, S),
        all_greater_than(Right, S).

default_domain(from_to(inf,sup)).

domain_infimum(from_to(I, _), I).
domain_infimum(split(_, Left, _), I) :- domain_infimum(Left, I).

domain_supremum(from_to(_, S), S).
domain_supremum(split(_, _, Right), S) :- domain_supremum(Right, S).

domain_num_elements(empty, n(0)).
domain_num_elements(from_to(From,To), Num) :- Num cis To - From + n(1).
domain_num_elements(split(_, Left, Right), Num) :-
        domain_num_elements(Left, NL),
        domain_num_elements(Right, NR),
        Num cis NL + NR.

domain_direction_element(from_to(n(From), n(To)), Dir, E) :-
        (   Dir == up -> between(From, To, E)
        ;   between(From, To, E0),
            E is To - (E0 - From)
        ).
domain_direction_element(split(_, D1, D2), Dir, E) :-
        (   Dir == up ->
            (   domain_direction_element(D1, Dir, E)
            ;   domain_direction_element(D2, Dir, E)
            )
        ;   (   domain_direction_element(D2, Dir, E)
            ;   domain_direction_element(D1, Dir, E)
            )
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Test whether domain contains a given integer.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_contains(from_to(From,To), I) :- From cis_leq n(I), n(I) cis_leq To.
domain_contains(split(S, Left, Right), I) :-
        (   I < S -> domain_contains(Left, I)
        ;   I > S -> domain_contains(Right, I)
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Test whether a domain contains another domain.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_subdomain(Dom, Sub) :- domain_subdomain(Dom, Dom, Sub).

domain_subdomain(from_to(_,_), Dom, Sub) :-
        domain_subdomain_fromto(Sub, Dom).
domain_subdomain(split(_, _, _), Dom, Sub) :-
        domain_subdomain_split(Sub, Dom, Sub).

domain_subdomain_split(empty, _, _).
domain_subdomain_split(from_to(From,To), split(S,Left0,Right0), Sub) :-
        (   To cis_lt n(S) -> domain_subdomain(Left0, Left0, Sub)
        ;   From cis_gt n(S) -> domain_subdomain(Right0, Right0, Sub)
        ).
domain_subdomain_split(split(_,Left,Right), Dom, _) :-
        domain_subdomain(Dom, Dom, Left),
        domain_subdomain(Dom, Dom, Right).

domain_subdomain_fromto(empty, _).
domain_subdomain_fromto(from_to(From,To), from_to(From0,To0)) :-
        From0 cis_leq From, To0 cis_geq To.
domain_subdomain_fromto(split(_,Left,Right), Dom) :-
        domain_subdomain_fromto(Left, Dom),
        domain_subdomain_fromto(Right, Dom).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Remove an integer from a domain. The domain is traversed until an
   interval is reached from which the element can be removed, or until
   it is clear that no such interval exists.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_remove(empty, _, empty).
domain_remove(from_to(L0, U0), X, D) :- domain_remove_(L0, U0, X, D).
domain_remove(split(S, Left0, Right0), X, D) :-
        (   X =:= S -> D = split(S, Left0, Right0)
        ;   X < S ->
            domain_remove(Left0, X, Left1),
            (   Left1 == empty -> D = Right0
            ;   D = split(S, Left1, Right0)
            )
        ;   domain_remove(Right0, X, Right1),
            (   Right1 == empty -> D = Left0
            ;   D = split(S, Left0, Right1)
            )
        ).

%?- domain_remove(from_to(n(0),n(5)), 3, D).

domain_remove_(inf, U0, X, D) :-
        (   U0 == n(X) -> U1 is X - 1, D = from_to(inf, n(U1))
        ;   U0 cis_lt n(X) -> D = from_to(inf,U0)
        ;   L1 is X + 1, U1 is X - 1,
            D = split(X, from_to(inf, n(U1)), from_to(n(L1),U0))
        ).
domain_remove_(n(N), U0, X, D) :- domain_remove_upper(U0, N, X, D).

domain_remove_upper(sup, L0, X, D) :-
        (   L0 =:= X -> L1 is X + 1, D = from_to(n(L1),sup)
        ;   L0 > X -> D = from_to(n(L0),sup)
        ;   L1 is X + 1, U1 is X - 1,
            D = split(X, from_to(n(L0),n(U1)), from_to(n(L1),sup))
        ).
domain_remove_upper(n(U0), L0, X, D) :-
        (   L0 =:= U0, X =:= L0 -> D = empty
        ;   L0 =:= X -> L1 is X + 1, D = from_to(n(L1), n(U0))
        ;   U0 =:= X -> U1 is X - 1, D = from_to(n(L0), n(U1))
        ;   between(L0, U0, X) ->
            U1 is X - 1, L1 is X + 1,
            D = split(X, from_to(n(L0), n(U1)), from_to(n(L1), n(U0)))
        ;   D = from_to(n(L0),n(U0))
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Remove all elements greater than / less than a constant.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_remove_greater_than(empty, _, empty).
domain_remove_greater_than(from_to(From0,To0), G, D) :-
        (   From0 cis_gt n(G) -> D = empty
        ;   To cis min(To0,n(G)), D = from_to(From0,To)
        ).
domain_remove_greater_than(split(S,Left0,Right0), G, D) :-
        (   S =< G ->
            domain_remove_greater_than(Right0, G, Right),
            (   Right == empty -> D = Left0
            ;   D = split(S, Left0, Right)
            )
        ;   domain_remove_greater_than(Left0, G, D)
        ).

domain_remove_smaller_than(empty, _, empty).
domain_remove_smaller_than(from_to(From0,To0), V, D) :-
        (   To0 cis_lt n(V) -> D = empty
        ;   From cis max(From0,n(V)), D = from_to(From,To0)
        ).
domain_remove_smaller_than(split(S,Left0,Right0), V, D) :-
        (   S >= V ->
            domain_remove_smaller_than(Left0, V, Left),
            (   Left == empty -> D = Right0
            ;   D = split(S, Left, Right0)
            )
        ;   domain_remove_smaller_than(Right0, V, D)
        ).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Remove a whole domain from another domain. (Set difference.)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_subtract(Dom0, Sub, Dom) :- domain_subtract(Dom0, Dom0, Sub, Dom).

domain_subtract(empty, _, _, empty).
domain_subtract(from_to(From0,To0), Dom, Sub, D) :-
        (   Sub == empty -> D = Dom
        ;   Sub = from_to(From,To) ->
            (   From == To -> From = n(X), domain_remove(Dom, X, D)
            ;   From cis_gt To0 -> D = Dom
            ;   To cis_lt From0 -> D = Dom
            ;   From cis_leq From0 ->
                (   To cis_geq To0 -> D = empty
                ;   From1 cis To + n(1),
                    D = from_to(From1, To0)
                )
            ;   To1 cis From - n(1),
                (   To cis_lt To0 ->
                    From = n(S),
                    From2 cis To + n(1),
                    D = split(S,from_to(From0,To1),from_to(From2,To0))
                ;   D = from_to(From0,To1)
                )
            )
        ;   Sub = split(S, Left, Right) ->
            (   n(S) cis_gt To0 -> domain_subtract(Dom, Dom, Left, D)
            ;   n(S) cis_lt From0 -> domain_subtract(Dom, Dom, Right, D)
            ;   domain_subtract(Dom, Dom, Left, D1),
                domain_subtract(D1, D1, Right, D)
            )
        ).
domain_subtract(split(S, Left0, Right0), _, Sub, D) :-
        domain_subtract(Left0, Left0, Sub, Left),
        domain_subtract(Right0, Right0, Sub, Right),
        (   Left == empty -> D = Right
        ;   Right == empty -> D = Left
        ;   D = split(S, Left, Right)
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Complement of a domain
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_complement(D, C) :-
        default_domain(Default),
        domain_subtract(Default, D, C).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Convert domain to a list of disjoint intervals From-To.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_intervals(D, Is) :- phrase(domain_intervals(D), Is).

domain_intervals(split(_, Left, Right)) -->
        domain_intervals(Left), domain_intervals(Right).
domain_intervals(empty)                 --> [].
domain_intervals(from_to(From,To))      --> [From-To].

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   To compute the intersection of two domains D1 and D2, we choose D1
   as the reference domain. For each interval of D1, we compute how
   far and to which values D2 lets us extend it.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domains_intersection(D1, D2, Intersection) :-
        domains_intersection_(D1, D2, Intersection),
        Intersection \== empty.

domains_intersection_(empty, _, empty).
domains_intersection_(from_to(L0,U0), D2, Dom) :-
        narrow(D2, L0, U0, Dom).
domains_intersection_(split(S,Left0,Right0), D2, Dom) :-
        domains_intersection_(Left0, D2, Left1),
        domains_intersection_(Right0, D2, Right1),
        (   Left1 == empty -> Dom = Right1
        ;   Right1 == empty -> Dom = Left1
        ;   Dom = split(S, Left1, Right1)
        ).

narrow(empty, _, _, empty).
narrow(from_to(L0,U0), From0, To0, Dom) :-
        From1 cis max(From0,L0), To1 cis min(To0,U0),
        (   From1 cis_gt To1 -> Dom = empty
        ;   Dom = from_to(From1,To1)
        ).
narrow(split(S, Left0, Right0), From0, To0, Dom) :-
        (   To0 cis_lt n(S) -> narrow(Left0, From0, To0, Dom)
        ;   From0 cis_gt n(S) -> narrow(Right0, From0, To0, Dom)
        ;   narrow(Left0, From0, To0, Left1),
            narrow(Right0, From0, To0, Right1),
            (   Left1 == empty -> Dom = Right1
            ;   Right1 == empty -> Dom = Left1
            ;   Dom = split(S, Left1, Right1)
            )
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Union of 2 domains.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domains_union(D1, D2, Union) :-
        domain_intervals(D1, Is1),
        domain_intervals(D2, Is2),
        append(Is1, Is2, IsU0),
        merge_intervals(IsU0, IsU1),
        intervals_to_domain(IsU1, Union).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Shift the domain by an offset.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_shift(empty, _, empty).
domain_shift(from_to(From0,To0), O, from_to(From,To)) :-
        From cis From0 + n(O), To cis To0 + n(O).
domain_shift(split(S0, Left0, Right0), O, split(S, Left, Right)) :-
        S is S0 + O,
        domain_shift(Left0, O, Left),
        domain_shift(Right0, O, Right).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   The new domain contains all values of the old domain,
   multiplied by a constant multiplier.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_expand(D0, M, D) :-
        (   M < 0 ->
            domain_negate(D0, D1),
            M1 is abs(M),
            domain_expand_(D1, M1, D)
        ;   M =:= 1 -> D = D0
        ;   domain_expand_(D0, M, D)
        ).

domain_expand_(empty, _, empty).
domain_expand_(from_to(From0, To0), M, from_to(From,To)) :-
        From cis From0*n(M),
        To cis To0*n(M).
domain_expand_(split(S0, Left0, Right0), M, split(S, Left, Right)) :-
        S is M*S0,
        domain_expand_(Left0, M, Left),
        domain_expand_(Right0, M, Right).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   similar to domain_expand/3, tailored for truncated division: an
   interval [From,To] is extended to [From*M, ((To+1)*M - 1)], i.e.,
   to all values that truncated integer-divided by M yield a value
   from interval.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_expand_more(D0, M, D) :-
        %format("expanding ~w by ~w\n", [D0,M]),
        (   M < 0 -> domain_negate(D0, D1), M1 is abs(M)
        ;   D1 = D0, M1 = M
        ),
        domain_expand_more_(D1, M1, D).
        %format("yield: ~w\n", [D]).

domain_expand_more_(empty, _, empty).
domain_expand_more_(from_to(From0, To0), M, from_to(From,To)) :-
        (   From0 cis_leq n(0) ->
            From cis (From0-n(1))*n(M) + n(1)
        ;   From cis From0*n(M)
        ),
        (   To0 cis_lt n(0) ->
            To cis To0*n(M)
        ;   To cis (To0+n(1))*n(M) - n(1)
        ).
domain_expand_more_(split(S0, Left0, Right0), M, split(S, Left, Right)) :-
        S is M*S0,
        domain_expand_more_(Left0, M, Left),
        domain_expand_more_(Right0, M, Right).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Scale a domain down by a constant multiplier. Assuming (//)/2.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_contract(D0, M, D) :-
        %format("contracting ~w by ~w\n", [D0,M]),
        (   M < 0 -> domain_negate(D0, D1), M1 is abs(M)
        ;   D1 = D0, M1 = M
        ),
        domain_contract_(D1, M1, D).

domain_contract_(empty, _, empty).
domain_contract_(from_to(From0, To0), M, from_to(From,To)) :-
        (   From0 cis_geq n(0) ->
            From cis (From0 + n(M) - n(1)) // n(M)
        ;   From cis From0 // n(M)
        ),
        (   To0 cis_geq n(0) ->
            To cis To0 // n(M)
        ;   To cis (To0 - n(M) + n(1)) // n(M)
        ).
domain_contract_(split(_,Left0,Right0), M, D) :-
        %  Scaled down domains do not necessarily retain any holes of
        %  the original domain.
        domain_contract_(Left0, M, Left),
        domain_contract_(Right0, M, Right),
        domains_union(Left, Right, D).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Similar to domain_contract, tailored for division, i.e.,
   {21,23} contracted by 4 is 5. It contracts "less".
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_contract_less(D0, M, D) :-
        (   M < 0 -> domain_negate(D0, D1), M1 is abs(M)
        ;   D1 = D0, M1 = M
        ),
        domain_contract_less_(D1, M1, D).

domain_contract_less_(empty, _, empty).
domain_contract_less_(from_to(From0, To0), M, from_to(From,To)) :-
        From cis From0 // n(M), To cis To0 // n(M).
domain_contract_less_(split(_,Left0,Right0), M, D) :-
        %  Scaled down domains do not necessarily retain any holes of
        %  the original domain.
        domain_contract_less_(Left0, M, Left),
        domain_contract_less_(Right0, M, Right),
        domains_union(Left, Right, D).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Negate the domain. Left and Right sub-domains and bounds switch sides.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_negate(empty, empty).
domain_negate(from_to(From0, To0), from_to(From, To)) :-
        From cis -To0, To cis -From0.
domain_negate(split(S0, Left0, Right0), split(S, Left, Right)) :-
        S is -S0,
        domain_negate(Left0, Right),
        domain_negate(Right0, Left).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Construct a domain from a list of integers. Try to balance it.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

list_to_disjoint_intervals([], []).
list_to_disjoint_intervals([N|Ns], Is) :-
        list_to_disjoint_intervals(Ns, N, N, Is).

list_to_disjoint_intervals([], M, N, [n(M)-n(N)]).
list_to_disjoint_intervals([B|Bs], M, N, Is) :-
        (   B =:= N + 1 ->
            list_to_disjoint_intervals(Bs, M, B, Is)
        ;   Is = [n(M)-n(N)|Rest],
            list_to_disjoint_intervals(Bs, B, B, Rest)
        ).

list_to_domain(List0, D) :-
        (   List0 == [] -> D = empty
        ;   sort(List0, List),
            list_to_disjoint_intervals(List, Is),
            intervals_to_domain(Is, D)
        ).

intervals_to_domain([], empty).
intervals_to_domain([I|Is], D) :-
        intervals_to_domain_(I, Is, D).

intervals_to_domain_(I0, [], from_to(M,N)) :-
        I0 = M-N.
intervals_to_domain_(I0, [I1|Is0], D) :-
        Is = [I0|[I1|Is0]],
        length(Is, L),
        FL is L // 2,
        length(Front, FL),
        append(Front, Tail, Is),
        Tail = [n(Start)-_|_],
        Hole is Start - 1,
        intervals_to_domain(Front, Left),
        intervals_to_domain(Tail, Right),
        D = split(Hole, Left, Right).
