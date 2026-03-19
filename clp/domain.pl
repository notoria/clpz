/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Domain
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

domain(D) :-
    var(D),
    throw(error(instantiation_error,domain/1)).
domain(D) :-
    domain_to_intervals(D, Is),
    domain_from_intervals(Is, D),
    intervals(Is).
% domain(empty).
% domain(from_to(L,F,T,R)) :-
%     bound(F),
%     bound(T),
%     F cis_le T, F \== sup, T \== inf,
%     domain(L),
%     domain(R),
%     domain_check_sup(L, F),
%     domain_check_inf(R, T).
% 
% domain_check_sup(empty, _).
% domain_check_sup(from_to(L,F,T,R), S) :-
%     domain_supremum(from_to(L,F,T,R), S0),
%     S1 cis S0+n(1), % there is a hole.
%     S1 cis_lt S.
% 
% domain_check_inf(empty, _).
% domain_check_inf(from_to(L,F,T,R), I) :-
%     domain_infimum(from_to(L,F,T,R), I0),
%     I1 cis I0-n(1), % there is a hole.
%     I1 cis_gt I.

domain_empty(empty).

domain_empty(empty, true).
domain_empty(from_to(_,_,_,_), false).

domain_singleton(from_to(D,I,I,D), I) :-
    domain_empty(D),
    I = n(_).

domain_from_bounds(I, S, D) :-
    cis_compare(O, I, S),
    '@domain_from_bounds'(O, I, S, D).

'@domain_from_bounds'(>, _, _, empty).
'@domain_from_bounds'(=, N, N, from_to(empty,N,N,empty)) :-
    N = n(_).
'@domain_from_bounds'(<, I, S, from_to(empty,I,S,empty)).

domain_infimum(D, I) :-
    '@domain_infimum'(D, sup, I).

'@domain_infimum'(empty, I, I).
'@domain_infimum'(from_to(L,F,_,_), _, I) :-
    '@domain_infimum'(L, F, I).

domain_supremum(D, S) :-
    '@domain_supremum'(D, inf, S).

'@domain_supremum'(empty, S, S).
'@domain_supremum'(from_to(_,_,T,R), _, S) :-
    '@domain_supremum'(R, T, S).

domain_length(empty, n(0)).
domain_length(from_to(L,F,T,R), S) :-
    domain_length(L, S0),
    domain_length(R, S1),
    S cis S0+T-F+n(1)+S1.

domain_diameter(Dom, Dia) :-
    domain_infimum(Dom, I),
    domain_supremum(Dom, S),
    Dia cis S-I.

domain_direction_element(D, up, E) :-
    domain_up_element(D, E).
domain_direction_element(D, down, E) :-
    domain_down_element(D, E).

domain_up_element(from_to(L,_,_,_), E) :-
    domain_up_element(L, E).
domain_up_element(from_to(_,n(F),n(T),_), E) :-
    integer_between(F, T, E).
domain_up_element(from_to(_,_,_,R), E) :-
    domain_up_element(R, E).

domain_down_element(from_to(_,_,_,R), E) :-
    domain_down_element(R, E).
domain_down_element(from_to(_,n(F),n(T),_), E) :-
    integer_add(T, F, R0),
    integer_between(F, T, E0),
    integer_add(R0, E, E0). % E #= T-(E0-F).
domain_down_element(from_to(L,_,_,_), E) :-
    domain_down_element(L, E).

% Membership.

domain_contains(D, E) :-
    domain_contains(D, E, true).

domain_contains(empty, _, false).
domain_contains(from_to(L,F,T,R), E, Truth) :-
    cis_compare(O0, n(E), F),
    cis_compare(O1, n(E), T),
    '@domain_contains'(O0, O1, L, R, E, Truth).

'@domain_contains'(<, <, D, _, E, T) :-
    domain_contains(D, E, T).
'@domain_contains'(>, <, _, _, _, true).
'@domain_contains'(=, <, _, _, _, true).
'@domain_contains'(>, =, _, _, _, true).
'@domain_contains'(=, =, _, _, _, true).
'@domain_contains'(>, >, _, D, E, T) :-
    domain_contains(D, E, T).

domain_includes(_, empty).
domain_includes(D, from_to(L,F,T,R)) :-
    '@domain_includes'(D, F-T),
    domain_includes(D, L),
    domain_includes(D, R).

