/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   J-C. Régin: "A filtering algorithm for constraints of difference in
   CSPs", AAAI-94, Seattle, WA, USA, pp 362--367, 1994
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

distinct_attach([], _, _) --> [].
distinct_attach([X|Xs], Prop, Right) -->
        (   var(X) ->
            init_propagator_([X], Prop),
            { make_propagator(pexclude(Xs,Right,X), P1) },
            init_propagator_([X], P1),
            trigger_prop(P1)
        ;   exclude_fire(Xs, Right, X)
        ),
        distinct_attach(Xs, Prop, [X|Right]).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   For each integer of the union of domains, an attributed variable is
   introduced, to benefit from constant-time access. Attributes are:

   value ... integer corresponding to the node
   free  ... whether this (right) node is still free
   edges ... [flow_from(F,From)] and [flow_to(F,To)] where F has an
             attribute "flow" that is either 0 or 1 and an attribute "used"
             if it is part of a maximum matching
   parent ... used in breadth-first search
   g0_edges ... [flow_to(F,To)] as above
   visited ... true if node was visited in DFS
   index, in_stack, lowlink ... used in Tarjan's SCC algorithm
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

difference_arcs(Vars, FreeLeft, FreeRight) :-
        empty_assoc(E),
        phrase(difference_arcs(Vars, FreeLeft), [E], [NumVar]),
        assoc_to_list(NumVar, LsNumVar),
        pairs_values(LsNumVar, FreeRight).

domain_to_list(Domain, List) :- phrase(domain_to_list(Domain), List).

domain_to_list(split(_, Left, Right)) -->
        domain_to_list(Left), domain_to_list(Right).
domain_to_list(empty)                 --> [].
domain_to_list(from_to(n(F),n(T)))    --> { N is T-F+1, length(Ns, N), [F|_] = Ns, chain_(succ, Ns) }, seq(Ns).

difference_arcs([], []) --> [].
difference_arcs([V|Vs], FL0) -->
        (   { fd_get(V, Dom, _), domain_to_list(Dom, Ns) } ->
            { FL0 = [V|FL] },
            enumerate(Ns, V),
            difference_arcs(Vs, FL)
        ;   difference_arcs(Vs, FL0)
        ).

writeln(T) :- write(T), nl.

:- meta_predicate must_succeed(0).

must_succeed(G) :-
        (   call(G) -> true
        ;   throw(failed-G)
        ).

enumerate([], _) --> [].
enumerate([N|Ns], V) -->
        state(NumVar0, NumVar),
        { (   get_assoc(N, NumVar0, Y) -> NumVar0 = NumVar
          ;   put_assoc(N, NumVar0, Y, NumVar),
              put_attr(Y, value, N)
          ),
          put_attr(F, flow, 0),
          must_succeed(append_edge(Y, edges, flow_from(F,V))),
          must_succeed(append_edge(V, edges, flow_to(F,Y))) },
        enumerate(Ns, V).

append_edge(V, Attr, E) :-
        (   get_attr_(Attr, V, Es) ->
            put_attr_(Attr, V, [E|Es])
        ;   put_attr_(Attr, V, [E])
        ).

get_attr_(edges, V, Es) :- get_attr(V, edges, Es).
get_attr_(g0_edges, V, Es) :- get_attr(V, g0_edges, Es).

put_attr_(edges, V, E) :- put_attr(V, edges, E).
put_attr_(g0_edges, V, E) :- put_attr(V, g0_edges, E).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Strategy: Breadth-first search until we find a free right vertex in
   the value graph, then find an augmenting path in reverse.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

clear_parent(V) :- del_attr(V, parent).

maximum_matching([]).
maximum_matching([FL|FLs]) :-
        augmenting_path_to([[FL]], Levels, To),
        phrase(augmenting_path(FL, To), Path),
        maplist(maplist(clear_parent), Levels),
        del_attr(To, free),
        adjust_alternate_1(Path),
        maximum_matching(FLs).

reachables([]) --> [].
reachables([V|Vs]) -->
        { get_attr(V, edges, Es) },
        reachables_(Es, V),
        reachables(Vs).

