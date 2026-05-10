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
    (   {   get_attribute(+, V0, difs(Es0)),
            var(V1), get_attribute(+, V1, difs(Es1))
        }
    ->  { list_append(Es0, Es1, Es) },
        [list_map(dif_clean, Es),list_map(dif_redo, Es)]
    ;   { get_attribute(+, V0, difs(Es0)), var(V1) }
    ->  {   put_attribute(+, V1, difs(Es0)),
            put_verifier(+, V1, differ),
            put_reifier(+, V1, differed)
        }
    ;   { get_attribute(+, V0, difs(Es)) }
    ->  [list_map(dif_clean, Es),list_map(dif_redo, Es)]
    ;   []
    ).

differed(V) -->
    { get_attribute(+, V, difs(Es)) },
    map(dif_goal, Es).

dif_goal(X=Y) -->
    { dif_clean(X=Y) },
    [dif:dif(X,Y)].

dif_insert(X=Y, V) :-
    (   get_attribute(+, V, difs(Es0))
    ->  (   list_select(E0, Es0, Es),
            list_element([X=Y,Y=X], E),
            E0 == E
        ->  true
        ;   Es = Es0
        )
    ;   Es = [],
        put_verifier(+, V, differ),
        put_reifier(+, V, differed)
    ),
    put_attribute(+, V, difs([X=Y|Es])).

dif_remove(X=Y, V) :-
    (   get_attribute(+, V, difs(Es0)),
        list_select(E0, Es0, Es),
        list_element([X=Y,Y=X], E),
        E == E0
    ->  '@dif_remove'(Es, V)
    ;   true
    ).

'@dif_remove'([], V) :-
    put_attribute(-, V, difs(_)),
    put_verifier(-, V, differ),
    put_reifier(-, V, differed).
'@dif_remove'([E|Es], V) :-
    put_attribute(+, V, difs([E|Es])).

dif_clean(X=Y) :-
    term_variables(X=Y, Vs),
    list_map(dif_remove(X=Y), Vs).

dif_redo(X=Y) :-
    dif(X, Y).

dif_trigger(X=Y) :-
    dif_clean(X=Y),
    dif_once(X, Y).

dif_eqs(V) -->
    (   { get_attribute(+, V, difs(Es)) }
    ->  map(identity, Es)
    ;   []
    ).

dif_variables(X=Y, Vs) :-
    copy_term(X=Y, U=U),
    phrase(equations(X=Y, U=U), Es),
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
    E = (X=Y),
    % term_variables(E, Vs),
    dif_variables(E, Vs),
    phrase(map(dif_eqs, Vs), Es0),
    '$uniques'(Es0, Es),
    (   copy_term([E|Es], [T=T|Fs]),
        list_element(Fs, U=V),
        U == V
    ->  true
    ;   list_map(dif_insert(E), Vs)
    ).

dif(X, Y) :-
    X \== Y,
    (   copy_term(X=Y, U=V),
        U \= V
    ->  true
    ;   (   (acyclic_term(X) ; acyclic_term(Y)),
            phrase(equations(X, Y), [E])
        ->  true
        ;   E = (X=Y)
        ),
        % term_variables(E, Vs),
        dif_variables(E, Vs),
        phrase(map(dif_eqs, Vs), Es0),
        '$uniques'(Es0, Es),
        (   copy_term([E|Es], [T=T|Fs]),
            list_element(Fs, U=V),
            U == V
        ->  true
        ;   list_map(dif_insert(E), Vs),
            list_map(dif_trigger, Es)
        )
    ).
