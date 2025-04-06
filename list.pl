/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    List.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

% list_any(G_1, [E|Es]) :-
%     '@list_any'(G_1, E, Es).
% 
% '@list_any'(G_1, E, _) :-
%     call(G_1, E).
% '@list_any'(G_1, _, [E|Es]) :-
%     '@list_any'(G_1, E, Es).

list_any(G_1, [E|_]) :-
    call(G_1, E).
list_any(G_1, [_|Es]) :-
    list_any(G_1, Es).

% list_append(Es0, Es1, Es) :-
%     list_foldl(list_remove, Es0, Es, Es1).

list_append([], []).
list_append([Es0|Ess], Es) :-
    list_append(Es0, Es1, Es),
    list_append(Ess, Es1).

list_append([], Es, Es).
list_append([E|Es0], Es1, [E|Es]) :-
    list_append(Es0, Es1, Es).

list_foldl(_, [], S, S).
list_foldl(G_3, [E|Es], S0, S) :-
    call(G_3, E, S0, S1),
    list_foldl(G_3, Es, S1, S).

% list_foldl(_, [], [], S, S).
% list_foldl(G_4, [E0|Es0], [E|Es], S0, S) :-
%     call(G_4, E0, E, S0, S1),
%     list_foldl(G_4, Es0, Es, S1, S).

% list_foldr(G_3, Es, S0, S) :-
%     list_reversed(Es, Fs),
%     list_foldl(G_3, Fs, S0, S).

list_foldr(_, [], S, S).
list_foldr(G_3, [E|Es], S0, S) :-
    list_foldr(G_3, Es, S0, S1),
    call(G_3, E, S1, S).

'@list_link'(R_2, E, S0, S) :-
    call(R_2, S0, E),
    S = E.

list_chain(_, []).
list_chain(R_2, [E|Es]) :-
    list_foldl('@list_link'(R_2), Es, E, _).

% list_element([E|_], E).
% list_element([_|Es], E) :-
%     list_element(Es, E).

list_element(Es, E) :-
    '@list_element'(Es, E).

'@list_element'(_, E, E).
'@list_element'([E|Es], _, E0) :-
    '@list_element'(Es, E, E0).

list_last([E0|Es], E) :-
    list_last(Es, E0, E).

list_last([], E, E).
list_last([E0|Es], _, E) :-
    list_last(Es, E0, E).

list_length(Es, N) :-
    (   var(N)
    ->  '@list_length'(Es, 0, N)
    ;   integer(N)
    ->  N @>= 0,
        '@list_length'(Es, 0, N)
    ).

'@list_length'(Es, N0, N) :-
    (   N0 == N
    ->  Es = []
    ;   '@@list_length'(Es, N0, N)
    ).

'@@list_length'([], N, N).
'@@list_length'([_|Es], N0, N) :-
    succ(N0, N1),
    '@list_length'(Es, N1, N).

list_nth0(N, Es0, E) :-
    list_nth0(N, Es0, E, _).

list_nth0(N, Es0, E, Es) :-
    (   var(N)
    ->  '@list_nth0'(E, 0, N, Es0, Es)
    ;   integer(N),
        '@list_nth0'(E, 0, N, Es0, Es1),
        Es = Es1
    ).

'@list_nth0'(E, N0, N, Es0, Es) :-
    (   N0 == N
    ->  [E|Es] = Es0
    ;   '@@list_nth0'(E, N0, N, Es0, Es)
    ).

'@@list_nth0'(E, N, N, [E|Es], Es).
'@@list_nth0'(E, N0, N, [_|Es0], Es) :-
    succ(N0, N1),
    '@list_nth0'(E, N1, N, Es0, Es).

% list_reversed(Es0, Es) :-
%     list_equisized(Es0, Es),
%     list_foldl(list_insert, Es0, [], Es).

list_reversed(Es0, Es) :-
    '@list_reversed'(Es0, Es, [], Es).

'@list_reversed'([], [], Es, Es).
'@list_reversed'([E|Es0], [_|Es1], Es2, Es) :-
    '@list_reversed'(Es0, Es1, [E|Es2], Es).

% list_congruent([], []).
list_equisized([], []).
list_equisized([_|As], [_|Bs]) :-
    list_equisized(As, Bs).