reachables_([], _) --> [].
reachables_([E|Es], V) -->
        edge_reachable(E, V),
        reachables_(Es, V).

edge_reachable(flow_to(F,To), V) -->
        (   { get_attr(F, flow, 0),
              \+ get_attr(To, parent, _) } ->
            { put_attr(To, parent, V-F) },
            [To]
        ;   []
        ).
edge_reachable(flow_from(F,From), V) -->
        (   { get_attr(F, flow, 1),
              \+ get_attr(From, parent, _) } ->
            { put_attr(From, parent, V-F) },
            [From]
        ;   []
        ).

augmenting_path_to(Levels0, Levels, Right) :-
        Levels0 = [Vs|_],
        Levels1 = [Tos|Levels0],
        phrase(reachables(Vs), Tos),
        Tos = [_|_],
        (   member(Right, Tos), get_attr(Right, free, true) ->
            Levels = Levels1
        ;   augmenting_path_to(Levels1, Levels, Right)
        ).

augmenting_path(S, V) -->
        (   { V == S } -> []
        ;   { get_attr(V, parent, V1-Augment) },
            [Augment],
            augmenting_path(S, V1)
        ).

adjust_alternate_1([A|Arcs]) :-
        put_attr(A, flow, 1),
        adjust_alternate_0(Arcs).

adjust_alternate_0([]).
adjust_alternate_0([A|Arcs]) :-
        put_attr(A, flow, 0),
        adjust_alternate_1(Arcs).

% Instead of applying Berge's property directly, we can translate the
% problem in such a way, that we have to search for the so-called
% strongly connected components of the graph.

g_g0(V) :-
        get_attr(V, edges, Es),
        maplist(g_g0_(V), Es).

g_g0_(V, flow_to(F,To)) :-
        (   get_attr(F, flow, 1) ->
            append_edge(V, g0_edges, flow_to(F,To))
        ;   append_edge(To, g0_edges, flow_to(F,V))
        ).


g0_successors(V, Tos) :-
        (   get_attr(V, g0_edges, Tos0) ->
            maplist(arg(2), Tos0, Tos)
        ;   Tos = []
        ).

put_free(F) :- put_attr(F, free, true).

free_node(F) :- get_attr(F, free, true).

:- meta_predicate with_local_attributes(?, 0, ?).

:- dynamic(nat_copy/1).

with_local_attributes(Vars, Goal, Result) :-
        catch((Goal,
               % Create a copy where all attributes are removed. Only
               % the result and its relation to Vars matters. We throw
               % an exception to undo all modifications to attributes
               % we made during propagation, and unify the variables
               % in the thrown copy with Vars in order to get the
               % intended variables in Result.
               copy_term_nat(Vars-Result, Copy),
               throw(local_attributes(Copy))),
              local_attributes(Vars-Result),
              true).

distinct(Vars) -->
        { with_local_attributes(Vars,
           (   difference_arcs(Vars, FreeLeft, FreeRight0),
               length(FreeLeft, LFL),
               length(FreeRight0, LFR),
               LFL =< LFR,
               maplist(put_free, FreeRight0),
               maximum_matching(FreeLeft),
               include(free_node, FreeRight0, FreeRight),
               maplist(g_g0, FreeLeft),
               scc(FreeLeft, g0_successors),
               maplist(dfs_used, FreeRight),
               phrase(distinct_goals(FreeLeft), Gs)), Gs) },
        disable_queue,
        neq_nums(Gs),
        enable_queue.

neq_nums([]) --> [].
neq_nums([neq_num(V,N)|VNs]) -->
        % { portray_clause(neq_num(V, N)) },
        neq_num(V, N), neq_nums(VNs).

distinct_goals([]) --> [].
distinct_goals([V|Vs]) -->
        { get_attr(V, edges, Es) },
        distinct_goals_(Es, V),
        distinct_goals(Vs).

distinct_goals_([], _) --> [].
distinct_goals_([flow_to(F,To)|Es], V) -->
        (   { get_attr(F, flow, 0),
              \+ get_attr(F, used, true),
              get_attr(V, lowlink, L1),
              get_attr(To, lowlink, L2),
              L1 =\= L2 } ->
            { get_attr(To, value, N) },
            [neq_num(V, N)]
        ;   []
        ),
        distinct_goals_(Es, V).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Mark used edges.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

