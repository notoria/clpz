reify(E, B) :- reify(E, B, _).

reify(Expr, B, Ps) :-
        (   acyclic_term(Expr), reifiable(Expr) -> phrase(reify(Expr, B), Ps)
        ;   domain_error(clpz_reifiable_expression, Expr)
        ).

reifiable(E) :-
    (   var(E)
    ->  non_monotonic(E)
    ;   reifiable_(E)
    ).

reifiable_(E)      :- integer(E), E in 0..1.
reifiable_(?(E))   :- must_be_fd_integer(E).
reifiable_(#E)     :- must_be_fd_integer(E).
reifiable_(V in _) :- fd_variable(V).
reifiable_(Expr)   :-
        Expr =.. [Op,Left,Right],
        (   once(member(Op, [#>=,#>,#=<,#<,#=,#\=]))
        ;   once(member(Op, [#==>,#<==,#<==>,#/\,#\/,#\])),
            reifiable(Left),
            reifiable(Right)
        ).
reifiable_(#\ E) :- reifiable(E).
reifiable_(tuples_in(Tuples, Relation)) :-
        must_be(list(list), Tuples),
        list_map(list_map(fd_variable), Tuples),
        must_be(list(list(integer)), Relation).
reifiable_(finite_domain(V)) :- fd_variable(V).

reify(E, B) --> { B in 0..1 }, '@reify'(E, B).

'@reify'(E, B) -->
    (   { var(E) }
    ->  { non_monotonic(E), E = B }
    ;   reify_(E, B)
    ).

reify_(E, B) --> { integer(E), E = B }.
reify_(?(B), B) --> [].
reify_(#B, B) --> [].
reify_(V in Drep, B) -->
    { drep_to_domain(Drep, Dom) },
    [p(P)],
    { propagator_from_constraint(reified_in(V,Dom,B), P),
      term_variables([V,B], Vs),
      propagator_trigger(P, Vs) },
    a(B).
reify_(tuples_in(Tuples, Relation), B) -->
    { list_map(relation_tuple_b_prop(Relation), Tuples, Bs, Ps),
      list_map(monotonic, Bs, Bs1),
      fold_statement(conjunction, Bs1, And),
      #B #<==> And },
    [p(P)],
    { propagator_from_constraint(tuples_not_in(Tuples,Relation,B), P),
      propagator_trigger(P, [B]) },
    kill_reified_tuples(Bs, Ps, Bs),
    map(identity, Ps),
    map(a, [B|Bs]).
reify_(finite_domain(V), B) -->
    [p(P)],
    { propagator_from_constraint(reified_fd(V,B), P),
      term_variables([V,B], Vs),
      propagator_trigger(P, Vs) },
    a(B).
reify_(L #>= R, B) --> arithmetic(L, R, B, reified_geq).
reify_(L #= R, B)  --> arithmetic(L, R, B, reified_eq).
reify_(L #\= R, B) --> arithmetic(L, R, B, reified_neq).
reify_(L #> R, B)  --> '@reify'(L #>= (R+1), B).
reify_(L #=< R, B) --> '@reify'(R #>= L, B).
reify_(L #< R, B)  --> '@reify'(R #>= (L+1), B).
reify_(L #==> R, B)  --> '@reify'((#\ L) #\/ R, B).
reify_(L #<== R, B)  --> '@reify'(R #==> L, B).
reify_(L #<==> R, B) --> '@reify'((L #==> R) #/\ (R #==> L), B).
reify_(L #\ R, B) --> '@reify'((L #\/ R) #/\ #\ (L #/\ R), B).
reify_(L #/\ R, B)   -->
        (   { conjunctive_neqs_var_drep(L #/\ R, V, D) } -> '@reify'(V in D, B)
        ;   boolean(L, R, B, reified_and)
        ).
reify_(L #\/ R, B) -->
        (   { disjunctive_eqs_var_drep(L #\/ R, V, D) } -> '@reify'(V in D, B)
        ;   boolean(L, R, B, reified_or)
        ).
reify_(#\ Q, B) -->
    reify(Q, QR),
    [p(P)],
    { propagator_from_constraint(reified_not(QR,B), P),
      term_variables([QR,B], Vs),
      propagator_trigger(P, Vs) },
    a(B).

arithmetic(L, R, B, Functor) -->
    { phrase((parse_reified_clpz(L, LR, LD),
              parse_reified_clpz(R, RR, RD)), Ps),
      C =.. [Functor,LD,LR,RD,RR,Ps,B] },
    map(identity, Ps),
    [p(P)],
    { propagator_from_constraint(C, P),
      propagator_trigger(P, [LD,LR,RD,RR,B]) },
    a(B).

boolean(L, R, B, Functor) -->
    { reify(L, LR, Ps1), reify(R, RR, Ps2),
      C =.. [Functor,LR,Ps1,RR,Ps2,B] },
    map(identity, Ps1), map(identity, Ps2),
    [p(P)],
    { propagator_from_constraint(C, P),
      propagator_trigger(P, [LR,RR,B]) },
    a(LR, RR, B).

a(X,Y,B) -->
        (   nonvar(X) -> a(Y, B)
        ;   nonvar(Y) -> a(X, B)
        ;   [a(X,Y,B)]
        ).

a(X, B) -->
        (   { var(X) } -> [a(X, B)]
        ;   a(B)
        ).

a(B) -->
        (   { var(B) } -> [a(B)]
        ;   []
        ).

as([])     --> [].
as([B|Bs]) --> a(B), as(Bs).

kill_reified_tuples([], _, _) --> [].
kill_reified_tuples([B|Bs], Ps, All) -->
    [p(P)],
    { propagator_from_constraint(kill_reified_tuples(B,Ps,All), P),
      propagator_trigger(P, [B]) },
    kill_reified_tuples(Bs, Ps, All).

relation_tuple_b_prop(Relation, Tuple, B, p(Prop)) :-
        put_attr(R, clpz_relation, Relation),
        propagator_from_constraint(reified_tuple_in(Tuple,R,B), Prop),
        queue_empty(Q0),
        phrase(
            (   map('@tuple_freeze'(Prop), Tuple),
                propagator_variable(Prop, B),
                % QUESTION: Why no `propagator_queue//1`?
                propagator_catalyze
            ),
            [Q0],
            _
        ).
