/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Membership Constraints
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

'@in'(D, V) :-
    (   var(V)
    ->  propagators_empty(Ps),
        queue_empty(Q),
        put_attr(W, clpz, clpz_attr(no,no,no,D,Ps,Q)),
        V = W
    ;   domain_contains(D, V)
    ).
    % (   fd_get(V, VD0, VPs) ->
    %     domain_inter(Dom, VD0, VD),
    %     fd_put(V, VD, VPs),
    %     reinforce(V) % QUESTION: Why?
    % ;   domain_contains(Dom, V)
    % ).

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

Var in D0 :-
    fd_variable(Var),
    (   drep(D0)
    ->  true
    ;   domain_error(clpz_domain, D0)
    ),
    drep_to_domain(D0, D),
    '@in'(D, Var),
    reinforce(Var). % QUESTION: Why? Is it needed?

fd_variable(V) :-
    (   var(V)
    ->  true
    ;   integer(V)
    ->  true
    ;   type_error(integer, V)
    ).

%% ins(+Vars, +Domain)
%
%  The variables in the list Vars are elements of Domain.

Vs ins D0 :-
    fd_must_be_list(Vs),
    list_map(fd_variable, Vs),
    (   drep(D0)
    ->  true
    ;   domain_error(clpz_domain, D0)
    ),
    drep_to_domain(D0, D),
    list_map('@in'(D), Vs),
    list_map(reinforce, Vs). % QUESTION: Why? Is it needed?

fd_must_be_list(Ls) :-
        (   fd_var(Ls) -> type_error(list, Ls)
        ;   must_be(list, Ls)
        ).

fd_must_be_list(Ls, Where) :-
        (   fd_var(Ls) -> type_error(list, Ls, Where)
        ;   must_be(list, Where, Ls)
        ).
