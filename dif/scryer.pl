:- module(dif, [dif/2]).
:- use_module(library(iso_ext)).
:- use_module(library(dcgs)).
:- use_module(library(lists)).

:- attribute(difs/1).

identity(E) --> [E].

map(_G__1, []) --> [].
map(G__1, [E|Es]) --> call(G__1, E), map(G__1, Es).

map(_G__2, [], []) --> [].
map(G__2, [E0|Es0], [E|Es]) --> call(G__2, E0, E), map(G__2, Es0, Es).

element(Es, E) :-
    member(E, Es).

% equations(X, Y) --> call('@equations'(X, Y)).

equations(X, Y, Es0, Es) :-
    phrase('@equations'([], Es0, X, Y), Es0, Es).

'@equations'(Es, Es0, X, Y) -->
    (   { X == Y }
    ->  []
    ;   { element(Es, E0), element([X=Y,Y=X], E), E0 == E }
    ->  []
    ;   { nonvar(X), nonvar(Y) }
    ->  {   functor(X, N, A), functor(Y, N, A),
            X =.. [N|Xs0], Y =.. [N|Ys0]
        },
        map('@equations'([X=Y|Es], Es0), Xs0, Ys0)
    ;   { element([X=Y,Y=X], E), \+ maplist(\==(E), Es0) }
    ->  []
    ;   [X=Y]
    ).

unsafe_goal(Vs, G_0) -->
    (   { call(G_0), maplist(var, Vs), term_variables(Vs, Vs) }
    ->  []
    ;   [G_0]
    ).

differ(V0, V1) -->
    (   {   get_atts(V0, +difs(Es0)),
            var(V1), get_atts(V1, +difs(Es1))
        }
    ->  { append(Es0, Es1, Es) },
        [maplist(dif_clean, Es),maplist(dif_redo, Es)]
    ;   { get_atts(V0, +difs(Es0)), var(V1) }
    ->  { put_atts(V1, +difs(Es0)) }
    ;   { get_atts(V0, +difs(Es)) }
    ->  [maplist(dif_clean, Es),maplist(dif_redo, Es)]
    ;   []
    ).

verify_attributes(V0, V1, Gs) :-
    phrase(differ(V0, V1), Gs).

dif_goal(X=Y) -->
    { dif_clean(X=Y) },
    [dif:dif(X,Y)].

differed(V) -->
    { get_atts(V, +difs(Es)) },
    map(dif_goal, Es).

attribute_goals(V) --> differed(V).

dif_insert(X=Y, V) :-
    (   get_atts(V, +difs(Es0))
    ->  (   select(E0, Es0, Es),
            element([X=Y,Y=X], E),
            E0 == E
        ->  true
        ;   Es = Es0
        )
    ;   Es = []
    ),
    put_atts(V, +difs([X=Y|Es])).

'@dif_remove'([], V) :-
    put_atts(V, -difs(_)).
'@dif_remove'([E|Es], V) :-
    put_atts(V, +difs([E|Es])).

dif_remove(X=Y, V) :-
    (   get_atts(V, +difs(Es0)),
        select(E0, Es0, Es),
        element([X=Y,Y=X], E),
        E == E0
    ->  '@dif_remove'(Es, V)
    ;   true
    ).

dif_clean(X=Y) :-
    term_variables(X=Y, Vs),
    maplist(dif_remove(X=Y), Vs).

dif_redo(X=Y) :-
    dif(X, Y).

dif_trigger(X=Y) :-
    dif_clean(X=Y),
    dif_once(X, Y).

dif_eqs(V) -->
    (   { get_atts(V, +difs(Es)) }
    ->  map(identity, Es)
    ;   []
    ).

dif_variables(X=Y, Vs) :-
    copy_term_nat(X=Y, U=U),
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
    (   select(K0-Vs, KVs0, KVs1), K0 == K
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

% dif_eqs([], _, E, E).
% dif_eqs([_|_], E, _, E).

% X=Y => X_0=Y_0/\X_1=Y_1/\... <=> dif(X_0,Y_0)\/dif(X_1,Y_1)\/.. => dif(X,Y)
% X=Y => X_0=Y_0\/X_1=Y_1\/... <=> dif(X_0,Y_0)/\dif(X_1,Y_1)/\.. => dif(X,Y)

dif_once(X, Y) :-
    E = (X=Y),
    term_variables(E, Vs),
    %%dif_variables(E, Vs),
    phrase(map(dif_eqs, Vs), Es0),
    sort(Es0, Es),
    (   copy_term_nat([E|Es], [T=T|Fs]),
        element(Fs, U=V),
        U == V
    ->  true
    ;   maplist(dif_insert(E), Vs)
    ).

dif(X, Y) :-
    X \== Y,
    (   copy_term_nat(X=Y, U=V),
        U \= V
    ->  true
    ;   (   phrase(equations(X, Y), [E])
        ->  true
        ;   E = (X=Y)
        ),
        term_variables(E, Vs),
        %%dif_variables(E, Vs),
        phrase(map(dif_eqs, Vs), Es0),
        sort(Es0, Es),
        (   copy_term_nat([E|Es], [T=T|Fs]),
            element(Fs, U=V),
            U == V
        ->  true
        ;   maplist(dif_insert(E), Vs),
            maplist(dif_trigger, Es)
        )
    ).
