% Match variables to created skeleton.

skeleton(Vs, Vs-Prop) :-
        (   propagator_state(Prop, State), State == dead ->
            true
        ;   maplist(prop_init(Prop), Vs),
            trigger_once(Prop)
        ).
