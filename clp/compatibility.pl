/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Compatibility predicates.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

seq([]) --> [].
seq([E|Es]) --> [E], seq(Es).

cyclic_term(T) :-
        \+ acyclic_term(T).

must_be(What, Term) :- must_be(What, unknown(Term)-1, Term).

must_be(Type, _, Term) :-
        \+ member(Type, [ground,acyclic,list,list(_)]),
        error:must_be(Type, Term).
must_be(ground, _, Term) :-
        (   ground(Term) -> true
        ;   instantiation_error(Term)
        ).
must_be(acyclic, Where, Term) :-
        (   acyclic_term(Term) ->
            true
        ;   domain_error(acyclic_term, Term, Where)
        ).
must_be(list, Where, Term) :-
        (   list_si(Term) -> true
        ;   type_error(list, Term, Where)
        ).
must_be(list(What), Where, Term) :-
        must_be(list, Where, Term),
        maplist(must_be(What, Where), Term).


instantiation_error(Term) :- instantiation_error(Term, unknown(Term)-1).

instantiation_error(_, Goal-Arg) :-
        throw(error(instantiation_error, instantiation_error(Goal, Arg))).


domain_error(Expectation, Term) :-
        domain_error(Expectation, Term, unknown(Term)-1).

type_error(Expectation, Term) :-
        type_error(Expectation, Term, unknown(Term)-1).


:- meta_predicate(partition(1, ?, ?, ?)).

partition(Pred, Ls0, As, Bs) :-
        include(Pred, Ls0, As),
        exclude(Pred, Ls0, Bs).


partition(_O_2, [], [], [], []).
partition(O_2, [X|Xs], Ls, Es, Gs) :-
    call(O_2, X, R),
    partition_(R, X, O_2, Xs, Ls, Es, Gs).

partition_(<, X, O_2, Xs, [X|Ls], Es, Gs) :-
    partition(O_2, Xs, Ls, Es, Gs).
partition_(=, X, O_2, Xs, Ls, [X|Es], Gs) :-
    partition(O_2, Xs, Ls, Es, Gs).
partition_(>, X, O_2, Xs, Ls, Es, [X|Gs]) :-
    partition(O_2, Xs, Ls, Es, Gs).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   include/3 and exclude/3
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- meta_predicate(include(1, ?, ?)).

include(_, [], []).
include(Goal, [L|Ls0], Ls) :-
        (   call(Goal, L) ->
            Ls = [L|Rest]
        ;   Ls = Rest
        ),
        include(Goal, Ls0, Rest).

:- meta_predicate(exclude(1, ?, ?)).

exclude(_, [], []).
exclude(Goal, [L|Ls0], Ls) :-
        (   call(Goal, L) ->
            Ls = Rest
        ;   Ls = [L|Rest]
        ),
        exclude(Goal, Ls0, Rest).

%:- discontiguous clpz:goal_expansion/5.
