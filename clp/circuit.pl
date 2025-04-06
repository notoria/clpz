%% circuit(+Vs)
%
% True iff the list Vs of finite domain variables induces a
% Hamiltonian circuit. The k-th element of Vs denotes the
% successor of node k. Node indexing starts with 1. Examples:
%
% ```
% ?- length(Vs, _), circuit(Vs), label(Vs).
%    Vs = []
% ;  Vs = [1]
% ;  Vs = [2,1]
% ;  Vs = [2,3,1]
% ;  Vs = [3,1,2]
% ;  Vs = [2,3,4,1]
% ;  ... .
% ```

circuit(Vs) :-
        must_be(list, Vs),
        maplist(fd_variable, Vs),
        length(Vs, L),
        Vs ins 1..L,
        (   L =:= 1 -> true
        ;   neq_index(Vs, 1),
            make_propagator(pcircuit(Vs), Prop),
            new_queue(Q0),
            phrase((distinct_attach(Vs, Prop, []),trigger_prop(Prop),do_queue), [Q0], _)
        ).

neq_index([], _).
neq_index([X|Xs], N) :-
        neq_num(X, N),
        N1 is N + 1,
        neq_index(Xs, N1).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Necessary condition for existence of a Hamiltonian circuit: The
   graph has a single strongly connected component. If the list is
   ground, the condition is also sufficient.

   Ts are used as temporary variables to attach attributes:

   lowlink, index: used for SCC
   [arc_to(V)]: possible successors
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

propagate_circuit(Vs) :-
        with_local_attributes([],
            (same_length(Vs, Ts),
             circuit_graph(Vs, Ts, Ts),
             scc(Ts, circuit_successors),
             maplist(single_component, Ts)), _).

single_component(V) :- get_attr(V, lowlink, 0).

circuit_graph([], _, _).
circuit_graph([V|Vs], Ts0, [T|Ts]) :-
        (   nonvar(V) -> Ns = [V]
        ;   fd_get(V, Dom, _),
            domain_to_list(Dom, Ns)
        ),
        phrase(circuit_edges(Ns, Ts0), Es),
        put_attr(T, edges, Es),
        circuit_graph(Vs, Ts0, Ts).

circuit_edges([], _) --> [].
circuit_edges([N|Ns], Ts) -->
        { nth1(N, Ts, T) },
        [arc_to(T)],
        circuit_edges(Ns, Ts).

circuit_successors(V, Tos) :-
        get_attr(V, edges, Tos0),
        maplist(arg(1), Tos0, Tos).
