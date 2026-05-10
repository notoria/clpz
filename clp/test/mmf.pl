:- flag(occurs_check, false).
:- library("dcg").
:- library("list").
:- library("format").
:- library("is").

var(T) :- variable(T).
nonvar(T) :- nonvariable(T).
compare(R, A, B) :- term_compare(R, A, B).
term_variables(T, Vs) :- '$unique_variables'(T, Vs).
copy_term(T, U) :- copy(T, U).

% :- include("../header").
:- include("../operators").
:- include("../utils").
:- include("../integer").
:- include("../bound").
:- include("../cis").
:- include("../interval").
:- include("../domain").
:- include("../add_mul_bounds").
% :- include("../z").

b(inf).
b(n(_)).
b(sup).

ideal(N, ZD, YD, XD0, XD) :-
    I0 cis -n(N),
    S0 cis n(N),
    domain_from_bounds(I0, S0, D0),
    findall(
        F0,
        (   domain_direction_element(D0, up, F0),
            domain_direction_element(YD, up, F1),
            n(E) cis n(F0)*n(F1),
            domain_member(ZD, E)
        ),
        [F|Fs]
    ),
    list_foldl(imin, Fs, F, I1),
    list_foldl(imax, Fs, F, S1),
    domain_from_bounds(n(I1), n(S1), XD1),
    domain_inter(XD0, XD1, XD2),
    findall(
        F0,
        (   domain_direction_element(XD2, up, F0),
            domain_direction_element(YD, up, F1),
            n(E) cis n(F0)*n(F1),
            domain_member(ZD, E)
        ),
        [G|Gs]
    ),
    list_foldl(imin, Gs, G, I),
    list_foldl(imax, Gs, G, S),
    domain_from_bounds(n(I), n(S), XD).

imin(N, S0, S) :-
    S is min(N,S0).

imax(N, S0, S) :-
    S is max(N,S0).

bad :-
    U = 7, L is -U,
    Bs = [L0,U0,L1,U1,L2,U2],
    list_map(b, Bs),
    % list_map(copy_term(n(_)), Bs),
    term_variables(L0-U0, Vs0), list_map(integer_between(L, U), Vs0),
    cis_le(L0,U0), cis_lt(L0, sup), cis_lt(inf, U0),
    term_variables(L1-U1, Vs1), list_map(integer_between(L, U), Vs1),
    cis_le(L1,U1), cis_lt(L1, sup), cis_lt(inf, U1),
    term_variables(L2-U2, Vs2), list_map(integer_between(L, U), Vs2),
    cis_le(L2,U2), cis_lt(L2, sup), cis_lt(inf, U2),
    % min_max_factor(L0, U0, L1, U1, L3, U3), % good
    min_max_factor(L0, U0, L1, U1, L2, U2, L3, U3), % how to handle empty set
    % [n(7),sup,n(7),sup,n(-3),n(-3)]+[n(1),n(-3)]
    % domain_from_bounds(L1, U1, YD), domain_length(YD, n(_)),
    % domain_from_bounds(L0, U0, ZD), % domain_length(ZD, n(_)),
    % domain_from_bounds(L2, U2, D2),
    % ideal(U, ZD, YD, D2, XD),
    \+ domain_from_bounds(L3, U3, _),
    portray_clause(user_output, Bs+[L3,U3]),
    false.

dom :-
    U = 7, L is -U,
    Bs = [L0,U0,L1,U1,L2,U2],
    % list_map(b, Bs),
    list_map(copy_term(n(_)), Bs),
    term_variables(L0-U0, Vs0), list_map(integer_between(L, U), Vs0),
    cis_le(L0,U0), cis_lt(L0, sup), cis_lt(inf, U0),
    term_variables(L1-U1, Vs1), list_map(integer_between(L, U), Vs1),
    cis_le(L1,U1), cis_lt(L1, sup), cis_lt(inf, U1),
    term_variables(L2-U2, Vs2), list_map(integer_between(L, U), Vs2),
    cis_le(L2,U2), cis_lt(L2, sup), cis_lt(inf, U2),
    min_max_factor(L0, U0, L1, U1, L2, U2, L3, U3),
    % min_max_factor(L0, U0, L1, U1, L3, U3), % good
    domain_from_bounds(L0, U0, ZD), % domain_length(ZD, n(_)),
    domain_from_bounds(L1, U1, YD), domain_length(YD, n(_)),
    domain_from_bounds(L3, U3, XD0), domain_length(XD0, n(_)),
    domain_from_bounds(L2, U2, D2),
    ideal(U, ZD, YD, D2, XD),
    XD0 \== XD,
    domain_from_bounds(L4, U4, XD),
    % \+ (L3 cis_le L4, U4 cis_le U3),
    portray_clause(user_output, Bs+[L3,U3]+[L4,U4]),
    false.

