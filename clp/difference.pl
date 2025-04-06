%% all_different(+Vars)
%
% Like all_distinct/1, but with weaker propagation.

all_different(Ls) :-
        fd_must_be_list(Ls, all_different(Ls)-1),
        maplist(fd_variable, Ls),
        Orig = original_goal(_, all_different(Ls)),
        new_queue(Q0),
        phrase((all_different(Ls, [], Orig),do_queue), [Q0], _).

all_different([], _, _) --> [].
all_different([X|Right], Left, Orig) -->
        (   { var(X) } ->
            { make_propagator(pdifferent(Left,Right,X,Orig), Prop) },
            init_propagator_([X], Prop),
            trigger_prop(Prop)
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
%  ?- maplist(in, Vs,
%             [1\/3..4, 1..2\/4, 1..2\/4, 1..3, 1..3, 1..6]),
%     all_distinct(Vs).
%  false.
% ```

all_distinct(Ls) :-
        fd_must_be_list(Ls, all_distinct(Ls)-1),
        maplist(fd_variable, Ls),
        make_propagator(pdistinct(Ls), Prop),
        new_queue(Q0),
        phrase((distinct_attach(Ls, Prop, []),trigger_prop(Prop),do_queue), [Q0], _),
        variables_same_queue(Ls).

%% nvalue(?N, +Vars).
%
%  True if N is the number of distinct values taken by Vars. Vars is a
%  list of domain variables, and N is a domain variable. Can be
%  thought of as a relaxed version of all_distinct/1.

nvalue(N, Vars) :-
        fd_must_be_list(Vars),
        maplist(fd_variable, Vars),
        length(Vars, Len),
        N in 0..Len,
        zero_or_more(Vars, N),
        propagator_init_trigger(Vars, pnvalue(N, Vars)).

zero_or_more([], 0).
zero_or_more([_|_], N) :- N #> 0.
