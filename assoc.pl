:- include("avlt").

empty_assoc(T) :-
    avlt_empty(T).

assoc_to_list(T, Es) :-
    avlt_list(in, lr, entry, T, Es).

get_assoc(K, T, V) :-
    avlt_search(T, K, V).

put_assoc(K, T0, V, T) :-
    avlt_insert(K, V, T0, T).
