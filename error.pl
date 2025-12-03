% instantiation_error(Ctx) :-
%     throw(error(instantiation_error,Ctx)).

type_error(Type, Term, Ctx) :-
    throw(error(type_error(Type,Term),Ctx)).

domain_error(Domain, Term, Ctx) :-
    throw(error(domain_error(Domain,Term),Ctx)).
