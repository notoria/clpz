:- include("core").

append([], []).
append([Es0|Ess], Es) :-
    append(Es0, Es1, Es),
    append(Ess, Es1).

append([], Es, Es).
append([E|Es0], Es1, [E|Es]) :-
    append(Es0, Es1, Es).

foldl(_, [], S, S).
foldl(G_3, [E|Es], S0, S) :-
    call(G_3, E, S0, S1),
    foldl(G_3, Es, S1, S).

member(E, Es) :-
    element(Es, E).

length(Es, N) :-
    (   var(N)
    ->  '@length'(Es, 0, N)
    ;   integer(N)
    ->  N @>= 0,
        '@length'(Es, 0, N)
    ).

'@length'(Es, N0, N) :-
    (   N0 == N
    ->  Es = []
    ;   '@@length'(Es, N0, N)
    ).

'@@length'([], N, N).
'@@length'([_|Es], N0, N) :-
    succ(N0, N1),
    '@length'(Es, N1, N).

reverse(Es0, Es) :-
    '@reversed'(Es0, Es, [], Es).

'@reversed'([], [], Es, Es).
'@reversed'([E|Es0], [_|Es1], Es2, Es) :-
    '@reversed'(Es0, Es1, [E|Es2], Es).

select(E0, [E0|Es], Es).
select(E0, [E|Es0], [E|Es]) :-
    select(E0, Es0, Es).

maplist(_, []).
maplist(G_1, [E|Es]) :-
    call(G_1, E),
    maplist(G_1, Es).

maplist(_, [], []).
maplist(G_2, [E0|Es0], [E|Es]) :-
    call(G_2, E0, E),
    maplist(G_2, Es0, Es).

maplist(_, [], [], []).
maplist(G_3, [E0|Es0], [E1|Es1], [E|Es]) :-
    call(G_3, E0, E1, E),
    maplist(G_3, Es0, Es1, Es).

list_si(Es0) :-
    '$skip_max_list'(_, _, Es0, Es),
    (   nonvar(Es)
    ->  Es = []
    ;   throw(error(instantiation_error,list_si/1))
    ).

same_length([], []).
same_length([_|Es0], [_|Es]) :-
    same_length(Es0, Es).

nth0(N, Es0, E) :-
    nth0(N, Es0, E, _).

nth0(N, Es0, E, Es) :-
    % can_be(integer, N),
    % can_be(list, Es0),
    % can_be(list, Es),
    (   var(N)
    ->  '@nth0'(E, 0, N, Es0, Es)
    ;   integer(N),
        '@nth0'(E, 0, N, Es0, Es1),
        Es = Es1
    ).

'@nth0'(E, N0, N, Es0, Es) :-
    (   N0 == N
    ->  [E|Es] = Es0
    % ;   N0 = N,
    %     Es0 = [E|Es]
    % ;   succ(N0, N1),
    %     [_|Es1] = Es0,
    %     '@nth0'(E, N1, N, Es1, Es)
    ;   '@@nth0'(E, N0, N, Es0, Es)
    ).

'@@nth0'(E, N, N, [E|Es], Es).
'@@nth0'(E, N0, N, [_|Es0], Es) :-
    succ(N0, N1),
    '@nth0'(E, N1, N, Es0, Es).

nth1(N, Es0, E) :-
    nth1(N, Es0, E, _).

nth1(N, Es0, E, Es) :-
    N \== 0,
    nth0(N, [_|Es0], E, Es),
    N \== 0.

sum_list(Es, S) :-
    foldl(sum_, Es, 0, S).

sum_(E, S0, S) :-
    S is E+S0.
