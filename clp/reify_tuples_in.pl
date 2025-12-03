tuples_in_conjunction(Tuples, Relation, Conj) :-
        list_map(tuple_in_disjunction(Relation), Tuples, Disjs),
        fold_statement(conjunction, Disjs, Conj).

tuple_in_disjunction(Relation, Tuple, Disj) :-
        list_map(tuple_in_conjunction(Tuple), Relation, Conjs),
        fold_statement(disjunction, Conjs, Disj).

tuple_in_conjunction(Tuple, Element, Conj) :-
        list_map(var_eq, Tuple, Element, Eqs),
        fold_statement(conjunction, Eqs, Conj).

fold_statement(Operation, List, Statement) :-
        (   List = [] -> Statement = 1
        ;   List = [First|Rest],
            list_foldl(Operation, Rest, First, Statement)
        ).

conjunction(E, Conj, Conj #/\ E).

disjunction(E, Disj, Disj #\/ E).

var_eq(V, N, #V #= N).
