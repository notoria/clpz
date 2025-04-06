can_be(What, Term) :-
    (   var(Term)
    ->  true
    ;   must_be(What, Term)
    ).

error:must_be(integer, T) :-
    (   var(T)
    ->  throw(error(instantiation_error,must_be/2))
    ;   integer(T)
    ->  true
    ;   throw(error(type_error(integer,T),must_be/2))
    ).

% instantiation_error(Where) :-
%     throw(error(instantiation_error,Where)).

type_error(Type, Term, Where) :-
    throw(error(type_error(Type,Term),Where)).

domain_error(Type, Term, Where) :-
    throw(error(domain_error(Type,Term),Where)).

