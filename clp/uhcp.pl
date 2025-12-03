/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Unification hook and constraint projection
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

verify_attributes(Var, Other, Gs) :-
    % portray_clause(Var = Other),
    (   get_attr(Var, clpz, CLPZ0) % get_atts(Var, +clpz(CLPZ))
    ->  CLPZ0 = clpz_attr(_,_,_,Dom0,Ps0,Q0),
        (   nonvar(Other)
        ->  (   integer(Other)
            ->  true
            ;   type_error(integer, Other)
            ),
            domain_contains(Dom0, Other),
            phrase(propagators_queue(Ps0), [Q0], [_]),
            Gs = [phrase(propagator_catalyze, [Q0], _)]
        ;   (   get_attr(Other, clpz, CLPZ1) % get_atts(Other, +clpz(clpz_attr(_,_,_,Dom1,Ps1,_)))
            ->  CLPZ1 = clpz_attr(_,_,_,Dom1,Ps1,_),
                domain_inter(Dom1, Dom0, Dom),
                propagators_append(Ps0, Ps1, Ps),
                queue_empty(Q),
                queue_unify([Var,Other]),
                phrase((fd_put(Other,Dom,Ps), propagators_queue(Ps)), [Q], _),
                Gs = [phrase(propagator_catalyze, [Q], _)]
            ;   put_attr(Other, clpz, CLPZ0), % put_atts(Other, +clpz(CLPZ0)),
                Gs = []
            )
        )
    ;   Gs = []
    ).

attribute_goals(X) -->
    '@attribute_clpz'(X),
    '@attribute_clpz_aux'(X),
    '@attribute_clpz_relation'(X),
    '@attribute_edges'(X),
    '@attribute_flow'(X),
    '@attribute_parent'(X),
    '@attribute_free'(X),
    '@attribute_g0_edges'(X),
    '@attribute_used'(X),
    '@attribute_lowlink'(X),
    '@attribute_value'(X),
    '@attribute_visited'(X),
    '@attribute_index'(X),
    '@attribute_in_stack'(X),
    '@attribute_clpz_gcc_vs'(X),
    '@attribute_clpz_gcc_num'(X),
    '@attribute_clpz_gcc_occurred'(X),
    '@attribute_queue'(X),
    '@attribute_disabled'(X).


'@attribute_clpz'(X) -->
    % { get_attr(X, clpz, Attr), format("A: ~w\n", [Attr]) },
    (   { get_attr(X, clpz, clpz_attr(_,_,_,Dom,Ps,_)) }
    ->  (   { domain_from_bounds(inf, sup, Dom), \+ propagators_dead(Ps) }
        ->  []
        ;   { drep_from_domain(Dom, Drep), with_clpz(X in Drep, G) },
            [G]
        ),
        propagators_goals(Ps),
        { del_attr(X, clpz) }
    ;   []
    ).

'@attribute_clpz_aux'(X) -->
    (   { get_attr(X, clpz_aux, Attr) }
    ->  [clpz:put_attr(X, clpz_aux, Attr)],
        { del_attr(X, clpz_aux) }
    ;   []
    ).

'@attribute_clpz_relation'(X) -->
    (   { get_attr(X, clpz_relation, Attr) }
    ->  [clpz:put_attr(X, clpz_relation, Attr)],
        { del_attr(X, clpz_relation) }
    ;   []
    ).

'@attribute_edges'(X) -->
    (   { get_attr(X, edges, Attr) }
    ->  [clpz:put_attr(X, edges, Attr)],
        { del_attr(X, edges) }
    ;   []
    ).

'@attribute_flow'(X) -->
    (   { get_attr(X, flow, Attr) }
    ->  [clpz:put_attr(X, flow, Attr)],
        { del_attr(X, flow) }
    ;   []
    ).

'@attribute_parent'(X) -->
    (   { get_attr(X, parent, Attr) }
    ->  [clpz:put_attr(X, parent, Attr)],
        { del_attr(X, parent) }
    ;   []
    ).

'@attribute_free'(X) -->
    (   { get_attr(X, free, Attr) }
    ->  [clpz:put_attr(X, free, Attr)],
        { del_attr(X, free) }
    ;   []
    ).

'@attribute_g0_edges'(X) -->
    (   { get_attr(X, g0_edges, Attr) }
    ->  [clpz:put_attr(X, g0_edges, Attr)],
        { del_attr(X, g0_edges) }
    ;   []
    ).

'@attribute_used'(X) -->
    (   { get_attr(X, used, Attr) }
    ->  [clpz:put_attr(X, used, Attr)],
        { del_attr(X, used) }
    ;   []
    ).

'@attribute_lowlink'(X) -->
    (   { get_attr(X, lowlink, Attr) }
    ->  [clpz:put_attr(X, lowlink, Attr)],
        { del_attr(X, lowlink) }
    ;   []
    ).

'@attribute_value'(X) -->
    (   { get_attr(X, value, Attr) }
    ->  [clpz:put_attr(X, value, Attr)],
        { del_attr(X, value) }
    ;   []
    ).

'@attribute_visited'(X) -->
    (   { get_attr(X, visited, Attr) }
    ->  [clpz:put_attr(X, visited, Attr)],
        { del_attr(X, visited) }
    ;   []
    ).

'@attribute_index'(X) -->
    (   { get_attr(X, index, Attr) }
    ->  [clpz:put_attr(X, index, Attr)],
        { del_attr(X, index) }
    ;   []
    ).

'@attribute_in_stack'(X) -->
    (   { get_attr(X, in_stack, Attr) }
    ->  [clpz:put_attr(X, in_stack, Attr)],
        { del_attr(X, in_stack) }
    ;   []
    ).

'@attribute_clpz_gcc_vs'(X) -->
    (   { get_attr(X, clpz_gcc_vs, Attr) }
    ->  [clpz:put_attr(X, clpz_gcc_vs, Attr)],
        { del_attr(X, clpz_gcc_vs) }
    ;   []
    ).

'@attribute_clpz_gcc_num'(X) -->
    (   { get_attr(X, clpz_gcc_num, Attr) }
    ->  [clpz:put_attr(X, clpz_gcc_num, Attr)],
        { del_attr(X, clpz_gcc_num) }
    ;   []
    ).

'@attribute_clpz_gcc_occurred'(X) -->
    (   { get_attr(X, clpz_gcc_occurred, Attr) }
    ->  [clpz:put_attr(X, clpz_gcc_occurred, Attr)],
        { del_attr(X, clpz_gcc_occurred) }
    ;   []
    ).

'@attribute_queue'(X) -->
    (   { get_atts(X, +queue(H,T)) }
    ->  [clpz:put_atts(X, +queue(H,T))],
        { put_atts(X, -queue(_,_)) }
    ;   []
    ).

'@attribute_disabled'(X) -->
    (   { get_atts(X, +disabled) }
    ->  [clpz:put_atts(X, +disabled)],
        { put_atts(X, -disabled) }
    ;   []
    ).

attribute_goal(Var, Goal) :-
    phrase(attribute_goals(Var), Goals),
    goals_goal(',', Goals, Goal).

% with_clpz(G, G).
with_clpz(G, clpz:G).

unwrap_with(G_2, T0, T) :-
    (   var(T0)
    ->  T = T0
    ;   T0 = #T1
    ->  call(G_2, T1, T)
    ;   T0 =.. [N|As0],
        list_map(unwrap_with(G_2), As0, As),
        T =.. [N|As]
    ).

bare_integer(V0, V) :-
    (   var(V0)
    ->  V = #V0
    ;   integer(V0),
        V = V0
    ).
