%% in(?Var, +Domain)
%
%  Var is an element of Domain. Domain is one of:
%
%         * Integer
%           Singleton set consisting only of _Integer_.
%         * Lower..Upper
%           All integers _I_ such that _Lower_ =< _I_ =< _Upper_.
%           _Lower_ must be an integer or the atom *inf*, which
%           denotes negative infinity. _Upper_ must be an integer or
%           the atom *sup*, which denotes positive infinity.
%         * Domain1 `\/` Domain2
%           The union of Domain1 and Domain2.

Var in Dom :- clpz_in(Var, Dom).

clpz_in(V, D) :-
        fd_variable(V),
        drep_to_domain(D, Dom),
        domain(V, Dom).

fd_variable(V) :- can_be(integer, V).

%% ins(+Vars, +Domain)
%
%  The variables in the list Vars are elements of Domain.

Vs ins D :-
        fd_must_be_list(Vs),
        maplist(fd_variable, Vs),
        drep_to_domain(D, Dom),
        domains(Vs, Dom).

fd_must_be_list(Ls) :-
        (   fd_var(Ls) -> type_error(list, Ls)
        ;   must_be(list, Ls)
        ).

fd_must_be_list(Ls, Where) :-
        (   fd_var(Ls) -> type_error(list, Ls, Where)
        ;   must_be(list, Where, Ls)
        ).
