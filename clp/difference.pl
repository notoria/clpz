%% all_different(+Vars)
%
% Like all_distinct/1, but with weaker propagation.

all_different(Ls) :-
        fd_must_be_list(Ls, all_different(Ls)-1),
        list_map(fd_variable, Ls),
        Ls ins inf..sup,
        % domain_from_bounds(inf, sup, D), list_map('@in'(D), Ls),
        Orig = original_goal(_,all_different(Ls)),
        queue_empty(Q0),
        phrase((all_different(Ls, [], Orig),propagator_catalyze), [Q0], _).

all_different([], _, _) --> [].
all_different([X|Right], Left, Orig) -->
        (   { var(X) } ->
            { propagator_from_constraint(pdifferent(Left,Right,X,Orig), Prop) },
            propagator_variable(Prop, X),
            propagator_queue(Prop)
        ;   exclude_fire(Left, Right, X)
        ),
        all_different(Right, [X|Left], Orig).

%% all_distinct(+Vars).
%
%  True iff Vars are pairwise distinct. For example, all_distinct/1
%  can detect that not all variables can assume distinct values given
%  the following domains:
%
% ```
%  ?- list_map(in, Vs,
%             [1\/3..4, 1..2\/4, 1..2\/4, 1..3, 1..3, 1..6]),
%     all_distinct(Vs).
%  false.
% ```

all_distinct(Ls) :-
        fd_must_be_list(Ls, all_distinct(Ls)-1),
        list_map(fd_variable, Ls),
        Ls ins inf..sup,
        % domain_from_bounds(inf, sup, D), list_map('@in'(D), Ls),
        propagator_from_constraint(pdistinct(Ls), Prop),
        queue_empty(Q0),
        phrase(
            (   distinct_attach(Ls, Prop, []),
                propagator_queue(Prop),
                propagator_catalyze
            ),
            [Q0],
            _
        ),
        queue_unify(Ls).

%% nvalue(?N, +Vars).
%
%  True if N is the number of distinct values taken by Vars. Vars is a
%  list of domain variables, and N is a domain variable. Can be
%  thought of as a relaxed version of all_distinct/1.

nvalue(N, Vars) :-
    fd_must_be_list(Vars),
    list_map(fd_variable, Vars),
    % domain_from_bounds(inf, sup, D), list_map('@in'(D), Vars),
    Vars ins inf..sup,
    list_length(Vars, Len),
    N in 0..Len,
    zero_or_more(Vars, N),
    propagator_from_constraint(pnvalue(N,Vars), P),
    propagator_trigger(P, Vars).

zero_or_more([], 0).
zero_or_more([_|_], N) :- #N #> #0.
