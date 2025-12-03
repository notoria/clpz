/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Queue
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

queue_empty(queue(Goal,Fast,Slow,Aux)) :-
    var(Goal),
    get_atts(Goal, -queue(_,_)),
    var(Fast),
    get_atts(Fast, -queue(_,_)),
    var(Slow),
    get_atts(Slow, -queue(_,_)),
    get_atts(Aux, -disabled).

queue_portray -->
    state(queue(Goal,Fast,Slow,_)),
    {   ignore(get_atts(Goal, +queue(GHs,_))),
        ignore(get_atts(Fast, +queue(FHs,_))),
        ignore(get_atts(Slow, +queue(SHs,_))),
        portray_clause(user_output, queue(goal(GHs),fast(FHs),slow(SHs)))
    }.

queue_parg(Element, Which) -->
    state(Queue),
    {   arg(Which, Queue, Arg),
        (   get_atts(Arg, +queue(Head0,Tail0)) ->
            Head = Head0,
            Tail0 = [Element|Tail]
        ;   Head = [Element|Tail]
        ),
        put_atts(Arg, +queue(Head,Tail))
    }.

queue_pgoal(Goal) --> queue_parg(Goal, 1).
queue_pfast(Prop) --> queue_parg(Prop, 2).
queue_pslow(Prop) --> queue_parg(Prop, 3).

:- meta_predicate(ignore(0)).

ignore(Goal) :- ( call(Goal) -> true ; true ).



queue_garg(Which, Element) -->
    state(Queue),
    {   arg(Which, Queue, Arg),
        get_atts(Arg, +queue([Element|Elements],Tail)),
        (   var(Elements) ->
            put_atts(Arg, -queue(_,_))
        ;   put_atts(Arg, +queue(Elements,Tail))
        )
    }.

queue_ggoal(Goal) --> queue_garg(1, Goal).
queue_gfast(Fast) --> queue_garg(2, Fast).
queue_gslow(Slow) --> queue_garg(3, Slow).

queue_enabled --> state(queue(_,_,_,Aux)), { \+ get_atts(Aux, +disabled) }.
queue_disable --> state(queue(_,_,_,Aux)), { put_atts(Aux, +disabled) }.
queue_enable --> state(queue(_,_,_,Aux)), { put_atts(Aux, -disabled) }.


queue_unify(Vs0) :-
    phrase(map(variable, Vs0), Vs),
    '@queue_unify'(Vs).

'@queue_unify'([]).
'@queue_unify'([V|Vs]) :-
    list_map(queue_from_variable, [V|Vs], Qs0),
    uniques(Qs0, [Q|Qs]),
    Q =.. [_|Args],
    list_foldl(queue_append([append,append,append,ignore]), Qs, Args, _),
    list_map(queue_clear, Qs),
    list_map(=(Q), Qs).

queue_append(Is, Q, S0, S) :-
    Q =.. [_|S1],
    list_map('@queue_append', Is, S0, S1),
    S = S1.

'@queue_append'(ignore, _, _).
'@queue_append'(append, Q0, Q) :-
        (   get_atts(Q0, +queue(Ls0,Ls1)) ->
            (   get_atts(Q, +queue(Ls2,Ls)) ->
                Ls1 = Ls2,
                put_atts(Q0, +queue(Ls0,Ls))
            ;   true
            )
        ;   (   get_atts(Q, +queue(Ms0,Ms)) ->
                put_atts(Q0, +queue(Ms0,Ms))
            ;   true
            )
        ).

queue_clear(queue(Goals,Fast,Slow,Aux)) :-
    put_atts(Goals, -queue(_,_)),
    put_atts(Fast, -queue(_,_)),
    put_atts(Slow, -queue(_,_)),
    put_atts(Aux, -disabled).

queue_from_variable(V, Q) :-
    get_attr(V, clpz, Attr),
    Attr = clpz_attr(_Left,_Right,_Spread,_Dom,_Ps,Q).
