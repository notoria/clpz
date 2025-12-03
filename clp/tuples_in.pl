%% tuples_in(+Tuples, +Relation).
%
% True iff all Tuples are elements of Relation. Each element of the
% list Tuples is a list of integers or finite domain variables.
% Relation is a list of lists of integers. Arbitrary finite relations,
% such as compatibility tables, can be modeled in this way. For
% example, if 1 is compatible with 2 and 5, and 4 is compatible with 0
% and 3:
%
% ```
% ?- tuples_in([[X,Y]], [[1,2],[1,5],[4,0],[4,3]]), X = 4.
% X = 4,
% Y in 0\/3.
% ```
%
% As another example, consider a train schedule represented as a list
% of quadruples, denoting departure and arrival places and times for
% each train. In the following program, Ps is a feasible journey of
% length 3 from A to D via trains that are part of the given schedule.
%
% ```
% trains([[1,2,0,1],
%         [2,3,4,5],
%         [2,3,0,1],
%         [3,4,5,6],
%         [3,4,2,3],
%         [3,4,8,9]]).
%
% threepath(A, D, Ps) :-
%         Ps = [[A,B,_T0,T1],[B,C,T2,T3],[C,D,T4,_T5]],
%         T2 #> T1,
%         T4 #> T3,
%         trains(Ts),
%         tuples_in(Ps, Ts).
% ```
%
% In this example, the unique solution is found without labeling:
%
% ```
% ?- threepath(1, 4, Ps).
% Ps = [[1, 2, 0, 1], [2, 3, 4, 5], [3, 4, 8, 9]].
% ```

tuples_in(Tuples, Relation) :-
        must_be(list(list), Tuples),
        list_map(list_map(fd_variable), Tuples),
        must_be(list(list(integer)), Relation),
        % Tuples ins inf..sup,
        domain_from_bounds(inf, sup, D), list_map(list_map('@in'(D)), Tuples),
        queue_empty(Q0),
        phrase(tuples_relation(Tuples, Relation), [Q0], [Q]),
        list_append(Tuples, Vs),
        queue_unify(Vs),
        phrase(propagator_catalyze, [Q], _).

tuple_relation(Tuple, Relation) -->
        { relation_unifiable(Relation, Tuple, Us, _, _) },
        (   { ground(Tuple) }
        ->  { once(member(Tuple, Relation)) }
        ;   tuple_domain(Tuple, Us),
            (   { Tuple = [_,_|_] }
            ->  tuple_freeze(Tuple, Us)
            ;   []
            )
        ).

tuples_relation([], _) --> [].
tuples_relation([Tuple|Tuples], Relation) -->
        { relation_unifiable(Relation, Tuple, Us, _, _) },
        (   ground(Tuple) -> { once(member(Tuple, Relation)) }
        ;   tuple_domain(Tuple, Us),
            (   Tuple = [_,_|_] -> tuple_freeze(Tuple, Us)
            ;   []
            )
        ),
        tuples_relation(Tuples, Relation).

list_first_rest([L|Ls], L, Ls).

tuple_domain([], _) --> [].
tuple_domain([T|Ts], Relation0) -->
        {   list_map(list_first_rest, Relation0, Firsts0, Relation1),
            sort(Firsts0, Firsts)
        },
        (   Firsts = [Unique] -> T = Unique
        ;   (   var(T) ->
                { domain_from_numbers(Firsts, FDom),
                  fd_get(T, TDom, TPs),
                  domain_inter(TDom, FDom, TDom1) },
                fd_put(T, TDom1, TPs)
            ;   []
            )
        ),
        tuple_domain(Ts, Relation1).

tuple_freeze(Tuple, Relation) -->
    (   { ground(Tuple) }
    ->  { once(member(Tuple, Relation)) }
    ;   { put_attr(R, clpz_relation, Relation),
          propagator_from_constraint(rel_tuple(R,Tuple), P) },
        map('@tuple_freeze'(P), Tuple)
    ).

'@tuple_freeze'(P, T) -->
    (   { var(T) }
    ->  propagator_variable(P, T),
        propagator_queue(P)
    ;   []
    ).

relation_unifiable([], _, [], Changed, Changed).
relation_unifiable([R|Rs], Tuple, Us, Changed0, Changed) :-
        (   all_in_domain(R, Tuple) ->
            Us = [R|Rest],
            relation_unifiable(Rs, Tuple, Rest, Changed0, Changed)
        ;   relation_unifiable(Rs, Tuple, Us, true, Changed)
        ).

all_in_domain([], []).
all_in_domain([A|As], [T|Ts]) :-
        (   fd_get(T, Dom, _) ->
            domain_contains(Dom, A)
        ;   T =:= A
        ),
        all_in_domain(As, Ts).
