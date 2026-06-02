/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Pair
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

pair_key_value(K-V, K, V).

pairs_keys_values(KVs, Ks, Vs) :-
    list_map(pair_key_value, KVs, Ks, Vs).

pairs_keys(KVs, Ks) :-
    pairs_keys_values(KVs, Ks, _).

pairs_values(KVs, Vs) :-
    pairs_keys_values(KVs, _, Vs).

map_list_to_pair(G_2, E, K-E) :-
    call(G_2, E, K).

map_list_to_pairs(G_2, Es, KVs) :-
    list_map(map_list_to_pair(G_2), Es, KVs).

same_key(K0, Vs, KVs0, KVs) :-
    (   [K-V|KVs1] = KVs0,
        K0 == K
    ->  [V|Vs0] = Vs,
        same_key(K0, Vs0, KVs1, KVs)
    ;   Vs = [],
        KVs = KVs0
    ).

group_pairs_by_key([], []).
group_pairs_by_key([K-V|KVs0], [K-[V|Vs]|KVs]) :-
    same_key(K, Vs, KVs0, KVs1),
    group_pairs_by_key(KVs1, KVs).
