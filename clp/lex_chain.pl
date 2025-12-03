%% lex_chain(+Lists)
%
% Lists are lexicographically non-decreasing.

lex_chain(Lss) :-
    must_be(list(list), lex_chain(Lss)-1, Lss),
    list_map(list_map(fd_variable), Lss),
    % Lss ins inf..sup,
    domain_from_bounds(inf, sup, D), list_map(list_map('@in'(D)), Lss),
    '@lex_chain'(Lss).

'@lex_chain'([]).
'@lex_chain'([Ls0|Lss0]) :-
    Lss = [Ls0|Lss0],
    propagator_from_constraint(presidual(lex_chain(Lss)), P),
    % list_map(list_map(propagator_variable(P)), Lss), list_chain(lex_le, Lss).
    list_foldl('@lex_chain'(P), Lss0, Ls0, _). % QUESTION: Why no `propagator_variable/2` for `Ls0`?
    % list_chain('@lex_chain'(P), Lss).

'@lex_chain'(P, E, Ls0, Ls) :-
    Ls = E,
    list_map(propagator_variable(P), Ls),
    lex_le(Ls0, Ls).

lex_le([], _).
lex_le([V1|V1s], [V2|V2s]) :-
    #V1 #=< #V2,
    (   var(V1)
    ->  freeze(V1, lex_le([V1|V1s], [V2|V2s]))
    ;   var(V2)
    ->  freeze(V2, lex_le([V1|V1s], [V2|V2s]))
    ;   integer(V1),
        integer(V2),
        (   V1 =:= V2
        ->  lex_le(V1s, V2s)
        ;   true
        )
    ).