% avlt is better than this.
% list_replace(E0, E, [E0|Es], [E|Es]).
% list_replace(E0, E, [E1|Es0], [E1|Es]) :-
%     list_replace(E0, E, Es0, Es).

list_select(E0, [E0|Es], Es).
list_select(E0, [E|Es0], [E|Es]) :-
    list_select(E0, Es0, Es).

% not freeze/2 friendly.
% list_nselect(N, E, Es0, Es) :-
%     var(N), !,
%     '@list_nselect'(0, N, E, Es0, Es).
% list_nselect(N, E, Es0, Es) :-
%     integer(N), !,
%     '@list_nselect'(0, N, E0, Es0, Es1), !,
%     E = E0,
%     Es = Es1.
% 
% '@list_nselect'( N, N, E0, [E0|Es], Es).
% '@list_nselect'(N0, N, E0, [E|Es0], [E|Es]) :-
%     '$integer_add'(N0, 1, N1),
%     '@list_nselect'(N1, N, E0, Es0, Es).

list_take(E0, [E0|Es], Es).
list_take(E0, [_|Es0], Es) :-
    list_take(E0, Es0, Es).

% not freeze/2 friendly.
% list_ntake(N, E, Es0, Es) :-
%     var(N), !,
%     '@list_ntake'(0, N, E, Es0, Es).
% list_ntake(N, E, Es0, Es) :-
%     integer(N),
%     '$list_skip_max'(N0, N, Es0, Es1),
%     '@list_ntake'(N0, N, E0, Es1, Es2), !,
%     E = E0,
%     Es = Es2.
% 
% '@list_ntake'(N0, N, E, Es0, Es) :-
%     N0 == N, !,
%     Es0 = [E|Es].
% '@list_ntake'( N, N, E, [E|Es], Es).
% '@list_ntake'(N0, N, E, [_|Es0], Es) :-
%     '$integer_add'(N0, 1, N1),
%     '@list_ntake'(N1, N, E, Es0, Es).

% list_separate/3.
% list_extract/3.
list_split([], [], []).
list_split([A|As], Bs, [A|Cs]) :-
    list_split(As, Bs, Cs).
list_split([A|As], [A|Bs], Cs) :-
    list_split(As, Bs, Cs).

% list_sorted(R_2, Es0, Es) :-
%     '$sort'(R_2, Es0, Es1),
%     list_chain(R_2, Es1),
%     Es = Es1.
% 
% list_uniques(Es0, Es) :-
%     '$uniques'(Es0, Es1),
%     '@list_uniques'(Es1),
%     Es = Es1.
% 
% '@list_uniques'([]).
% '@list_uniques'([E|Es]) :-
%     list_map(@\=(E), Es),
%     '@list_uniques'(Es).
% 
% list_singles(Es0, Es) :-
%     list_uniques(Es0, _),
%     '$singles'(Es0, Es).

list_transpose([Ls|Lss], Tss) :-
    Ls = [_|_],
    '@list_transpose'(Ls, [Ls|Lss], Tss).

'@list_transpose'([], Lss0, []) :-
    '@list_column'(Lss0).
'@list_transpose'([_|Ls], Lss0, [Ts|Tss]) :-
    '@list_column'(Lss0, Ts, Lss),
    '@list_transpose'(Ls, Lss, Tss).

'@list_column'([]).
'@list_column'([[]|Es]) :-
    '@list_column'(Es).

'@list_column'([], [], []).
'@list_column'([[L|Ls]|Lss0], [L|Ts], [Ls|Lss]) :-
    '@list_column'(Lss0, Ts, Lss).

% list_map/N, N>1.
list_map(_, []).
list_map(G_1, [E|Es]) :-
    call(G_1, E),
    list_map(G_1, Es).

list_map(_, [], []).
list_map(G_2, [E0|Es0], [E|Es]) :-
    call(G_2, E0, E),
    list_map(G_2, Es0, Es).

list_map(_, [], [], []).
list_map(G_3, [E0|Es0], [E1|Es1], [E|Es]) :-
    call(G_3, E0, E1, E),
    list_map(G_3, Es0, Es1, Es).

list_insert(E, Es, [E|Es]).

% list_delete(E, [E|Es], Es).
list_remove(E, [E|Es], Es).
