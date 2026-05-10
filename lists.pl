:- include("core").
:- include("list").

% goal_expansion(list_map(G_1, Es), maplist(G_1, Es)).
% goal_expansion(list_map(G_2, Es0, Es), maplist(G_2, Es0, Es)).
% goal_expansion(list_map(G_3, Es0, Es1, Es), maplist(G_3, Es0, Es1, Es)).
% goal_expansion(list_map(G_4, Es0, Es1, Es2, Es), maplist(G_4, Es0, Es1, Es2, Es)).

append(Ess, Es) :-
    list_append(Ess, Es).

append(Es0, Es1, Es) :-
    list_append(Es0, Es1, Es).

foldl(G_3, Es, S0, S) :-
    list_foldl(G_3, Es, S0, S).

member(E, Es) :-
    list_element(Es, E).

length(Es, N) :-
    list_length(Es, N).

reverse(Es0, Es) :-
    list_reversed(Es0, Es).

select(E0, Es0, Es) :-
    list_select(E0, Es0, Es).

maplist(G_1, Es) :-
    list_map(G_1, Es).

maplist(G_2, Es0, Es) :-
    list_map(G_2, Es0, Es).

maplist(G_3, Es0, Es1, Es) :-
    list_map(G_3, Es0, Es1, Es).

list_si(Es0) :-
    '$skip_max_list'(_, _, Es0, Es),
    (   var(Es),
        throw(error(instantiation_error,list_si/1))
    ;   Es = []
    ).

same_length(Es0, Es) :-
    list_equisized(Es0, Es).

nth0(N, Es0, E) :-
    list_nth0(N, Es0, E, _).

nth1(N, Es0, E) :-
    nth1(N, Es0, E, _).

nth1(N, Es0, E, Es) :-
    N \== 0,
    list_nth0(N, [_|Es0], E, Es),
    N \== 0.

sum_list(Es, S) :-
    foldl(sum_, Es, 0, S).

sum_(E, S0, S) :-
    S is E+S0.

transpose(Lss, Tss) :-
    list_transpose(Lss, Tss).
