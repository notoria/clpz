/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Propagator
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A propagator is a term of the form propagator(C, State), where C
   represents a constraint, and State is a free variable that can be
   used to destructively change the state of the propagator via
   attributes. This can be used to avoid redundant invocation of the
   same propagator, or to disable the propagator.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

propagator_constraint(propagator(C,_), C).

propagator_state(propagator(_,S), S).

propagator_from_constraint(C, P) :-
    propagator_constraint(P, C).

propagator_variable(P, V) :-
    (   fd_get(V, Dom, Ps0)
    ->  propagator_insert(P, Ps0, Ps),
        fd_put(V, Dom, Ps)
    ;   true
    ).

propagator_variable(P, V) -->
    (   { fd_get(V, Dom, Ps0) }
    ->  { propagator_insert(P, Ps0, Ps) },
        fd_put(V, Dom, Ps)
    ;   [] % Case where the variable is ground now.
    ).

propagator_insert(P, Ps0, Ps) :-
    (   propagator_constraint(P, C),
        functor(C, F, _),
        constraint_wake(F, W)
    ->  true
    ;   W = other
    ),
    '@propagator_insert'(W, P, Ps0, Ps).

% '@propagator_insert'(ground, P, fd_props(Gs0,Bs,Os), fd_props(Gs,Bs,Os)) :-
%     list_append(Gs0, [P], Gs).
% '@propagator_insert'(bounds, P, fd_props(Gs,Bs0,Os), fd_props(Gs,Bs,Os)) :-
%     list_append(Bs0, [P], Bs).
% '@propagator_insert'( other, P, fd_props(Gs,Bs,Os0), fd_props(Gs,Bs,Os)) :-
%     list_append(Os0, [P], Os).

'@propagator_insert'(ground, P, fd_props(Gs,Bs,Os), fd_props([P|Gs],Bs,Os)).
'@propagator_insert'(bounds, P, fd_props(Gs,Bs,Os), fd_props(Gs,[P|Bs],Os)).
'@propagator_insert'( other, P, fd_props(Gs,Bs,Os), fd_props(Gs,Bs,[P|Os])).

% propagator_queue(P) :- trigger_once(P).
% 
% trigger_once(P) :-
%         queue_empty(Q),
%         trigger_once_(P, Q).
% 
% trigger_once_(P, Q) :-
%         phrase((propagator_queue(P),propagator_catalyze), [Q], _).

propagator_trigger(P, Vs) :-
    queue_empty(Q0),
    phrase(propagator_trigger(P, Vs), [Q0], _).

propagator_trigger(P, Vs) -->
    map(propagator_variable(P), Vs),
    { queue_unify(Vs) },
    propagator_queue(P),
    propagator_catalyze.

propagator_queue(P) -->
    { propagator_state(P, State) },
    (   { State == dead }
    ->  []
    ;   { get_attr(State, clpz_aux, queued) }
    ->  []
    ;   % passive
        % { propagator_constraint(P, C0), portray_clause(user_output, queue-C0) },
        { put_attr(State, clpz_aux, queued) },
        (   {   propagator_constraint(P, C),
                functor(C, F, _),
                constraint_global(F)
            }
        ->  queue_pslow(P)
        ;   queue_pfast(P)
        )
    ).

propagator_dead(P) :-
    propagator_state(P, S),
    S == dead.

propagator_goals(P) -->
    { propagator_constraint(P, C), propagator_state(P, State) },
    (   { ground(State) }
    ->  []
    ;   { phrase(constraint_goals(C), Gs0) }
    ->  {   del_attr(State, clpz_aux),
            State = processed,
            (   monotonic
            ->  list_map(unwrap_with(bare_integer), Gs0, Gs1)
            ;   list_map(unwrap_with(=), Gs0, Gs1)
            ),
            list_map(with_clpz, Gs1, Gs)
        },
        map(identity, Gs)
    ;   [C] % possibly user-defined constraint
    ).

