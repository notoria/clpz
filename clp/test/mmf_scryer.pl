:- use_module(library(lists)).
:- use_module(library(between)).
:- use_module(library(format)).
:- use_module(library(clpz)).

b(inf).
b(n(_)).
b(sup).

dom :-
    U = 3, L is -U,
    Bs = [L0,U0,L1,U1,L2,U2],
    list_map(b, Bs),
    term_variables(L0-U0, Vs0), list_map(between(L, U), Vs0),
    clpz:cis_ge(U0,L0), clpz:cis_gt(sup, L0), clpz:cis_gt(U0, inf),
    term_variables(L1-U1, Vs1), list_map(between(L, U), Vs1),
    clpz:cis_ge(U1,L1), clpz:cis_gt(sup, L1), clpz:cis_gt(U1, inf),
    term_variables(L2-U2, Vs2), list_map(between(L, U), Vs2),
    clpz:cis_ge(U2,L2), clpz:cis_gt(sup, L2), clpz:cis_gt(U2, inf),
    clpz:min_max_factor(L0, U0, L1, U1, L2, U2, Min, Max),
    % domain_from_bounds(Min, Max, Dom0),
    % domain_from_bounds(L2, U2, Dom1),
    % domain_inter(Dom0, Dom1, Dom), domain_empty(Dom, false),
    portray_clause(user_output, Bs+[Min,Max]),
    false.

gen :-
    % U = 7 % 11390625/24137569 cases with/without infinites
    U = 7, L is -U,
    Bs = [L0,U0,L1,U1,L2,U2],
    list_map(b, Bs),
    term_variables(L0-U0, Vs0), list_map(between(L, U), Vs0),
    clpz:cis_ge(U0,L0), clpz:cis_gt(sup, L0), clpz:cis_gt(U0, inf),
    term_variables(L1-U1, Vs1), list_map(between(L, U), Vs1),
    clpz:cis_ge(U1,L1), clpz:cis_gt(sup, L1), clpz:cis_gt(U1, inf),
    term_variables(L2-U2, Vs2), list_map(between(L, U), Vs2),
    clpz:cis_ge(U2,L2), clpz:cis_gt(sup, L2), clpz:cis_gt(U2, inf),
    clpz:min_max_factor(L0, U0, L1, U1, L2, U2, Min, Max),
    portray_clause(user_output, Bs+[Min,Max]),
    false.

mmf :-
    U = 3, L is -U,
    Bs = [L0,U0,L1,U1],
    list_map(b, Bs),
    term_variables(Bs, Vs),
    list_map(between(L, U), Vs),
    clpz:cis_ge(U0,L0), clpz:cis_gt(sup, L0), clpz:cis_gt(U0, inf),
    clpz:cis_ge(U1,L1), clpz:cis_gt(sup, L1), clpz:cis_gt(U1, inf),
    clpz:min_factor(L0, U0, L1, U1, Min), clpz:max_factor(L0, U0, L1, U1, Max),
    portray_clause(user_output, Bs+[Min,Max]),
    false.

test :-
    list_map(b, [YL,YU,XL,XU]),
    term_variables([YL,YU,XL,XU], Vs),
    list_map(between(-3, 3), [Z|Vs]),
    clpz:cis_gt(YU,YL),
    clpz:cis_gt(XU,XL),
    clpz:min_max_factor(n(Z), n(Z), YL, YU, XL, XU, NXL, NXU),
    portray_clause(user_output, n(Z)+[YL,YU,XL,XU]+[NXL,NXU]),
    false.
