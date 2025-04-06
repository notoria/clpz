%% chain(+Relation, +Zs)
%
% Zs form a chain with respect to Relation. Zs is a list of finite
% domain variables that are a chain with respect to the partial order
% Relation, in the order they appear in the list. Relation must be #=,
% #=<, #>=, #< or #>. For example:
%
% ```
% ?- chain(#>=, [X,Y,Z]).
% X#>=Y,
% Y#>=Z.
% ```

chain(Relation, Zs) :-
        must_be(list, Zs),
        maplist(fd_variable, Zs),
        must_be(ground, Relation),
        (   chain_relation(Relation) -> true
        ;   domain_error(chain_relation, Relation)
        ),
        chain_(Zs, Relation).

chain_([], _).
chain_([X|Xs], Relation) :- foldl(chain(Relation), Xs, X, _).

chain_relation(#=).
chain_relation(#<).
chain_relation(#=<).
chain_relation(#>).
chain_relation(#>=).

chain(Relation, X, Prev, X) :- call(Relation, #Prev, #X).