propagator_activate(P) -->
    { propagator_state(P, State) },
    (   State == dead
    ->  []
    ;   { del_attr(State, clpz_aux), propagator_constraint(P, C) },
        % { portray_clause(user_output, run-C) },
        (   { constraint_once(C) }
        ->  propagate(C, State)
        ;   propagate(C, State)
        )
    ).

% Propagators
propagators_empty(fd_props([],[],[])).

propagators_constraint(fd_props(Ps,_,_), C) :-
    list_element(Ps, P),
    propagator_constraint(P, C).
propagators_constraint(fd_props(_,Ps,_), C) :-
    list_element(Ps, P),
    propagator_constraint(P, C).
propagators_constraint(fd_props(_,_,Ps), C) :-
    list_element(Ps, P),
    propagator_constraint(P, C).

propagators_queuegb(fd_props(Gs,Bs,Os), X, D0, D) -->
    (   { ground(X), portray_clause(user_output, propagators(ground)) }
    ->  map(propagator_queue, Gs),
        map(propagator_queue, Bs)
    ;   '@propagator_queue'(Bs, D0, D)
    ),
    map(propagator_queue, Os).

'@propagator_queue'([], _, _) --> [].
'@propagator_queue'([B|Bs], D0, D) -->
    (   {   domain_infimum(D0, I), domain_infimum(D, I),
            domain_supremum(D0, S), domain_supremum(D, S)
        }
    ->  []
    ;   map(propagator_queue, [B|Bs])
    ).

% propagators_queueg(fd_props(Gs,Bs,Os), X) -->
%     map(propagator_queue, Os),
%     map(propagator_queue, Bs),
%     (   { ground(X) } ->
%         map(propagator_queue, Gs)
%     ;   []
%     ).

propagators_queue(fd_props(Gs,Bs,Os)) -->
    map(propagator_queue, Gs),
    map(propagator_queue, Bs),
    map(propagator_queue, Os).

propagators_number(fd_props(Gs,Bs,Os), N) :-
    list_length(Gs, N1),
    list_length(Bs, N2),
    list_length(Os, N3),
    list_foldl(integer_add, [N1,N2,N3], 0, N).

propagators_dead(fd_props(Gs,Bs,Os)) :-
    list_map(propagator_dead, Gs),
    list_map(propagator_dead, Bs),
    list_map(propagator_dead, Os).

propagators_append(
    fd_props(Gs0,Bs0,Os0), fd_props(Gs1,Bs1,Os1), fd_props(Gs,Bs,Os)
) :-
    list_map(list_append, [Gs0,Bs0,Os0], [Gs1,Bs1,Os1], [Gs,Bs,Os]).

propagators_goals(fd_props(Gs,Bs,Os)) -->
    map(propagator_goals, Gs),
    map(propagator_goals, Bs),
    map(propagator_goals, Os).


% propagator_catalyze -->
%     queue_portray,
%     { false }.
propagator_catalyze -->
    (   queue_enabled
    ->  (   queue_ggoal(Goal)
        ->  { call(Goal) },
            propagator_catalyze
        ;   queue_gfast(Fast)
        ->  propagator_activate(Fast),
            propagator_catalyze
        ;   queue_gslow(Slow)
        ->  propagator_activate(Slow),
            propagator_catalyze
        ;   []
        )
    ;   []
    ).

% propagator_portray(propagator(C,_), F) :- functor(C, F, _).

% all_propagators(fd_props(Gs,Bs,Os)) -->
%         propagators_(Gs),
%         propagators_(Bs),
%         propagators_(Os).
% 
% propagators_([]) --> [].
% propagators_([P|Ps]) --> propagator_(P), propagators_(Ps).
% 
% propagator_(Propagator) -->
%         { propagator_state(Propagator, State) },
%         (   { State == dead } -> []
%         ;   { get_attr(State, clpz_aux, queued) } -> []
%         ;   % passive
%             % format("triggering: ~w\n", [Propagator]),
%             [clpz:propagator_queue(Propagator)]
%         ).