dfs_used(V) :-
        (   get_attr(V, visited, true) -> true
        ;   put_attr(V, visited, true),
            (   get_attr(V, g0_edges, Es) ->
                dfs_used_edges(Es)
            ;   true
            )
        ).

dfs_used_edges([]).
dfs_used_edges([flow_to(F,To)|Es]) :-
        put_attr(F, used, true),
        dfs_used(To),
        dfs_used_edges(Es).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Tarjan's strongly connected components algorithm.

   DCGs are used to implicitly pass around the global index, stack
   and the predicate relating a vertex to its successors.

   For more information about this technique, see:

                 https://www.metalevel.at/prolog/dcg
                 ===================================

   A Prolog implementation of this algorithm is also available as a
   standalone library from:

                   https://www.metalevel.at/scc.pl
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- meta_predicate(scc(?,2)).

scc(Vs, Succ) :- phrase(scc(Vs), [s(0,[],Succ)], _).

scc([])     --> [].
scc([V|Vs]) -->
        (   vindex_defined(V) -> scc(Vs)
        ;   scc_(V), scc(Vs)
        ).

vindex_defined(V) --> { get_attr(V, index, _) }.

vindex_is_index(V) -->
        state(s(Index,_,_)),
        { put_attr(V, index, Index) }.

vlowlink_is_index(V) -->
        state(s(Index,_,_)),
        { put_attr(V, lowlink, Index) }.

index_plus_one -->
        state(s(I,Stack,Succ), s(I1,Stack,Succ)),
        { I1 is I+1 }.

s_push(V)  -->
        state(s(I,Stack,Succ), s(I,[V|Stack],Succ)),
        { put_attr(V, in_stack, true) }.

vlowlink_min_lowlink(V, VP) -->
        { get_attr(V, lowlink, VL),
          get_attr(VP, lowlink, VPL),
          VL1 is min(VL, VPL),
          put_attr(V, lowlink, VL1) }.

successors(V, Tos) --> state(s(_,_,Succ)), { call(Succ, V, Tos) }.

scc_(V) -->
        vindex_is_index(V),
        vlowlink_is_index(V),
        index_plus_one,
        s_push(V),
        successors(V, Tos),
        each_edge(Tos, V),
        (   { get_attr(V, index, VI),
              get_attr(V, lowlink, VI) } -> pop_stack_to(V, VI)
        ;   []
        ).

pop_stack_to(V, N) -->
        state(s(I,[First|Stack],Succ), s(I,Stack,Succ)),
        { del_attr(First, in_stack) },
        (   { First == V } -> []
        ;   { put_attr(First, lowlink, N) },
            pop_stack_to(V, N)
        ).

each_edge([], _) --> [].
each_edge([VP|VPs], V) -->
        (   vindex_defined(VP) ->
            (   v_in_stack(VP) ->
                vlowlink_min_lowlink(V, VP)
            ;   []
            )
        ;   scc_(VP),
            vlowlink_min_lowlink(V, VP)
        ),
        each_edge(VPs, V).

state(S), [S] --> [S].

state(S0, S), [S] --> [S0].

v_in_stack(V) --> { get_attr(V, in_stack, true) }.

node_lowlink(V, L) :- get_attr(V, lowlink, L).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   nvalue/2: A relaxed version of all_distinct/1.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


maximal_matching([]) --> [].
maximal_matching([FL|FLs]) -->
        (   { augmenting_path_to([[FL]], Levels, To) } ->
            { phrase(augmenting_path(FL, To), Path),
              maplist(maplist(clear_parent), Levels),
              del_attr(To, free),
              adjust_alternate_1(Path) },
            [FL]
        ;   []
        ),
        maximal_matching(FLs).

