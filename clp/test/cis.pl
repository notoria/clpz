% :- library("dcg").
% :- library("list").
% :- library("format").
% :- library("is").
% 
% var(T) :- variable(T).
% list_map(G_1, Es) :- list_map(G_1, Es).
% member(E, Es) :- list_element(Es, E).
% element(Es, E) :- list_element(Es, E).
% compare(R, A, B) :- term_compare(R, A, B).

:- include("../operators").
:- include("../cis").

cis_gen(G_1, S, E) :-
    phrase(cis_gen(E, S, 0), Is),
    list_map(G_1, Is).

cis_gen(n(I), S, S) --> [I].
cis_gen(inf, S, S) --> [].
cis_gen(sup, S, S) --> [].
cis_gen(sign(E0), S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S).
cis_gen(abs(E0), S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S).
cis_gen(-E0, S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S).
cis_gen(E0+E1, S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S2),
    cis_gen(E1, S2, S).
cis_gen(E0-E1, S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S2),
    cis_gen(E1, S2, S).
cis_gen(min(E0,E1), S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S2),
    cis_gen(E1, S2, S).
cis_gen(max(E0,E1), S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S2),
    cis_gen(E1, S2, S).
cis_gen(E0*E1, S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S2),
    cis_gen(E1, S2, S).
cis_gen(div(E0,E1), S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S2),
    cis_gen(E1, S2, S).
cis_gen(E0//E1, S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S2),
    cis_gen(E1, S2, S).
cis_gen(E0^E1, S0, S) -->
    { succ(S1, S0) },
    cis_gen(E0, S1, S2),
    cis_gen(E1, S2, S).

cis_test :-
    integer_between(0, 2, S),
    % cis_gen(list_element([-1,0,1]), S, E),
    cis_gen(integer_between(-3,3), S, E),
    findall(R, R cis E, Rs),
    portray_clause(user_output, E+Rs),
    false.
