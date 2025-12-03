/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A drep is a user-accessible and visible domain representation. N,
   N..M, and D1 \/ D2 are dreps, if D1 and D2 are dreps.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

drep(R) :-
    var(R),
    throw(error(instantiation_error,drep/1)).
% drep(N) :- integer(N).
drep(F..T) :-
    bound_from_defaulty(F, I),
    bound_from_defaulty(T, S),
    interval(I-S).
    % drep_bound(F), drep_bound(T), F \== sup, T \== inf.
drep(D0\/D1) :- drep(D0), drep(D1).
drep({}).
drep({AI}) :- drep_iais(AI).
drep(\D) :- drep(D).

% Is and Integers
drep_iais(I) :-
    var(I),
    throw(error(instantiation_error,drep/1)).
drep_iais(I) :- integer(I).
drep_iais((A,B)) :- drep_iais(A), drep_iais(B).

drep_bound(I) :-
    var(I),
    throw(error(instantiation_error,drep/1)).
drep_bound(I) :- integer(I).
drep_bound(sup).
drep_bound(inf).

drep_from_numbers(Ns, DR) :-
    intervals_from_numbers(Ns, Is),
    drep_from_intervals(Is, DR).

'@@drep_from_interval'(=, B0-B0, {B}) :-
    bound_to_defaulty(B0, B).
'@@drep_from_interval'(<, F0-T0, F..T) :-
    bound_to_defaulty(F0, F),
    bound_to_defaulty(T0, T).

'@drep_from_interval'(F-T, DR) :-
    cis_compare(O, F, T),
    '@@drep_from_interval'(O, F-T, DR).

'@drep_iand'((Is0,Is1)) --> drep_iand(Is0), drep_iand(Is1).

drep_iand(T) -->
    (   { integer(T) }
    ->  [T]
    ;   '@drep_iand'(T)
    ).

'@drep_from_interval'(F..T, {}, {}) --> [F..T].
'@drep_from_interval'(F..T, {Is0}, {}) -->
    '@drep_from_interval'({Is0}),
    [F..T].
'@drep_from_interval'({Is0}, {}, {Is0}) --> [].
'@drep_from_interval'({Is1}, {Is0}, {Is0,Is1}) --> [].

'@drep_from_interval'({}) --> [].
'@drep_from_interval'({Is0}) -->
    { phrase(drep_iand(Is0), Is1), goals_goal(',', Is1, Is) },
    [{Is}].
'@drep_from_interval'(F..T) --> [F..T].

'@drep_from_intervals'(DRs) -->
    foldl('@drep_from_interval', DRs, {}, DR),
    '@drep_from_interval'(DR).

'@drep_union'(DR0, DR1, DR1\/DR0).

drep_from_intervals([], {}).
drep_from_intervals([I|Is], DR) :-
    list_map('@drep_from_interval', [I|Is], DRs0),
    phrase('@drep_from_intervals'(DRs0), [DR0|DRs]),
    list_foldl('@drep_union', DRs, DR0, DR).

drep_to_intervals(DR, Is) :-
    phrase('@drep_to_intervalss'(DR), Iss),
    list_foldl(intervals_union, Iss, [], Is).

% '@drep_to_intervalss'(I) --> { integer(I) }, [[n(I)-n(I)]].
'@drep_to_intervalss'(F0..T0) -->
    {   bound_from_defaulty(F0, F),
        bound_from_defaulty(T0, T),
        F cis_le T
    },
    [[F-T]].
'@drep_to_intervalss'(DR0\/DR1) -->
    '@drep_to_intervalss'(DR0), '@drep_to_intervalss'(DR1).
'@drep_to_intervalss'(\DR) -->
    {   phrase('@drep_to_intervalss'(DR), Iss),
        list_foldl(intervals_union, Iss, [], Is0),
        intervals_diff(Is0, [inf-sup], Is)
    },
    [Is].
'@drep_to_intervalss'({}) --> [].
'@drep_to_intervalss'({AI}) --> '@drep_and_integers'(AI).

'@drep_and_integers'(I) --> { integer(I) }, [[n(I)-n(I)]].
'@drep_and_integers'((A,B)) -->
    '@drep_and_integers'(A), '@drep_and_integers'(B).

drep_from_domain(D, DR) :-
    domain_to_intervals(D, Is),
    drep_from_intervals(Is, DR).

drep_to_domain(DR, D) :-
    phrase('@drep_to_intervalss'(DR), Iss),
    list_foldl(intervals_union, Iss, [], Is),
    domain_from_intervals(Is, D).