gen0 :-
    U = 3, L is -U,
    Bs = [L0,U0,L1,U1,L2,U2],
    list_map(b, Bs),
    call_nth(
        (   term_variables(L0-U0, Vs0), list_map(integer_between(L, U), Vs0),
            cis_le(L0,U0), cis_lt(L0, sup), cis_lt(inf, U0),
            term_variables(L1-U1, Vs1), list_map(integer_between(L, U), Vs1),
            cis_le(L1,U1), cis_lt(L1, sup), cis_lt(inf, U1),
            term_variables(L2-U2, Vs2), list_map(integer_between(L, U), Vs2),
            cis_le(L2,U2), cis_lt(L2, sup), cis_lt(inf, U2)
        ),
        Nth
    ),
    interval_factor(L0-U0, L1-U1, Is0), intervals_inter([L2-U2], Is0, Is), Is = [_|_], domain_from_intervals(Is, D), domain_infimum(D, Min), domain_supremum(D, Max),
    % min_max_factor(L0, U0, L1, U1, L2, U2, Min, Max),
    % min_max_factor(L0, U0, L1, U1, Min, Max),
    portray_clause(user_output, Nth+Bs+[Min,Max]),
    false.

gen :-
    % TODO: U = 7 % 11390625/24137569 cases with/without infinites
    U = 3, L is -U,
    Bs = [L0,U0,L1,U1,L2,U2],
    list_map(b, Bs),
    call_nth(
        (   term_variables(L0-U0, Vs0), list_map(integer_between(L, U), Vs0),
            cis_le(L0,U0), cis_lt(L0, sup), cis_lt(inf, U0),
            term_variables(L1-U1, Vs1), list_map(integer_between(L, U), Vs1),
            cis_le(L1,U1), cis_lt(L1, sup), cis_lt(inf, U1),
            term_variables(L2-U2, Vs2), list_map(integer_between(L, U), Vs2),
            cis_le(L2,U2), cis_lt(L2, sup), cis_lt(inf, U2)
        ),
        Nth
    ),
    min_max_factor(L0, U0, L1, U1, L2, U2, Min, Max),
    % min_max_factor(L0, U0, L1, U1, Min, Max),
    portray_clause(user_output, Nth+Bs+[Min,Max]),
    false.

mmf :-
    U = 3, L is -U,
    Bs = [L0,U0,L1,U1],
    list_map(b, Bs),
    term_variables(Bs, Vs),
    list_map(integer_between(L, U), Vs),
    cis_le(L0,U0), cis_lt(L0, sup), cis_lt(inf, U0),
    cis_le(L1,U1), cis_lt(L1, sup), cis_lt(inf, U1),
    min_max_factor(L0, U0, L1, U1, Min, Max),
    portray_clause(user_output, Bs+[Min,Max]),
    false.

test :-
    list_map(b, [YL,YU,XL,XU]),
    term_variables([YL,YU,XL,XU], Vs),
    list_map(integer_between(-3, 3), [Z|Vs]),
    cis_gt(YU,YL),
    cis_gt(XU,XL),
    % min_max_factor(n(Z), n(Z), YL, YU, XL, XU, NXL, NXU),
    min_max_factor(n(Z), n(Z), YL, YU, XL, XU, NXL, NXU),
    portray_clause(user_output, n(Z)+[YL,YU,XL,XU]+[NXL,NXU]),
    false.
