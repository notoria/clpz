%% global_cardinality(+Vs, +Pairs)
%
%  Global      Cardinality      constraint.        Equivalent      to
%  `global_cardinality(Vs, Pairs, [])`. Example:
%
% ```
% ?- Vs = [_,_,_], global_cardinality(Vs, [1-2,3-_]), label(Vs).
%    Vs = [1,1,3]
% ;  Vs = [1,3,1]
% ;  Vs = [3,1,1]
% ;  false.
% ```

global_cardinality(Xs, Pairs) :- global_cardinality(Xs, Pairs, []).

%% global_cardinality(+Vs, +Pairs, +Options)
%
%  Global Cardinality constraint. Vs  is  a   list  of  finite domain
%  variables, Pairs is a list  of  Key-Num   pairs,  where  Key is an
%  integer and Num is a finite  domain variable. The constraint holds
%  iff each V in Vs is equal to   some key, and for each Key-Num pair
%  in Pairs, the number of occurrences of   Key in Vs is Num. Options
%  is a list of options. Supported options are:
%
%  `consistency(value)`
%  A weaker form of consistency is used.
%
%  `cost(Cost, Matrix)`
%  Matrix is a list of rows, one for each variable, in the order
%  they occur in Vs. Each of these rows is a list of integers, one
%  for each key, in the order these keys occur in Pairs. When
%  variable v\_i is assigned the value of key k\_j, then the
%  associated cost is Matrix\_{ij}. Cost is the sum of all costs.

