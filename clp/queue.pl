no_reactivation(rel_tuple(_,_)).
no_reactivation(pdistinct(_)).
no_reactivation(pnvalue(_)).
no_reactivation(pgcc(_,_,_)).
no_reactivation(pgcc_single(_,_)).
%no_reactivation(scalar_product(_,_,_,_)).

activate_propagator(propagator(P,State)) -->
        % { portray_clause(running(P)) },
        (   State == dead -> []
        ;   { del_attr(State, clpz_aux) },
            (   { no_reactivation(P) } ->
                % { bb_b_put('$clpz_current_propagator', State) },
                run_propagator(P, State)
                % { bb_b_put('$clpz_current_propagator', []) }
            ;   run_propagator(P, State)
            )
        ).

%do_queue --> print_queue, false.
do_queue -->
        (   queue_enabled ->
            (   queue_get_goal(Goal) -> { call(Goal) }, do_queue
            ;   queue_get_fast(Fast) -> activate_propagator(Fast), do_queue
            ;   queue_get_slow(Slow) -> activate_propagator(Slow), do_queue
            ;   true
            )
        ;   true
        ).

:- meta_predicate(ignore(0)).

ignore(Goal) :- ( call(Goal) -> true ; true ).

print_queue -->
        state(queue(Goal,Fast,Slow,_)),
        { ignore(get_atts(Goal, +queue(GHs,_))),
          ignore(get_atts(Fast, +queue(FHs,_))),
          ignore(get_atts(Slow, +queue(SHs,_))),
          format("Current queue:~n   goal: ~q~n   fast: ~q~n   slow: ~q~n~n", [GHs,FHs,SHs]) }.



queue_get_goal(Goal) --> queue_get_arg(1, Goal).
queue_get_fast(Fast) --> queue_get_arg(2, Fast).
queue_get_slow(Slow) --> queue_get_arg(3, Slow).

queue_get_arg(Which, Element) -->
        state(Queue),
        { queue_get_arg_(Queue, Which, Element) }.

queue_get_arg_(Queue, Which, Element) :-
        arg(Which, Queue, Arg),
        get_atts(Arg, +queue([Element|Elements],Tail)),
        (   var(Elements) ->
            put_atts(Arg, -queue(_,_))
        ;   put_atts(Arg, +queue(Elements,Tail))
        ).

queue_enabled --> state(queue(_,_,_,Aux)), { \+ get_atts(Aux, +disabled) }.
disable_queue --> state(queue(_,_,_,Aux)), { put_atts(Aux, +disabled) }.
enable_queue --> state(queue(_,_,_,Aux)), { put_atts(Aux, -disabled) }.
