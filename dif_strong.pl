:- include("core").
:- include("dcg").
:- include("list").


identity(E) --> [E].

map(_, []) --> [].
map(G__1, [E|Es]) --> call(G__1, E), map(G__1, Es).

map(_, [], []) --> [].
map(G__2, [E0|Es0], [E|Es]) --> call(G__2, E0, E), map(G__2, Es0, Es).

% equations(X, Y) --> call('@equations'(X, Y)).

equations(X, Y, Eqs0, Eqs) :-
    phrase('@equations'(Eqs0, X, Y), Eqs0, Eqs).

'@equations'(Eqs0, X, Y) -->
    (   { X == Y }
    ->  []
    ;   { nonvar(X), nonvar(Y) }
    ->  {   functor(X, N, A), functor(Y, N, A),
            X =.. [N|Xs0], Y =.. [N|Ys0]
        },
        map('@equations'(Eqs0), Xs0, Ys0)
    ;   { list_element([X=Y,Y=X], Eq), \+ list_map(\==(Eq), Eqs0) }
    ->  []
    ;   [X=Y]
    ).

unsafe_goal(Vs, G_0) -->
    (   { call(G_0), list_map(var, Vs), term_variables(Vs, Vs) }
    ->  []
    ;   [G_0]
    ).

differ(V0, V1) -->
    (   {   get_attribute(+, V0, difs(Ps0)),
            var(V1), get_attribute(+, V1, difs(Ps1))
        }
    ->  { list_append(Ps0, Ps1, Ps) },
        [list_map(dif_clean, Ps),list_map(dif_redo, Ps)]
    ;   { get_attribute(+, V0, difs(Ps)), var(V1) }
    ->  [list_map(dif_clean, Ps),list_map(dif_redo, Ps)]
    ;   { get_attribute(+, V0, difs(Ps)) }
    ->  [list_map(dif_clean, Ps),list_map(dif_redo, Ps)]
    ;   { var(V1), get_attribute(+, V1, difs(Ps)) }
    ->  [list_map(dif_clean, Ps),list_map(dif_redo, Ps)]
    ;   []
    ).

differed(V) -->
    { get_attribute(+, V, difs(Ps)) },
    map(dif_goal, Ps).

dif_goal(X-Y) -->
    { dif_clean(X-Y) },
    [dif:dif(X,Y)].

dif_insert(X-Y, V) :-
    (   get_attribute(+, V, difs(Ps0))
    ->  (   list_select(P0, Ps0, Ps),
            list_element([X-Y,Y-X], P),
            P0 == P
        ->  true
        ;   Ps = Ps0
        )
    ;   Ps = [],
        put_verifier(+, V, differ),
        put_reifier(+, V, differed)
    ),
    put_attribute(+, V, difs([X-Y|Ps])).

dif_remove(X-Y, V) :-
    (   get_attribute(+, V, difs(Ps0)),
        list_select(P0, Ps0, Ps),
        list_element([X-Y,Y-X], P),
        P == P0
    ->  '@dif_remove'(Ps, V)
    ;   true
    ).

'@dif_remove'([], V) :-
    put_attribute(-, V, difs(_)),
    put_verifier(-, V, differ),
    put_reifier(-, V, differed).
'@dif_remove'([P|Ps], V) :-
    put_attribute(+, V, difs([P|Ps])).

dif_clean(X-Y) :-
    term_variables(X-Y, Vs),
    list_map(dif_remove(X-Y), Vs).

dif_redo(X-Y) :-
    dif(X, Y).

dif_trigger(X-Y) :-
    dif_clean(X-Y),
    dif_once(X, Y).

dif_pairs(V) -->
    (   { get_attribute(+, V, difs(Ps)) }
    ->  map(identity, Ps)
    ;   []
    ).

dif_variables(X-Y, Vs) :-
    copy_term(X-Y, U-U),
    phrase(equations(X-Y, U-U), Es),
    phrase(map(dif_variable, Es), KVs0),
    list_foldl(dif_group, KVs0, [], KVs1),
    phrase(map(dif_single, KVs1), Vs0),
    term_variables(Vs0, Vs).
    % term_variables(X=Y, Vs1),
    % dif_inter(Vs0, Vs1, Vs).

dif_variable(X=Y) -->
    (   { var(Y) }
    ->  [Y-X]
    ;   [!-X]
    ).

dif_group(K-V, KVs0, KVs) :-
    (   list_select(K0-Vs, KVs0, KVs1), K0 == K
    ->  KVs = [K-[V|Vs]|KVs1]
    ;   KVs = [K-[V]|KVs0]
    ).

dif_single(K-Vs0) -->
    (   { K == ! }
    ->  { term_variables(Vs0, Vs) },
        map(identity, Vs)
    ;   { Vs0 = [_] }
    ->  []
    ;   { term_variables(Vs0, Vs) },
        map(identity, Vs)
    ).

dif_once(X, Y) :-
    % X \== Y,
    (   X \= Y
    ->  true
    ;   P = X-Y,
        % term_variables(P, Vs),
        dif_variables(P, Vs),
        list_map(dif_insert(P), Vs)
    ).

dif(X, Y) :-
    X \== Y,
    (   X \= Y
    ->  true
    ;   (   (acyclic_term(X) ; acyclic_term(Y)),
            phrase(equations(X, Y), [U=V])
        ->  P = U-V
        ;   P = X-Y
        ),
        % term_variables(P, Vs),
        dif_variables(P, Vs),
        phrase(map(dif_pairs, Vs), Ps0),
        '$uniques'(Ps0, Ps),
        list_map(dif_insert(P), Vs),
        list_map(dif_trigger, Ps)
    ).

dif_uniques(Es0, Es) :-
    list_reversed(Es0, Es1),
    '@dif_uniques'(Es1, [], Es).

'@dif_uniques'([], Es, Es).
'@dif_uniques'([X=Y|Es0], Es1, Es) :-
    list_element([X=Y,Y=X], E),
    \+ list_map(\==(E), Es0),
    !,
    '@dif_uniques'(Es0, Es1, Es).
'@dif_uniques'([E|Es0], Es1, Es) :-
    '@dif_uniques'(Es0, [E|Es1], Es).

dif_append([], Ps, Ps).
dif_append([X-Y|Ps0], Ps1, Ps) :-
    list_element([X-Y,Y-X], P0),
    \+ list_map(\==(P0), Ps1),
    !,
    dif_append(Ps0, Ps1, Ps).
dif_append([P0|Ps0], Ps1, Ps) :-
    list_append(Ps1, [P0], Ps2),
    dif_append(Ps0, Ps2, Ps).
