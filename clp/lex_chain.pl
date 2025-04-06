%% lex_chain(+Lists)
%
% Lists are lexicographically non-decreasing.

lex_chain(Lss) :-
        must_be(list(list), lex_chain(Lss)-1, Lss),
        maplist(maplist(fd_variable), Lss),
        (   Lss == [] -> true
        ;   Lss = [First|Rest],
            make_propagator(presidual(lex_chain(Lss)), Prop),
            foldl(lex_chain_(Prop), Rest, First, _)
        ).

lex_chain_(Prop, Ls, Prev, Ls) :-
        maplist(prop_init(Prop), Ls),
        lex_le(Prev, Ls).

lex_le([], []).
lex_le([V1|V1s], [V2|V2s]) :-
        #V1 #=< #V2,
        (   integer(V1) ->
            (   integer(V2) ->
                (   V1 =:= V2 -> lex_le(V1s, V2s) ;  true )
            ;   freeze(V2, lex_le([V1|V1s], [V2|V2s]))
            )
        ;   freeze(V1, lex_le([V1|V1s], [V2|V2s]))
        ).
