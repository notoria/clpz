/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A propagator is a term of the form propagator(C, State), where C
   represents a constraint, and State is a free variable that can be
   used to destructively change the state of the propagator via
   attributes. This can be used to avoid redundant invocation of the
   same propagator, or to disable the propagator.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

make_propagator(C, propagator(C, _)).

propagator_state(propagator(_,S), S).

trigger_props(fd_props(Gs,Bs,Os), X, D0, D) -->
        (   { ground(X) } ->
            trigger_props_(Gs),
            trigger_props_(Bs)
        ;   Bs \== [] ->
            { domain_infimum(D0, I0),
              domain_infimum(D, I) },
            (   { I == I0 } ->
                { domain_supremum(D0, S0),
                  domain_supremum(D, S) },
                (   { S == S0 } -> []
                ;   trigger_props_(Bs)
                )
            ;   trigger_props_(Bs)
            )
        ;   []
        ),
        trigger_props_(Os).

trigger_props(fd_props(Gs,Bs,Os), X) -->
        trigger_props_(Os),
        trigger_props_(Bs),
        (   { ground(X) } ->
            trigger_props_(Gs)
        ;   []
        ).

trigger_props(fd_props(Gs,Bs,Os)) -->
        trigger_props_(Gs),
        trigger_props_(Bs),
        trigger_props_(Os).

trigger_props_([]) --> [].
trigger_props_([P|Ps]) --> trigger_prop(P), trigger_props_(Ps).

trigger_prop(P) :- trigger_once(P).

trigger_prop(Propagator) -->
        { propagator_state(Propagator, State) },
        (   { State == dead } -> []
        ;   { get_attr(State, clpz_aux, queued) } -> []
        % ;   { bb_get('$clpz_current_propagator', C), C == State } -> []
        ;   % passive
            %{ format("triggering: ~w\n", [Propagator]) },
            { put_attr(State, clpz_aux, queued) },
            (   { arg(1, Propagator, C), functor(C, F, _), global_constraint(F) } ->
                queue_slow(Propagator)
            ;   queue_fast(Propagator)
            )
        ).

all_propagators(fd_props(Gs,Bs,Os)) -->
        propagators_(Gs),
        propagators_(Bs),
        propagators_(Os).

propagators_([]) --> [].
propagators_([P|Ps]) --> propagator_(P), propagators_(Ps).

propagator_(Propagator) -->
        { propagator_state(Propagator, State) },
        (   { State == dead } -> []
        ;   { get_attr(State, clpz_aux, queued) } -> []
        ;   % passive
            % format("triggering: ~w\n", [Propagator]),
            [clpz:trigger_prop(Propagator)]
        ).
