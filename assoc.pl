:- include("avlt").
:- include("list").

empty_assoc(T) :-
    avlt_empty(T).

assoc_to_list(T, Es) :-
    avlt_list(in, lr, entry, T, Es).

'@list_to_assoc'(K-V, T0, T) :-
    avlt_insert(K, V, T0, T).

list_to_assoc(Es, T) :-
    avlt_empty(T0),
    list_foldl('@list_to_assoc', Es, T0, T).

get_assoc(K, T, V) :-
    avlt_search(T, K, V).

put_assoc(K, T0, V, T) :-
    avlt_insert(K, V, T0, T).