'@domain_includes'(from_to(L0,F0,T0,R0), F-T) :-
    cis_compare(O0, F, T0),
    cis_compare(O1, T, F0),
    '@domain_includes'(O0, O1, from_to(L0,F0,T0,R0), F-T).

'@domain_includes'(<, <, from_to(L,_,_,_), I) :-
    '@domain_includes'(L, I).
'@domain_includes'(<, >, from_to(_,F0,T0,_), F-T) :-
    F0 cis_le F, T cis_le T0.
'@domain_includes'(<, =, from_to(_,F0,T0,_), F-T) :-
    F0 cis_le F, T cis_le T0.
'@domain_includes'(=, >, from_to(_,F0,T0,_), F-T) :-
    F0 cis_le F, T cis_le T0.
'@domain_includes'(=, =, from_to(_,F0,T0,_), F-T) :-
    F0 cis_le F, T cis_le T0.
'@domain_includes'(>, >, from_to(_,_,_,R), I) :-
    '@domain_includes'(R, I).

domain_includes(_, empty, true).
domain_includes(D, from_to(L,F,T,R), Truth) :-
    call(
        (   domain_includes(D, L),
            '@domain_includes'(D, F-T),
            domain_includes(D, R)
        ),
        Truth
    ).

'@domain_includes'(empty, _, false).
'@domain_includes'(from_to(L,I,S,R), F-T, Truth) :-
    cis_compare(O0, F, S),
    cis_compare(O1, T, I),
    '@domain_includes'(O0, O1, from_to(L,I,S,R), F-T, Truth).

'@domain_includes'(<, <, from_to(L,_,_,_), I, Truth) :-
    '@domain_includes'(L, I, Truth).
'@domain_includes'(<, >, from_to(_,I,S,_), F-T, Truth) :-
    cis_compare(O0, F, I),
    cis_compare(O1, T, S),
    '@@domain_includes'(O0, O1, Truth).
'@domain_includes'(<, =, from_to(_,I,S,_), F-T, Truth) :-
    cis_compare(O0, F, I),
    cis_compare(O1, T, S),
    '@@domain_includes'(O0, O1, Truth).
'@domain_includes'(=, >, from_to(_,I,S,_), F-T, Truth) :-
    cis_compare(O0, F, I),
    cis_compare(O1, T, S),
    '@@domain_includes'(O0, O1, Truth).
% '@domain_includes'(<, =, from_to(_,N,_,_), _-N, false).
% '@domain_includes'(=, >, from_to(_,_,N,_), N-_, false).
'@domain_includes'(=, =, from_to(_,N,N,_), N-N, true).
'@domain_includes'(>, >, from_to(_,_,_,R), I, Truth) :-
    '@domain_includes'(R, I, Truth).

'@@domain_includes'(>, <, true).
'@@domain_includes'(>, =, true).
'@@domain_includes'(=, <, true).
'@@domain_includes'(=, =, true).
'@@domain_includes'(>, >, false).
'@@domain_includes'(=, >, false).
'@@domain_includes'(<, >, false).
'@@domain_includes'(<, =, false).
'@@domain_includes'(<, <, false).

domain_intersects(D0, D1, Truth) :-
    call(
        ('@domain_intersects'(D0, D1) ; '@domain_intersects'(D1, D0)),
        Truth
    ).

'@domain_intersects'(_, empty, false).
'@domain_intersects'(D, from_to(L,F,T,R), Truth) :-
    bound_finite(F, T0),
    bound_finite(T, T1),
    call(
        (   '@domain_intersects'(D, L)
        ;   '@@domain_intersects'(T0, T1, D, F, T)
        ;   '@domain_intersects'(D, R)
        ),
        Truth
    ).

'@@domain_intersects'(false, false, D, inf, sup, Truth) :-
    if_(domain_empty(D), Truth = false, Truth = true).
'@@domain_intersects'(false,  true, D, inf, n(N), Truth) :-
    % domain_infimum(D, I),
    % domain_from_bounds(inf, n(N), D0),
    % if_(bound_finite(I), (n(N0) = I, domain_contains(D0, N0)), Truth = true).
    call(domain_contains(D, N), Truth).
'@@domain_intersects'( true, false, D, n(N), sup, Truth) :-
    call(domain_contains(D, N), Truth).
