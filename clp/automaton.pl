%% automaton(+Vs, +Nodes, +Arcs)
%
%  Describes a list of finite domain variables with a finite
%  automaton. Equivalent to automaton(Vs, _, Vs, Nodes, Arcs,
%  [], [], _), a common use case of automaton/8. In the following
%  example, a list of binary finite domain variables is constrained to
%  contain at least two consecutive ones:
%
% ```
% two_consecutive_ones(Vs) :-
%         automaton(Vs, [source(a),sink(c)],
%                       [arc(a,0,a), arc(a,1,b),
%                        arc(b,0,a), arc(b,1,c),
%                        arc(c,0,c), arc(c,1,c)]).
% ```
%
%  Example query:
%
% ```
% ?- list_length(Vs, 3), two_consecutive_ones(Vs), label(Vs).
%    Vs = [0,1,1]
% ;  Vs = [1,1,0]
% ;  Vs = [1,1,1]
% ;  false.
% ```

automaton(Sigs, Ns, As) :- automaton(Sigs, _, Sigs, Ns, As, [], [], _).


%% automaton(+Sequence, ?Template, +Signature, +Nodes, +Arcs, +Counters, +Initials, ?Finals)
%
%  Describes a list of finite domain variables with a finite
%  automaton. True iff the finite automaton induced by Nodes and Arcs
%  (extended with Counters) accepts Signature. Sequence is a list of
%  terms, all of the same shape. Additional constraints must link
%  Sequence to Signature, if necessary. Nodes is a list of
%  source(Node) and sink(Node) terms. Arcs is a list of
%  arc(Node,Integer,Node) and arc(Node,Integer,Node,Exprs) terms that
%  denote the automaton's transitions. Each node is represented by an
%  arbitrary term. Transitions that are not mentioned go to an
%  implicit failure node. `Exprs` is a list of arithmetic expressions,
%  of the same length as Counters. In each expression, variables
%  occurring in Counters symbolically refer to previous counter
%  values, and variables occurring in Template refer to the current
%  element of Sequence. When a transition containing arithmetic
%  expressions is taken, each counter is updated according to the
%  result of the corresponding expression. When a transition without
%  arithmetic expressions is taken, all counters remain unchanged.
%  Counters is a list of variables. Initials is a list of finite
%  domain variables or integers denoting, in the same order, the
%  initial value of each counter. These values are related to Finals
%  according to the arithmetic expressions of the taken transitions.
%
%  The following example is taken from Beldiceanu, Carlsson, Debruyne
%  and Petit: "Reformulation of Global Constraints Based on
%  Constraints Checkers", Constraints 10(4), pp 339-362 (2005). It
%  relates a sequence of integers and finite domain variables to its
%  number of inflexions, which are switches between strictly ascending
%  and strictly descending subsequences:
%
% ```
%  sequence_inflexions(Vs, N) :-
%          variables_signature(Vs, Sigs),
%          automaton(Sigs, _, Sigs,
%                    [source(s),sink(i),sink(j),sink(s)],
%                    [arc(s,0,s), arc(s,1,j), arc(s,2,i),
%                     arc(i,0,i), arc(i,1,j,[C+1]), arc(i,2,i),
%                     arc(j,0,j), arc(j,1,j),
%                     arc(j,2,i,[C+1])],
%                    [C], [0], [N]).
%
%  variables_signature([], []).
%  variables_signature([V|Vs], Sigs) :-
%          variables_signature_(Vs, V, Sigs).
%
%  variables_signature_([], _, []).
%  variables_signature_([V|Vs], Prev, [S|Sigs]) :-
%          V #= Prev #<==> S #= 0,
%          Prev #< V #<==> S #= 1,
%          Prev #> V #<==> S #= 2,
%          variables_signature_(Vs, V, Sigs).
% ```
%
%  Example queries:
%
% ```
%  ?- sequence_inflexions([1,2,3,3,2,1,3,0], N).
%  N = 3.
%
%  ?- list_length(Ls, 5), Ls ins 0..1,
%     sequence_inflexions(Ls, 3), label(Ls).
%  Ls = [0, 1, 0, 1, 0] ;
%  Ls = [1, 0, 1, 0, 1].
% ```

template_var_path(T, Var, Ns0) :-
    (   Ns0 = [], var(T)
    ->  T == Var
    ;   Ns0 = [N|Ns],
        arg(N, T, Arg),
        template_var_path(Arg, Var, Ns)
    ).

path_term_variable([], V, V).
path_term_variable([P|Ps], T, V) :-
        arg(P, T, Arg),
        path_term_variable(Ps, Arg, V).

initial_expr(_, []-1).

