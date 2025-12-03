% must = strict, can = ??
% error(Goal, Arg, Kind, Type, Term)?
% error(Kind, Goal, Arg, Type, Term).
error(Kind, Goal, Arg, Type, Term) :-
    var(Kind),
    Ctxt = [goal-error(Kind, Goal, Arg, Type, Term),argument-1],
    throw(error(instantiation_error,Ctxt)).
error(Kind, Goal, Arg, Type, Term) :-
    var(Type),
    Ctxt = [goal-error(Kind, Goal, Arg, Type, Term),argument-4],
    throw(error(instantiation_error,Ctxt)).
error(Kind, Goal, Arg, Type, Term) :-
    var(Goal),
    Ctxt = [goal-error(Kind, Goal, Arg, Type, Term),argument-2],
    throw(error(instantiation_error,Ctxt)).
error(Kind, Goal, Arg, Type, Term) :-
    var(Arg),
    Ctxt = [goal-error(Kind, Goal, Arg, Type, Term),argument-3],
    throw(error(instantiation_error,Ctxt)).
error(Kind, Goal, Arg, Type, Term) :-
    \+ list_element([can,must], Kind),
    Ctxt = [goal-error(Kind, Goal, Arg, Type, Term),argument-1],
    throw(error(domain_error(ekind,Kind),Ctxt)).
error(Kind, Goal, Arg, integer, Term) :-
    (   var(Term)
    ->  (   Kind == can
        ->  true % freeze?
        ;   Kind == must
        ->  Ctxt = [goal-Goal,argument-Arg],
            throw(error(instantiation_error,Ctxt))
        )
    ;   integer(Term)
    ->  true
    ;   Ctxt = [goal-Goal,argument-Arg],
        throw(error(type_error(integer,Term),Ctxt))
    ).
