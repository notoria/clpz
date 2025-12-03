/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A domain is a finite set of disjoint intervals. Internally, domains
   are represented as trees. Each node is one of:

   empty: empty domain.

   split(N,Left,Right)
      - split on integer N, with Left and Right domains whose elements are
        all less than and greater than N, respectively. The domain is the
        union of Left and Right, i.e., N is a hole.

   from_to(From,To)
      - interval (From-1, To+1); From and To are bounds

   Desiderata: rebalance domains; singleton intervals.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Type definition and inspection of domains.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain(D) :-
    var(D),
    throw(error(instantiation_error,domain/1)).
domain(empty).
domain(from_to(From,To)) :-
        bound(From), bound(To),
        From cis_le To.
domain(split(S,Left,Right)) :-
        integer(S),
        domain(Left), domain(Right),
        domain_supremum(Left, Sup),
        domain_infimum(Right, Inf),
        Sup cis_lt n(S), n(S) cis_lt Inf.
        % all_less_than(Left, S),
        % all_greater_than(Right, S).

% all_less_than(empty, _).
% all_less_than(from_to(From,To), S) :-
%         From cis_lt n(S), To cis_lt n(S).
% all_less_than(split(S0,Left,Right), S) :-
%         S0 < S,
%         all_less_than(Left, S),
%         all_less_than(Right, S).
% 
% all_greater_than(empty, _).
% all_greater_than(from_to(From,To), S) :-
%         From cis_gt n(S), To cis_gt n(S).
% all_greater_than(split(S0,Left,Right), S) :-
%         S0 > S,
%         all_greater_than(Left, S),
%         all_greater_than(Right, S).

domain_empty(empty).

domain_empty(empty, true).
domain_empty(from_to(_,_), false).
domain_empty(split(_,_,_), false).

domain_singleton(from_to(I,I), I).

domain_from_bounds(I, S, D) :-
    cis_compare(O, I, S),
    domain_from_bounds_(O, I, S, D).

domain_from_bounds_(>, _, _, empty).
domain_from_bounds_(=, N, N, from_to(N,N)) :-
    N = n(_).
domain_from_bounds_(<, I, S, from_to(I,S)).

default_domain(from_to(inf,sup)).

domain_infimum(from_to(I, _), I).
domain_infimum(split(_,Left,_), I) :- domain_infimum(Left, I).

domain_supremum(from_to(_,S), S).
domain_supremum(split(_,_,Right), S) :- domain_supremum(Right, S).

domain_length(empty, n(0)).
domain_length(from_to(From,To), Num) :- Num cis To - From + n(1).
domain_length(split(_,Left,Right), Num) :-
        domain_length(Left, NL),
        domain_length(Right, NR),
        Num cis NL + NR.

domain_direction_element(Dom, up, E) :-
    domain_up_element(Dom, E).
domain_direction_element(Dom, down, E) :-
    domain_down_element(Dom, E).

domain_up_element(from_to(n(From),n(To)), E) :-
    between(From, To, E).
domain_up_element(split(_,D,_), E) :-
    domain_up_element(D, E).
domain_up_element(split(_,_,D), E) :-
    domain_up_element(D, E).

domain_down_element(from_to(n(From),n(To)), E) :-
    between(From, To, E0),
    E is To-(E0-From).
domain_down_element(split(_,_,D), E) :-
    domain_down_element(D, E).
domain_down_element(split(_,D,_), E) :-
    domain_down_element(D, E).

