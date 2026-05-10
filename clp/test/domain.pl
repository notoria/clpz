% :- library("dcg").
% :- library("format").
% :- library("is").
% 
% :- op(950, fx, *). *(_).
% 
% var(T) :-
%     variable(T).
% 
% member(E, Es) :-
%     list_element(Es, E).
% 
% compare(O, T, U) :-
%     term_compare(O, T, U).

:- include("../../reif").
:- include("../sicstus/compatibility").
:- include("../operators").
:- include("../integer").
:- include("../utils").
:- include("../bound").
:- include("../cis").
:- include("../interval").
:- include("../domain").

interval(F-T, L0-U, L-U) :-
    L0 @=< U,
    between(L0, U, F0),
    between(F0, U, T0),
    L is T0+2,
    bound_from_defaulty(F0, F),
    bound_from_defaulty(T0, T).

test_contains :-
    list_length(_, N),
    portray_clause(user_error, N),
    L is -N,
    U = N,
    list_foldl(interval, Is, L-U, _),
    domain_from_intervals(Is, D),
    domain_to_numbers(D, Ns),
    list_element(Ns, E),
    (   \+ domain_contains(D, E)
    ;   \+ domain_contains(D, E, true)
    ;   domain_contains(D, E, false)
    ),
    portray_clause(user_error, D-E),
    halt.

test_ncontains :-
    list_length(_, N),
    portray_clause(user_error, N),
    L is -N,
    U = N,
    list_foldl(interval, Is, L-U, _),
    domain_from_intervals(Is, D),
    intervals_diff(Is, [L-U], Js),
    intervals_to_numbers(Js, Ns),
    list_element(Ns, E),
    (   domain_contains(D, E)
    ;   \+ domain_contains(D, E, false)
    ;   domain_contains(D, E, true)
    ),
    portray_clause(user_error, D-E),
    halt.

test_includes :-
    list_length(_, N),
    portray_clause(user_error, N),
    L is -N,
    U = N,
    list_foldl(interval, Is0, L-U, _),
    list_foldl(interval, Is1, L-U, _),
    domain_from_intervals(Is0, D0),
    domain_from_intervals(Is1, D1),
    (   \+ domain_includes(D0, D1)
    ;   \+ domain_includes(D0, D1, true)
    ;   domain_includes(D0, D1, false)
    ),
    domain_to_numbers(D0, Ns0),
    domain_to_numbers(D1, Ns1),
    list_map(list_element(Ns0), Ns1),
    portray_clause(user_error, domain_includes(D0, D1)),
    halt.

test_intersects :-
    list_length(_, N),
    portray_clause(user_error, N),
    L is -N,
    U = N,
    list_foldl(interval, Is0, L-U, _),
    list_foldl(interval, Is1, L-U, _),
    domain_from_intervals(Is0, D0),
    domain_from_intervals(Is1, D1),
    domain_inter(D0, D1, D),
    \+ if_(domain_intersects(D0, D1), domain_empty(D, false), domain_empty(D, true)),
    portray_clause(user_error, domain_intersects(D0, D1)-D),
    halt.
