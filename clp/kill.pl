kill(State) :- del_attr(State, clpz_aux), State = dead.

kill(State, Ps) :-
        kill(State),
        maplist(kill_entailed, Ps).

kill_entailed(p(Prop)) :-
        propagator_state(Prop, State),
        kill(State).
kill_entailed(a(V)) :-
        del_attr(V, clpz).
kill_entailed(a(X,B)) :-
        (   X == B -> true
        ;   del_attr(B, clpz)
        ).
kill_entailed(a(X,Y,B)) :-
        (   X == B -> true
        ;   Y == B -> true
        ;   del_attr(B, clpz)
        ).