% domain_direction_element(from_to(n(From),n(To)), Dir, E) :-
%         (   Dir == up -> between(From, To, E)
%         ;   between(From, To, E0),
%             E is To - (E0 - From)
%         ).
% domain_direction_element(split(_,D1,D2), Dir, E) :-
%         (   Dir == up ->
%             (   domain_direction_element(D1, Dir, E)
%             ;   domain_direction_element(D2, Dir, E)
%             )
%         ;   (   domain_direction_element(D2, Dir, E)
%             ;   domain_direction_element(D1, Dir, E)
%             )
%         ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Test whether domain contains a given integer.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_contains(from_to(From,To), I) :- From cis_le n(I), n(I) cis_le To.
domain_contains(split(S,Left,Right), I) :-
        % (   I < S -> domain_contains(Left, I)
        % ;   I > S -> domain_contains(Right, I)
        % ).
        compare(R, I, S),
        domain_contains_(R, Left, Right, I).

domain_contains_(<, D, _, I) :-
    domain_contains(D, I).
domain_contains_(>, _, D, I) :-
    domain_contains(D, I).

domain_member(from_to(From,To), I) :-
    From cis_le n(I), n(I) cis_le To.
domain_member(split(_,Left,Right), I) :-
    domain_supremum(Left, Sup0), Sup cis Sup0+n(1),
    domain_infimum(Right, Inf0), Inf cis Inf0-n(1),
    cis_compare(R, I, Sup),
    cis_compare(R, I, Inf),
    domain_member_(R, Left, Right, I).

domain_member_(<, D, _, I) :-
    domain_member(D, I).
domain_member_(>, _, D, I) :-
    domain_member(D, I).

domain_member(empty, _, false).
domain_member(from_to(From0,To0), I, T) :-
    From cis From0-n(1),
    To cis To0+n(1),
    cis_compare(R0, From, n(I)), cis_compare(R1, n(I), To),
    domain_member_(R0, R1, T).
    % call(R0=R1, T).
    % if_(R0=R1, T = true, T = false).
domain_member(split(_,Left,Right), I, T) :-
    domain_supremum(Left, Sup0), Sup cis Sup0+n(1),
    domain_infimum(Right, Inf0), Inf cis Inf0-n(1),
    cis_compare(R0, n(I), Sup),
    cis_compare(R1, n(I), Inf),
    domain_member_(R0, R1, Left, Right, I, T).
    % if_(dm(R0,R1), domain_member_(R0, Left, Right, I, T), T = false).
    % if_(R0=R1, domain_member_(R0, Left, Right, I, T), T = false).

% domain_member_(<, D, _, I, T) :-
%     domain_member(D, I, T).
% domain_member_(=, _, _, _, false).
% domain_member_(>, _, D, I, T) :-
%     domain_member(D, I, T).

domain_member_(<, <, D, _, I, T) :-
    domain_member(D, I, T).
domain_member_(<, =, _, _, _, false).
domain_member_(<, >, _, _, _, false).
domain_member_(=, <, _, _, _, false).
domain_member_(=, =, _, _, _, false).
domain_member_(=, >, _, _, _, false).
domain_member_(>, <, _, _, _, false).
domain_member_(>, =, _, _, _, false).
domain_member_(>, >, _, D, I, T) :-
    domain_member(D, I, T).

domain_member_(<, <, true).
domain_member_(<, =, false).
domain_member_(<, >, false).
domain_member_(=, <, false).
domain_member_(=, =, false).
domain_member_(=, >, false).
domain_member_(>, <, false).
domain_member_(>, =, false).
domain_member_(>, >, true).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Test whether a domain contains another domain.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_subdomain(Dom, Sub) :- domain_subdomain(Dom, Dom, Sub).

domain_subdomain(from_to(_,_), Dom, Sub) :-
        domain_subdomain_fromto(Sub, Dom).
domain_subdomain(split(_,_,_), Dom, Sub) :-
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
        From0 cis_le From, To0 cis_ge To.
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
domain_remove(split(S,Left0,Right0), X, D) :-
        (   X =:= S -> D = split(S,Left0,Right0)
        ;   X < S ->
            domain_remove(Left0, X, Left1),
            (   Left1 == empty -> D = Right0
            ;   D = split(S,Left1,Right0)
            )
        ;   domain_remove(Right0, X, Right1),
            (   Right1 == empty -> D = Left0
            ;   D = split(S,Left0,Right1)
            )
        ).

%?- domain_remove(from_to(n(0),n(5)), 3, D).

domain_remove_(inf, U0, X, D) :-
        (   U0 == n(X) -> U1 is X - 1, D = from_to(inf, n(U1))
        ;   U0 cis_lt n(X) -> D = from_to(inf,U0)
        ;   L1 is X + 1, U1 is X - 1,
            D = split(X,from_to(inf,n(U1)),from_to(n(L1),U0))
        ).
domain_remove_(n(N), U0, X, D) :- domain_remove_upper(U0, N, X, D).

domain_remove_upper(sup, L0, X, D) :-
        (   L0 =:= X -> L1 is X + 1, D = from_to(n(L1),sup)
        ;   L0 > X -> D = from_to(n(L0),sup)
        ;   L1 is X + 1, U1 is X - 1,
            D = split(X,from_to(n(L0),n(U1)),from_to(n(L1),sup))
        ).
domain_remove_upper(n(U0), L0, X, D) :-
        (   L0 =:= U0, X =:= L0 -> D = empty
        ;   L0 =:= X -> L1 is X + 1, D = from_to(n(L1), n(U0))
        ;   U0 =:= X -> U1 is X - 1, D = from_to(n(L0), n(U1))
        ;   between(L0, U0, X) ->
            U1 is X - 1, L1 is X + 1,
            D = split(X,from_to(n(L0),n(U1)),from_to(n(L1),n(U0)))
        ;   D = from_to(n(L0),n(U0))
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Remove all elements greater than / less than a constant.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_remove_greater_than(_, empty, empty).
domain_remove_greater_than(G, from_to(From0,To0), D) :-
        (   From0 cis_gt n(G) -> D = empty
        ;   To cis min(To0,n(G)), D = from_to(From0,To)
        ).
domain_remove_greater_than(G, split(S,Left0,Right0), D) :-
        (   S =< G ->
            domain_remove_greater_than(G, Right0, Right),
            (   Right == empty -> D = Left0
            ;   D = split(S,Left0,Right)
            )
        ;   domain_remove_greater_than(G, Left0, D)
        ).

domain_remove_less_than(_, empty, empty).
domain_remove_less_than(V, from_to(From0,To0), D) :-
        (   To0 cis_lt n(V) -> D = empty
        ;   From cis max(From0,n(V)), D = from_to(From,To0)
        ).
domain_remove_less_than(V, split(S,Left0,Right0), D) :-
        (   S >= V ->
            domain_remove_less_than(V, Left0, Left),
            (   Left == empty -> D = Right0
            ;   D = split(S,Left,Right0)
            )
        ;   domain_remove_less_than(V, Right0, D)
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
            ;   From cis_le From0 ->
                (   To cis_ge To0 -> D = empty
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
        ;   Sub = split(S,Left,Right) ->
            (   n(S) cis_gt To0 -> domain_subtract(Dom, Dom, Left, D)
            ;   n(S) cis_lt From0 -> domain_subtract(Dom, Dom, Right, D)
            ;   domain_subtract(Dom, Dom, Left, D1),
                domain_subtract(D1, D1, Right, D)
            )
        ).
domain_subtract(split(S,Left0,Right0), _, Sub, D) :-
        domain_subtract(Left0, Left0, Sub, Left),
        domain_subtract(Right0, Right0, Sub, Right),
        (   Left == empty -> D = Right
        ;   Right == empty -> D = Left
        ;   D = split(S,Left,Right)
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Complement of a domain
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_complement(D0, D) :-
        domain_from_bounds(inf, sup, D1),
        domain_subtract(D1, D0, D).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Convert domain to a list of disjoint intervals From-To.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_to_intervals(D, Is) :- phrase(domain_intervals(D), Is).

domain_intervals(split(_,Left,Right)) -->
        domain_intervals(Left), domain_intervals(Right).
domain_intervals(empty)               --> [].
domain_intervals(from_to(From,To))    --> [From-To].

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   To compute the intersection of two domains D1 and D2, we choose D1
   as the reference domain. For each interval of D1, we compute how
   far and to which values D2 lets us extend it.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_inter(D1, D2, Intersection) :-
        domain_inter_(D1, D2, Intersection),
        Intersection \== empty.

domain_inter_(empty, _, empty).
domain_inter_(from_to(L0,U0), D2, Dom) :-
        narrow(D2, L0, U0, Dom).
domain_inter_(split(S,Left0,Right0), D2, Dom) :-
        domain_inter_(Left0, D2, Left1),
        domain_inter_(Right0, D2, Right1),
        (   Left1 == empty -> Dom = Right1
        ;   Right1 == empty -> Dom = Left1
        ;   Dom = split(S,Left1,Right1)
        ).

narrow(empty, _, _, empty).
narrow(from_to(L0,U0), From0, To0, Dom) :-
        From1 cis max(From0,L0), To1 cis min(To0,U0),
        (   From1 cis_gt To1 -> Dom = empty
        ;   Dom = from_to(From1,To1)
        ).
narrow(split(S,Left0,Right0), From0, To0, Dom) :-
        (   To0 cis_lt n(S) -> narrow(Left0, From0, To0, Dom)
        ;   From0 cis_gt n(S) -> narrow(Right0, From0, To0, Dom)
        ;   narrow(Left0, From0, To0, Left1),
            narrow(Right0, From0, To0, Right1),
            (   Left1 == empty -> Dom = Right1
            ;   Right1 == empty -> Dom = Left1
            ;   Dom = split(S,Left1,Right1)
            )
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Union of 2 domains.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_union(D1, D2, Union) :-
        domain_to_intervals(D1, Is1),
        domain_to_intervals(D2, Is2),
        intervals_union(Is1, Is2, Is),
        domain_from_intervals(Is, Union).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Shift the domain by an offset.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_shift(empty, _, empty).
domain_shift(from_to(From0,To0), O, from_to(From,To)) :-
        From cis From0 + n(O), To cis To0 + n(O).
domain_shift(split(S0,Left0,Right0), O, split(S,Left,Right)) :-
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
domain_expand_(split(S0,Left0,Right0), M, split(S,Left,Right)) :-
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
        (   From0 cis_le n(0) ->
            From cis (From0-n(1))*n(M) + n(1)
        ;   From cis From0*n(M)
        ),
        (   To0 cis_lt n(0) ->
            To cis To0*n(M)
        ;   To cis (To0+n(1))*n(M) - n(1)
        ).
domain_expand_more_(split(S0,Left0,Right0), M, split(S,Left,Right)) :-
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
        (   From0 cis_ge n(0) ->
            From cis (From0 + n(M) - n(1)) // n(M)
        ;   From cis From0 // n(M)
        ),
        (   To0 cis_ge n(0) ->
            To cis To0 // n(M)
        ;   To cis (To0 - n(M) + n(1)) // n(M)
        ).
domain_contract_(split(_,Left0,Right0), M, D) :-
        %  Scaled down domains do not necessarily retain any holes of
        %  the original domain.
        domain_contract_(Left0, M, Left),
        domain_contract_(Right0, M, Right),
        domain_union(Left, Right, D).

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
        domain_union(Left, Right, D).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Negate the domain. Left and Right sub-domains and bounds switch sides.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain_negate(empty, empty).
domain_negate(from_to(From0, To0), from_to(From, To)) :-
        From cis -To0, To cis -From0.
domain_negate(split(S0,Left0,Right0), split(S,Left,Right)) :-
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

list_to_domain([], empty).
list_to_domain([E0|Es0], D) :-
    sort([E0|Es0], Es),
    list_to_disjoint_intervals(Es, Is),
    intervals_to_domain(Is, D).

intervals_to_domain([], empty).
intervals_to_domain([I|Is], D) :-
        intervals_to_domain_(I, Is, D).

intervals_to_domain_(I0, [], from_to(M,N)) :-
        I0 = M-N.
intervals_to_domain_(I0, [I1|Is0], D) :-
        Is = [I0|[I1|Is0]],
        list_length(Is, L),
        FL is L // 2,
        list_length(Front, FL),
        list_append(Front, Tail, Is),
        Tail = [n(Start)-_|_],
        Hole is Start - 1,
        intervals_to_domain(Front, Left),
        intervals_to_domain(Tail, Right),
        D = split(Hole,Left,Right).

domain_spread(Dom, Spread) :-
        domain_smallest_finite(Dom, S),
        domain_largest_finite(Dom, L),
        Spread cis L - S, portray_clause(user_error, domain_spread(Spread)).

smallest_finite(inf, Y, Y).
smallest_finite(n(N), _, n(N)).

domain_smallest_finite(from_to(F,T), S)   :- smallest_finite(F, T, S).
domain_smallest_finite(split(_, L, _), S) :- domain_smallest_finite(L, S).

largest_finite(sup, Y, Y).
largest_finite(n(N), _, n(N)).

domain_largest_finite(from_to(F,T), L)   :- largest_finite(T, F, L).
domain_largest_finite(split(_, _, R), L) :- domain_largest_finite(R, L).
domain_to_list(Domain, List) :- phrase(domain_to_list(Domain), List).

domain_to_list(empty)               --> [].
domain_to_list(split(_,Left,Right)) -->
        domain_to_list(Left), domain_to_list(Right).
domain_to_list(from_to(n(F),n(T)))  -->
        { N is T-F+1, list_length(Ns, N), [F|_] = Ns, chain_(succ, Ns) },
        seq(Ns).