automaton(Seqs, Template, Sigs, Ns, As0, Cs, Is, Fs) :-
        must_be(list(list), [Sigs,Ns,As0,Cs,Is]),
        (   var(Seqs)
        ->  (   monotonic
            ->  instantiation_error(Seqs)
            ;   Seqs = Sigs
            )
        ;   must_be(list, Seqs)
        ),
        list_map(monotonic, Cs, CsM),
        list_map(arc_normalized(CsM), As0, As),
        include_args1(sink, Ns, Sinks),
        include_args1(source, Ns, Sources),
        list_map(initial_expr, Cs, Exprs0),
        phrase(
            (   arcs_relation(As, Relation),
                nodes_nums(Sinks, SinkNums0),
                nodes_nums(Sources, SourceNums0)
            ),
            [s([]-0, Exprs0)],
            [s(_,Exprs1)]
        ),
        list_map(expr0_expr, Exprs1, Exprs),
        phrase(
            transitions(Seqs, Template, Sigs, Start, End, Exprs, Cs, Is, Fs),
            Tuples
        ),
        drep_from_numbers(SourceNums0, SourceDrep),
        Start in SourceDrep,
        drep_from_numbers(SinkNums0, SinkDrep),
        End in SinkDrep,
        tuples_in(Tuples, Relation).

expr0_expr(Es0-_, Es) :-
        pairs_keys(Es0, Es1),
        list_reversed(Es1, Es).

transitions([], _, [], S, S, _, _, Cs, Cs) --> [].
transitions([Seq|Seqs], Template, [Sig|Sigs], S0, S, Exprs, Counters, Cs0, Cs) -->
        [[S0,Sig,S1|Is]],
        { phrase(exprs_next(Exprs, Is, Cs1), [s(Seq,Template,Counters,Cs0)], _) },
        transitions(Seqs, Template, Sigs, S1, S, Exprs, Counters, Cs1, Cs).

exprs_next([], [], []) --> [].
exprs_next([Es|Ess], [I|Is], [C|Cs]) -->
        exprs_values(Es, Vs),
        { element(I, Vs, C) },
        exprs_next(Ess, Is, Cs).

exprs_values([], []) --> [].
exprs_values([E0|Es], [V|Vs]) -->
        { term_variables(E0, EVs0),
          copy_term(E0, E),
          term_variables(E, EVs),
          #V #= E },
        match_variables(EVs0, EVs),
        exprs_values(Es, Vs).

match_variables([], _) --> [].
match_variables([V0|Vs0], [V|Vs]) -->
        state(s(Seq,Template,Counters,Cs0)),
        { (   template_var_path(Template, V0, Ps) ->
              path_term_variable(Ps, Seq, V)
          ;   template_var_path(Counters, V0, Ps) ->
              path_term_variable(Ps, Cs0, V)
          ;   domain_error(variable_from_template_or_counters, V0)
          ) },
        match_variables(Vs0, Vs).

nodes_nums([], []) --> [].
nodes_nums([Node|Nodes], [Num|Nums]) -->
        node_num(Node, Num),
        nodes_nums(Nodes, Nums).

arcs_relation([], []) --> [].
arcs_relation([arc(S0,L,S1,Es)|As], [[From,L,To|Ns]|Rs]) -->
        node_num(S0, From),
        node_num(S1, To),
        state(s(Nodes, Exprs0), s(Nodes, Exprs)),
        { exprs_nums(Es, Ns, Exprs0, Exprs) },
        arcs_relation(As, Rs).

exprs_nums([], [], [], []).
exprs_nums([E|Es], [N|Ns], [Ex0-C0|Exs0], [Ex-C|Exs]) :-
        (   member(Exp-N, Ex0), Exp == E -> C = C0, Ex = Ex0
        ;   N = C0, integer_add(1, C0, C), Ex = [E-C0|Ex0]
        ),
        exprs_nums(Es, Ns, Exs0, Exs).

node_num(Node, Num) -->
        state(s(Nodes0-C0, Exprs), s(Nodes-C, Exprs)),
        { (   member(N-Num, Nodes0), N == Node -> C = C0, Nodes = Nodes0
          ;   Num = C0, integer_add(1, C0, C), Nodes = [Node-C0|Nodes0]
          )
        }.

include_args1(Goal, Ls0, As) :-
        include(Goal, Ls0, Ls),
        list_map(arg(1), Ls, As).

source(source(_)).

sink(sink(_)).

monotonic(Var, #Var).

arc_normalized(Cs, Arc0, Arc) :- arc_normalized_(Arc0, Cs, Arc).

arc_normalized_(arc(S0,L,S,Cs), _, arc(S0,L,S,Cs)).
arc_normalized_(arc(S0,L,S), Cs, arc(S0,L,S,Cs)).