'@@domain_intersects'( true,  true, D, n(N0), n(N1), Truth) :-
    call((domain_contains(D, N0) ; domain_contains(D, N1)), Truth).

% Operations.

% domain_remove(<(E), D0, D) :-
%     domain_remove_greater_than(E, D0, D).
% domain_remove(=(E), D0, D) :-
%     domain_remove_number(E, D0, D).
% domain_remove(>(E), D0, D) :-
%     domain_remove_less_than(E, D0, D).

% domain_remove_number(E, D0, D) :-
domain_remove(E, D0, D) :-
    if_(domain_contains(D0, E), '@domain_remove_number'(E, D0, D), D = D0).

'@domain_remove_number'(E, D0, D) :-
    domain_to_intervals(D0, Is0),
    intervals_diff([n(E)-n(E)], Is0, Is),
    domain_from_intervals(Is, D).

domain_remove_less_than(I, D0, D) :-
    domain_infimum(D0, I0),
    cis_compare(O, I0, n(I)),
    '@domain_remove_less_than'(O, I, D0, D).

'@domain_remove_less_than'(<, I0, D0, D) :-
    domain_to_intervals(D0, Is0),
    integer_add(1, I, I0),
    intervals_diff([inf-n(I)], Is0, Is),
    domain_from_intervals(Is, D).
'@domain_remove_less_than'(=, _, D, D).
'@domain_remove_less_than'(>, _, D, D).

domain_remove_greater_than(S, D0, D) :-
    domain_supremum(D0, S0),
    cis_compare(O, S0, n(S)),
    '@domain_remove_greater_than'(O, S, D0, D).

'@domain_remove_greater_than'(<, _, D, D).
'@domain_remove_greater_than'(=, _, D, D).
'@domain_remove_greater_than'(>, S0, D0, D) :-
    domain_to_intervals(D0, Is0),
    integer_add(1, S0, S),
    intervals_diff([n(S)-sup], Is0, Is),
    domain_from_intervals(Is, D).

domain_diff(S, D0, D) :-
    % if_(domain_includes(D0, S), '@domain_diff'(S, D0, D), D = D0). % Wrong.
    '@domain_diff'(S, D0, D).

'@domain_diff'(S, D0, D) :-
    domain_to_intervals(S, Is0),
    domain_to_intervals(D0, Is1),
    intervals_diff(Is0, Is1, Is),
    domain_from_intervals(Is, D).

domain_complement(D0, D) :-
    domain_from_bounds(inf, sup, D1),
    domain_diff(D0, D1, D).

% Geometry.

domain_congruent(empty, empty).
domain_congruent(from_to(L0,_,_,R0), from_to(L,_,_,R)) :-
    domain_congruent(L0, L),
    domain_congruent(R0, R).

domain_union(D0, D1, D) :-
    domain_to_intervals(D0, Is0),
    domain_to_intervals(D1, Is1),
    intervals_union(Is0, Is1, Is),
    domain_from_intervals(Is, D).

domain_inter(D0, D1, D) :-
    domain_to_intervals(D0, Is0),
    domain_to_intervals(D1, Is1),
    intervals_inter(Is0, Is1, Is),
    domain_from_intervals(Is, D).

domain_shift(N, D0, D) :-
    integer_compare(O, 0, N),
    '@domain_shift'(O, N, D0, D).

'@domain_shift'(<, N, D0, D) :-
    '@domain_shift'(N, D0, D).
'@domain_shift'(=, 0, D, D).
'@domain_shift'(>, N, D0, D) :-
    '@domain_shift'(N, D0, D).

'@domain_shift'(_, empty, empty).
'@domain_shift'(N, from_to(L0,F0,T0,R0), from_to(L,F,T,R)) :-
    '@domain_shift'(N, L0, L),
    F cis F0+n(N),
    T cis T0+n(N),
    '@domain_shift'(N, R0, R).

domain_expand(A, D0, D) :-
    compare(O, 0, A),
    '@domain_expand'(O, A, D0, D).

'@domain_expand'(<, A, D0, D) :- '@domain_positive_expand'(A, D0, D).
'@domain_expand'(=, 0, D0, D) :- '@domain_zero_expand'(D0, D).
'@domain_expand'(>, A, D0, D) :- '@domain_negative_expand'(A, D0, D).