global_cardinality(Xs, Pairs, Options) :-
    must_be(list(list), [Xs,Pairs,Options]),
    list_map(fd_variable, Xs),
    list_map(gcc_pair, Pairs),
    pairs_keys_values(Pairs, Keys, Nums),
    (   sort(Keys, Keys1), list_equisized(Keys, Keys1) -> true
    ;   domain_error(gcc_unique_key_pairs, Pairs)
    ),
    list_length(Xs, L),
    Nums ins 0..L,
    drep_from_numbers(Keys, Drep),
    Xs ins Drep,
    gcc_pairs(Pairs, Xs, Pairs1),
    % pgcc_check must be installed before triggering other
    % propagators
    % constraint_trigger(Xs, pgcc_check(Pairs1)),
    propagator_from_constraint(pgcc_check(Pairs1), P0),
    propagator_trigger(P0, Xs),
    % constraint_trigger(Nums, pgcc_check_single(Pairs1)),
    propagator_from_constraint(pgcc_check_single(Pairs1), P1),
    propagator_trigger(P1, Nums),
    (   member(OD, Options), OD == consistency(value) -> true
    ;   % constraint_trigger(Nums, pgcc_single(Xs, Pairs1)),
        propagator_from_constraint(pgcc_single(Xs,Pairs1), P2),
        propagator_trigger(P2, Nums),
        % constraint_trigger(Xs, pgcc(Xs, Pairs, Pairs1))
        propagator_from_constraint(pgcc(Xs,Pairs,Pairs1), P3),
        propagator_trigger(P3, Xs)
    ),
    (   member(OC, Options), functor(OC, cost, 2) ->
        OC = cost(Cost, Matrix),
        must_be(list(list(integer)), Matrix),
        list_map(keys_costs(Keys), Xs, Matrix, Costs),
        sum(Costs, #=, Cost)
    ;   true
    ).

keys_costs(Keys, X, Row, C) :-
        element(N, Keys, X),
        element(N, Row, C).

gcc_pair(Pair) :-
        (   Pair = Key-Val ->
            must_be(integer, Key),
            fd_variable(Val)
        ;   domain_error(gcc_pair, Pair)
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   For each Key-Num0 pair, we introduce an auxiliary variable Num and
   attach the following attributes to it:

   clpz_gcc_num: equal Num0, the user-visible counter variable
   clpz_gcc_vs: the remaining variables in the constraint that can be
   equal Key.
   clpz_gcc_occurred: stores how often Key already occurred in vs.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

gcc_pairs([], _, []).
gcc_pairs([Key-Num0|KNs], Vs, [Key-Num|Rest]) :-
        put_attr(Num, clpz_gcc_num, Num0),
        put_attr(Num, clpz_gcc_vs, Vs),
        put_attr(Num, clpz_gcc_occurred, 0),
        gcc_pairs(KNs, Vs, Rest).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    J.-C. Régin: "Generalized Arc Consistency for Global Cardinality
    Constraint", AAAI-96 Portland, OR, USA, pp 209--215, 1996
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

gcc_global(Vs, KNs) -->
        % at this point, all elements of clpz_gcc_vs must be
        % variables, which a previously scheduled and called
        % gcc_check//1 ensures. Note that gcc_check//1 disables the
        % queue and accumulates constraints in the queue. Do we need
        % to insert a call of propagator_catalyze//0 here to reach a fixpoint?  I
        % think not, because verify_attributes/3 gives each variable
        % that is involved in a unification an opportunity to schedule
        % its propagators, even if the unifications happen
        % simultaneously (such as [A,B] = [0,1], which can happen in
        % the propagator of tuples_in/2). Hence: We need this only if
        % an example shows it, ideally found by a systematic search
        % that can be used to test the implementation.
        { with_local_attributes(Vs,
              (gcc_arcs(KNs, S, Vals),
               variables_with_num_occurrences(Vs, VNs),
               list_map(target_to_v(T), VNs),
               (   get_attr(S, edges, Es) ->
                   put_attr(S, parent, none), % Mark S as seen to avoid going back to S.
                   feasible_flow(Es, S, T), % First construct a feasible flow (if any)
                   maximum_flow(S, T),      % only then, maximize it.
                   gcc_consistent(T),
                   scc(Vals, gcc_successors),
                   phrase(gcc_goals(Vals), Gs)
               ;   Gs = [] )), Gs) },
        queue_disable,
        neq_nums(Gs),
        queue_enable.

gcc_consistent(T) :-
        get_attr(T, edges, Es),
        list_map(saturated_arc, Es).

saturated_arc(arc_from(_,U,_,Flow)) :- get_attr(Flow, flow, U).

gcc_goals([]) --> [].
gcc_goals([Val|Vals]) -->
        { get_attr(Val, edges, Es) },
        gcc_edges_goals(Es, Val),
        gcc_goals(Vals).

gcc_edges_goals([], _) --> [].
gcc_edges_goals([E|Es], Val) -->
        gcc_edge_goal(E, Val),
        gcc_edges_goals(Es, Val).

gcc_edge_goal(arc_from(_,_,_,_), _) --> [].
gcc_edge_goal(arc_to(_,_,V,F), Val) -->
        (   { get_attr(F, flow, 0),
              get_attr(V, lowlink, L1),
              get_attr(Val, lowlink, L2),
              L1 =\= L2,
              get_attr(Val, value, Value) } ->
            [neq_num(V, Value)]
        ;   []
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Like in all_distinct/1, first use breadth-first search, then
   construct an augmenting path in reverse.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

maximum_flow(S, T) :-
        (   gcc_augmenting_path([[S]], Levels, T) ->
            phrase(augmenting_path(S, T), Path),
            Path = [augment(_,First,_)|Rest],
            path_minimum(Rest, First, Min),
            list_map(gcc_augment(Min), Path),
            list_map(list_map(clear_parent), Levels),
            maximum_flow(S, T)
        ;   true
        ).

feasible_flow([], _, _).
feasible_flow([A|As], S, T) :-
        make_arc_feasible(A, S, T),
        feasible_flow(As, S, T).

make_arc_feasible(A, S, T) :-
        A = arc_to(L,_,V,F),
        get_attr(F, flow, Flow),
        (   Flow >= L -> true
        ;   integer_add(Diff, Flow, L), % Diff #= L-Flow
            put_attr(V, parent, S-augment(F,Diff,+)),
            gcc_augmenting_path([[V]], Levels, T),
            phrase(augmenting_path(S, T), Path),
            path_minimum(Path, Diff, Min),
            list_map(gcc_augment(Min), Path),
            list_map(list_map(clear_parent), Levels),
            make_arc_feasible(A, S, T)
        ).

gcc_augmenting_path(Levels0, Levels, T) :-
        Levels0 = [Vs|_],
        Levels1 = [Tos|Levels0],
        phrase(gcc_reachables(Vs), Tos),
        Tos = [_|_],
        (   member(To, Tos), To == T -> Levels = Levels1
        ;   gcc_augmenting_path(Levels1, Levels, T)
        ).

gcc_reachables([])     --> [].
gcc_reachables([V|Vs]) -->
        { get_attr(V, edges, Es) },
        gcc_reachables_(Es, V),
        gcc_reachables(Vs).

gcc_reachables_([], _)     --> [].
gcc_reachables_([E|Es], V) -->
        gcc_reachable(E, V),
        gcc_reachables_(Es, V).

gcc_reachable(arc_from(_,_,V,F), P) -->
        (   { \+ get_attr(V, parent, _),
              get_attr(F, flow, Flow),
              Flow > 0 } ->
            { put_attr(V, parent, P-augment(F,Flow,-)) },
            [V]
        ;   []
        ).
gcc_reachable(arc_to(_L,U,V,F), P) -->
        (   { \+ get_attr(V, parent, _),
              get_attr(F, flow, Flow),
              Flow < U } ->
            { integer_add(Diff, Flow, U), % Diff #= U-Flow
              put_attr(V, parent, P-augment(F,Diff,+)) },
            [V]
        ;   []
        ).


path_minimum([], Min, Min).
path_minimum([augment(_,A,_)|As], Min0, Min) :-
        integer_min(A, Min0, Min1),
        path_minimum(As, Min1, Min).

gcc_augment(Min, augment(F,_,Sign)) :-
        get_attr(F, flow, Flow0),
        gcc_flow_(Sign, Flow0, Min, Flow),
        put_attr(F, flow, Flow).

gcc_flow_(+, F0, A, F) :- integer_add(A, F0, F). % F #= F0+A
gcc_flow_(-, F0, A, F) :- integer_add(F, A, F0). % F #= F0-A.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Build value network for global cardinality constraint.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

gcc_arcs([], _, []).
gcc_arcs([Key-Num0|KNs], S, Vals) :-
        (   get_attr(Num0, clpz_gcc_vs, Vs) ->
            get_attr(Num0, clpz_gcc_num, Num),
            get_attr(Num0, clpz_gcc_occurred, Occ),
            (   nonvar(Num)
            ->  integer_add(U, Occ, Num), % U #= Num-Occ
                U = L
            ;   fd_get(Num, _, n(L0), n(U0), _),
                integer_add(L, Occ, L0), % L #= L0-Occ
                integer_add(U, Occ, U0) % U #= U0-Occ
            ),
            put_attr(Val, value, Key),
            Vals = [Val|Rest],
            put_attr(F, flow, 0),
            append_edge(S, edges, arc_to(L, U, Val, F)),
            put_attr(Val, edges, [arc_from(L, U, S, F)]),
            variables_with_num_occurrences(Vs, VNs),
            list_map(val_to_v(Val), VNs)
        ;   Vals = Rest
        ),
        gcc_arcs(KNs, S, Rest).

variables_with_num_occurrences(Vs0, VNs) :-
        include(var, Vs0, Vs1),
        samsort(Vs1, Vs),
        (   Vs == []
        ->  VNs = []
        ;   Vs = [V|Rest],
            variables_with_num_occurrences(Rest, V, 1, VNs)
        ).

variables_with_num_occurrences([], Prev, Count, [Prev-Count]).
variables_with_num_occurrences([V|Vs], Prev, Count0, VNs) :-
        (   V == Prev ->
            integer_add(1, Count0, Count1), % Count1 #= Count0+1,
            variables_with_num_occurrences(Vs, Prev, Count1, VNs)
        ;   VNs = [Prev-Count0|Rest],
            variables_with_num_occurrences(Vs, V, 1, Rest)
        ).


target_to_v(T, V-Count) :-
        put_attr(F, flow, 0),
        append_edge(V, edges, arc_to(0, Count, T, F)),
        append_edge(T, edges, arc_from(0, Count, V, F)).

val_to_v(Val, V-Count) :-
        put_attr(F, flow, 0),
        append_edge(V, edges, arc_from(0, Count, Val, F)),
        append_edge(Val, edges, arc_to(0, Count, V, F)).


gcc_successors(V, Tos) :-
        get_attr(V, edges, Tos0),
        phrase(gcc_successors_(Tos0), Tos).

gcc_successors_([])     --> [].
gcc_successors_([E|Es]) --> gcc_succ_edge(E), gcc_successors_(Es).

gcc_succ_edge(arc_to(_,U,V,F)) -->
        (   { get_attr(F, flow, Flow),
              Flow < U } -> [V]
        ;   []
        ).
gcc_succ_edge(arc_from(_,_,V,F)) -->
        (   { get_attr(F, flow, Flow),
              Flow > 0 } -> [V]
        ;   []
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Simple consistency check, run before global propagation.
   Importantly, it removes all ground values from clpz_gcc_vs.

   The pgcc_check/1 propagator in itself suffices to ensure
   consistency.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

gcc_check(Pairs) -->
        queue_disable,
        gcc_check_(Pairs),
        queue_enable.

gcc_done(Num) :-
        del_attr(Num, clpz_gcc_vs),
        del_attr(Num, clpz_gcc_num),
        del_attr(Num, clpz_gcc_occurred).

gcc_check_([]) --> [].
gcc_check_([Key-Num0|KNs]) -->
        (   { get_attr(Num0, clpz_gcc_vs, Vs) } ->
            { get_attr(Num0, clpz_gcc_num, Num),
              get_attr(Num0, clpz_gcc_occurred, Occ0),
              vs_key_min_others(Vs, Key, 0, Min, Os),
              put_attr(Num0, clpz_gcc_vs, Os),
              put_attr(Num0, clpz_gcc_occurred, Occ1),
              integer_add(Min, Occ0, Occ1) /* Occ1 #= Occ0+Min */ },
            { #Occ1 #=< #Num }, % leq(Occ1, Num), % geq(Num, Occ1),
            % The queue is disabled for efficiency here in any case.
            % If it were enabled, make sure to retain the invariant
            % that gcc_global is never triggered during an
            % inconsistent state (after gcc_done/1 but before all
            % relevant constraints are posted).
            (   Occ1 == Num -> all_neq(Os, Key), { gcc_done(Num0) }
            ;   Os == [] -> { gcc_done(Num0) }, Num = Occ1
            ;   { list_length(Os, L),
                  integer_add(Occ1, L, Max) /* Max #= Occ1+L */ },
                { #Num #=< #Max }, % leq(Num, Max), % geq(Max, Num),
                (   { nonvar(Num) }
                ->  { integer_add(Diff, Occ1, Num) } % Diff #= Num-Occ1
                ;   { fd_get(Num, ND, _),
                      domain_infimum(ND, n(NInf)) },
                    { integer_add(Diff, Occ1, NInf) } % Diff #= NInf-Occ1
                ),
                L >= Diff,
                (   L =:= Diff ->
                    { integer_add(Occ1, Diff, Num) }, % Num #= Occ1+Diff
                    { list_map(=(Key), Os),
                      gcc_done(Num0) }
                ;   true
                )
            )
        ;   true
        ),
        gcc_check_(KNs).

vs_key_min_others([], _, Min, Min, []).
vs_key_min_others([V|Vs], Key, Min0, Min, Others) :-
        (   fd_get(V, VD, _) ->
            (   domain_contains(VD, Key) ->
                Others = [V|Rest],
                vs_key_min_others(Vs, Key, Min0, Min, Rest)
            ;   vs_key_min_others(Vs, Key, Min0, Min, Others)
            )
        ;   (   V =:= Key
            ->  integer_add(1, Min0, Min1), % Min1 #= Min0+1
                vs_key_min_others(Vs, Key, Min1, Min, Others)
            ;   vs_key_min_others(Vs, Key, Min0, Min, Others)
            )
        ).

all_neq([], _) --> [].
all_neq([X|Xs], C) -->
        neq_num(X, C),
        all_neq(Xs, C).

all_neq([], _).
all_neq([X|Xs], C) :-
        neq_num(X, C),
        all_neq(Xs, C).
