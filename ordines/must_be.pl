% :- include("list").

must_be(Term, Type, Goal, Arg) :-
    (   var(Term)
    ->  instantiation_error(Goal-Arg)
    ;   '@must_be'(Type, Goal, Arg, Term)
    ).

'@must_be'(Type, Goal, Arg, _Term) :-
    var(Type),
    instantiation_error(Goal-Arg).
'@must_be'(ground, Goal, Arg, Term) :-
    \+ ground(Term),
    instantiation_error(Goal-Arg).
'@must_be'(acyclic, Goal, Arg, Term) :-
    \+ acyclic_term(Term),
    domain_error(acyclic, Term, Goal-Arg).
'@must_be'(list, Goal, Arg, Term) :-
    \+ list_si(Term),
    type_error(list, Term, Goal-Arg).
'@must_be'(list(Type), Goal, Arg, Term) :-
    '@must_be'(list, Goal, Arg, Term),
    \+ list_map('@must_be'(Type, Goal, Arg), Term).
'@must_be'(_Type, _Goal, _Arg, _Term).
