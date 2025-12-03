%% serialized(+Starts, +Durations)
%
%  Describes a set of non-overlapping tasks.
%  Starts = [S_1,...,S_n], is a list of variables or integers,
%  Durations = [D_1,...,D_n] is a list of non-negative integers.
%  Constrains Starts and Durations to denote a set of
%  non-overlapping tasks, i.e.: S_i + D_i =< S_j or S_j + D_j =<
%  S_i for all 1 =< i < j =< n. Example:
%
% ```
% ?- list_length(Vs, 3),
%    Vs ins 0..3,
%    serialized(Vs, [1,2,3]),
%    label(Vs).
%    Vs = [0,1,3]
% ;  Vs = [2,0,3]
% ;  false.
% ```
%
%  @see Dorndorf et al. 2000, "Constraint Propagation Techniques for the
%       Disjunctive Scheduling Problem"

serialized(Starts, Durations) :-
        must_be(list, Starts),
        must_be(list(integer), Durations),
        % list_equisized(Durations, SDs),
        pairs_keys_values(SDs, Starts, Durations),
        % Starts ins inf..sup,
        domain_from_bounds(inf, sup, D0), list_map('@in'(D0), Starts),
        % Durations ins 0..sup,
        domain_from_bounds(n(0), sup, D1), list_map('@in'(D1), Durations),
        Orig = original_goal(_, serialized(Starts, Durations)),
        serialize(SDs, Orig).

serialize([], _).
serialize([S-D|SDs], Orig) :-
        D >= 0,
        serialize(SDs, S, D, Orig),
        serialize(SDs, Orig).

serialize([], _, _, _).
serialize([S-D|Rest], S0, D0, Orig) :-
    D >= 0,
    propagator_from_constraint(pserialized(S,D,S0,D0,Orig), P),
    propagator_trigger(P, [S0,S]),
    serialize(Rest, S0, D0, Orig).

% consistency check / propagation
% Currently implements 2-b-consistency

earliest_start_time(Start, EST) :-
        (   fd_get(Start, D, _) ->
            domain_infimum(D, EST)
        ;   EST = n(Start)
        ).

latest_start_time(Start, LST) :-
        (   fd_get(Start, D, _) ->
            domain_supremum(D, LST)
        ;   LST = n(Start)
        ).

serialize_lower_upper(S_I, D_I, S_J, D_J, MState) -->
        (   { var(S_I) } ->
            serialize_lower_bound(S_I, D_I, S_J, D_J, MState),
            (   { var(S_I) } ->
                serialize_upper_bound(S_I, D_I, S_J, D_J, MState)
            ;   []
            )
        ;   []
        ).

serialize_lower_bound(I, D_I, J, D_J, MState) -->
        { fd_get(I, DomI, Ps) },
        (   { domain_infimum(DomI, n(EST_I)),
              latest_start_time(J, n(LST_J)),
              EST_I + D_I > LST_J,
              earliest_start_time(J, n(EST_J)) } ->
            (   nonvar(J) -> kill(MState)
            ;   []
            ),
            { integer_add(EST_J, D_J, EST),
              domain_remove_less_than(EST, DomI, DomI1) },
            fd_put(I, DomI1, Ps)
        ;   []
        ).

serialize_upper_bound(I, D_I, J, D_J, MState) -->
        { fd_get(I, DomI, Ps) },
        (   { domain_supremum(DomI, n(LST_I)),
              earliest_start_time(J, n(EST_J)),
              EST_J + D_J > LST_I,
              latest_start_time(J, n(LST_J)) } ->
            (   nonvar(J) -> kill(MState)
            ;   []
            ),
            { integer_add(LST, D_I, LST_J),
              domain_remove_greater_than(LST, DomI, DomI1) },
            fd_put(I, DomI1, Ps)
        ;   []
        ).
