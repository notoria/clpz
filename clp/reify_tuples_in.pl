tuples_in_conjunction(Tuples, Relation, Conj) :-
        maplist(tuple_in_disjunction(Relation), Tuples, Disjs),
        fold_statement(conjunction, Disjs, Conj).

tuple_in_disjunction(Relation, Tuple, Disj) :-
        maplist(tuple_in_conjunction(Tuple), Relation, Conjs),
        fold_statement(disjunction, Conjs, Disj).

tuple_in_conjunction(Tuple, Element, Conj) :-
        maplist(var_eq, Tuple, Element, Eqs),
        fold_statement(conjunction, Eqs, Conj).

fold_statement(Operation, List, Statement) :-
        (   List = [] -> Statement = 1
        ;   List = [First|Rest],
            foldl(Operation, Rest, First, Statement)
        ).

conjunction(E, Conj, Conj #/\ E).

disjunction(E, Disj, Disj #\/ E).

var_eq(V, N, #V #= N).
