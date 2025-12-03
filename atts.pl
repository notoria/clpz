% Special for CLP(Z)

put_atts(_, A) :-
    var(A),
    throw(error(instantiation_error,put_atts/2)).
put_atts(_, A) :-
    \+ member(A, [[],[_|_],+_,-_]),
    throw(error(domain_error(access,A),put_atts/2)).
put_atts(_, []).
put_atts(Var, [A|As]) :-
    put_atts(Var, A),
    put_atts(Var, As).
put_atts(Var, +A) :-
    put_verifier(+, Var, verify),
    put_reifier(+, Var, attribute_goals),
    put_attribute(+, Var, A).
put_atts(Var, -A) :-
    put_verifier(-, Var, verify),
    put_reifier(-, Var, attribute_goals),
    put_attribute(-, Var, A).

get_atts(_, A) :-
    var(A),
    throw(error(instantiation_error,get_atts/2)).
get_atts(_, A) :-
    \+ member(A, [[],[_|_],+_,-_]),
    throw(error(domain_error(access,A),get_atts/2)).
get_atts(_, []).
get_atts(Var, [A|As]) :-
    get_atts(Var, A),
    get_atts(Var, As).
get_atts(Var, +A) :-
    get_attribute(+, Var, A).
get_atts(Var, -A) :-
    get_attribute(-, Var, A).

verify(Var, Other, Gs0, Gs) :-
    verify_attributes(Var, Other, Gs1),
    list_append(Gs1, Gs, Gs0).