'@domain_positive_expand'(A, D0, D) :-
    compare(O, 1, A),
    '@domain_positive_expand'(O, A, D0, D).

'@domain_positive_expand'(=, 1, D, D).
'@domain_positive_expand'(<, A, D0, D) :-
    '@@domain_positive_expand'(A, D0, D).

'@@domain_positive_expand'(_, empty, empty).
'@@domain_positive_expand'(A, from_to(L0,F0,T0,R0), from_to(L,F,T,R)) :-
    '@@domain_positive_expand'(A, L0, L),
    F cis n(A)*F0,
    T cis n(A)*T0,
    '@@domain_positive_expand'(A, R0, R).

'@domain_zero_expand'(empty, empty).
'@domain_zero_expand'(from_to(_,_,_,_), from_to(empty,n(0),n(0),empty)).

'@domain_negative_expand'(A, D0, D) :-
    domain_to_intervals(D0, Is0),
    phrase('@intervals_negative_expand'(A, Is0), Is),
    domain_congruent(D0, D),
    domain_to_intervals(D, Is).

domain_contract(A, D0, D) :-
    domain_to_intervals(D0, Is0),
    intervals_contract(A, Is0, Is),
    domain_from_intervals(Is, D).
%     compare(O, 0, A),
%     '@domain_contract'(O, A, D0, D).
% 
% '@domain_contract'(<, A, D0, D) :-
%     domain_to_intervals(D0, Is0),
%     intervals_contract(A, Is0, Is),
%     domain_from_intervals(Is, D).
% '@domain_contract'(>, A, D0, D) :-
%     domain_to_intervals(D0, Is0),
%     intervals_contract(A, Is0, Is),
%     domain_from_intervals(Is, D).

domain_shrink(A, D0, D) :-
    domain_to_intervals(D0, Is0),
    intervals_shrink(A, Is0, Is),
    domain_from_intervals(Is, D).

% Intervals.
domain_to_intervals(D, Is) :-
    phrase('@domain_intervals'(D), Is).

'@domain_intervals'(empty) --> [].
'@domain_intervals'(from_to(L,F,T,R)) -->
    '@domain_intervals'(L), [F-T], '@domain_intervals'(R).

domain_from_intervals([], empty).
domain_from_intervals([I0|Is0], from_to(L,F,T,R)) :-
    Is = [I0|Is0],
    list_length(Is, N),
    integer_ddqr(floor, N, 2, Mid, _), % Mid #= N div 2,
    list_length(Is1, Mid),
    list_append(Is1, [F-T|Is2], Is),
    domain_from_intervals(Is1, L),
    domain_from_intervals(Is2, R).

domain_from_numbers(Ns, D) :-
    intervals_from_numbers(Ns, Is),
    domain_from_intervals(Is, D).

domain_to_numbers(D, _) :-
    domain_diameter(D, sup),
    throw(error(instantiation_error,domain_to_numbers/2)).
domain_to_numbers(D, Ns) :-
    phrase(domain_to_numbers(D), Ns).

domain_to_numbers(empty) --> [].
domain_to_numbers(from_to(L,F,T,R)) -->
    domain_to_numbers(L), '@interval_to_numbers'(F-T), domain_to_numbers(R).

domain_boundary(empty) --> [].
domain_boundary(from_to(L,F,T,R)) -->
    domain_boundary(L), [F,T], domain_boundary(R).


% domain_spread(Dom, Spread) :-
%         domain_smallest_finite(Dom, S),
%         domain_largest_finite(Dom, L),
%         Spread cis L - S, portray_clause(user_error, domain_spread(Spread)).
% 
% smallest_finite(inf, Y, Y).
% smallest_finite(n(N), _, n(N)).
% 
% domain_smallest_finite(empty, inf).
% domain_smallest_finite(from_to(L,F,T,_), I) :-
%     domain_smallest_finite(L, I0),
%     smallest_finite(F, T, I1),
%     I cis max(I0,I1).
% 
% largest_finite(sup, Y, Y).
% largest_finite(n(N), _, n(N)).
% 
% domain_largest_finite(empty, sup).
% domain_largest_finite(from_to(_,F,T,R), S) :-
%     domain_largest_finite(R, S0),
%     largest_finite(T, F, S1),
%     S cis min(S0,S1).
