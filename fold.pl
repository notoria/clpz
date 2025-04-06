% Interesting generalization but not usable (infinite loop)

foldl(_, S, S).
foldl(G_2, S0, S) :-
    call(G_2, S0, S1),
    foldl(G_2, S1, S).

foldr(_, S, S).
foldr(G_2, S0, S) :-
    foldr(G_2, S0, S1),
    call(G_2, S1, S).