propagate_nvalue(N, Vars0) :-
        sort(Vars0, Vars),
        include(integer, Vars, Ints),
        length(Ints, Distinct),
        vars_num_infinite(Vars, NumInfinite),
        N #>= Distinct,
        with_local_attributes(Vars,
           (   difference_arcs(Vars, FreeLeft, FreeRight0),
               maplist(put_free, FreeRight0),
               phrase(maximal_matching(FreeLeft), MatchedLeft),
               length(MatchedLeft, MaxFurther) ),
            MaxFurther),
        N #=< NumInfinite + Distinct + MaxFurther.

vars_num_infinite(Vars, Num) :-
        foldl(num_infinite, Vars, 0, Num).

num_infinite(Var, N0, N) :-
        (   integer(Var) -> N = N0
        ;   fd_get(Var, Dom, _),
            (   domain_infimum(Dom, n(_)),
                domain_supremum(Dom, n(_)) -> N = N0
            ;   #N #= N0 + 1
            )
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Weak arc consistent constraint of difference, currently only
   available internally. Candidate for all_different/2 option.

   See Neng-Fa Zhou: "Programming Finite-Domain Constraint Propagators
   in Action Rules", Theory and Practice of Logic Programming, Vol.6,
   No.5, pp 483-508, 2006
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

weak_arc_all_distinct(Ls) :-
        must_be(list, Ls),
        Orig = original_goal(_, weak_arc_all_distinct(Ls)),
        all_distinct(Ls, [], Orig).

all_distinct([], _, _).
all_distinct([X|Right], Left, Orig) :-
        %\+ list_contains(Right, X),
        (   var(X) ->
            make_propagator(weak_distinct(Left,Right,X,Orig), Prop),
            init_propagator(X, Prop),
            trigger_prop(Prop)
%             make_propagator(check_distinct(Left,Right,X), Prop2),
%             init_propagator(X, Prop2),
%             trigger_prop(Prop2)
        ;   exclude_fire(Left, Right, X)
        ),
        outof_reducer(Left, Right, X),
        all_distinct(Right, [X|Left], Orig).

exclude_fire(Left, Right, E) :-
        all_neq(Left, E),
        all_neq(Right, E).

exclude_fire(Left, Right, E) -->
        all_neq(Left, E),
        all_neq(Right, E).

list_contains([X|Xs], Y) :-
        (   X == Y -> true
        ;   list_contains(Xs, Y)
        ).

kill_if_isolated(Left, Right, X, MState) :-
        append(Left, Right, Others),
        fd_get(X, XDom, _),
        (   all_empty_intersection(Others, XDom) -> kill(MState)
        ;   true
        ).

all_empty_intersection([], _).
all_empty_intersection([V|Vs], XDom) :-
        (   fd_get(V, VDom, _) ->
            domains_intersection_(VDom, XDom, empty),
            all_empty_intersection(Vs, XDom)
        ;   all_empty_intersection(Vs, XDom)
        ).

outof_reducer(Left, Right, Var) :-
        (   fd_get(Var, Dom, _) ->
            append(Left, Right, Others),
            domain_num_elements(Dom, N),
            num_subsets(Others, Dom, 0, Num, NonSubs),
            (   n(Num) cis_geq N -> false
            ;   n(Num) cis N - n(1) ->
                reduce_from_others(NonSubs, Dom)
            ;   true
            )
        ;   %\+ list_contains(Right, Var),
            %\+ list_contains(Left, Var)
            true
        ).

reduce_from_others([], _).
reduce_from_others([X|Xs], Dom) :-
        (   fd_get(X, XDom, XPs) ->
            domain_subtract(XDom, Dom, NXDom),
            fd_put(X, NXDom, XPs)
        ;   true
        ),
        reduce_from_others(Xs, Dom).

num_subsets([], _Dom, Num, Num, []).
num_subsets([S|Ss], Dom, Num0, Num, NonSubs) :-
        (   fd_get(S, SDom, _) ->
            (   domain_subdomain(Dom, SDom) ->
                Num1 is Num0 + 1,
                num_subsets(Ss, Dom, Num1, Num, NonSubs)
            ;   NonSubs = [S|Rest],
                num_subsets(Ss, Dom, Num0, Num, Rest)
            )
        ;   num_subsets(Ss, Dom, Num0, Num, NonSubs)
        ).
