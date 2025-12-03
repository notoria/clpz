% Match variables to created skeleton.

skeleton(Vs, Vs-Prop) :-
    (   propagator_state(Prop, State),
        State == dead
    ->  true
    ;   list_map(propagator_variable(Prop), Vs),
        propagator_trigger(Prop, [])
        % propagator_trigger(Prop, Vs) % QUESTION: why not?
    ).
