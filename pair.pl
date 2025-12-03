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
