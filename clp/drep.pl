/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A drep is a user-accessible and visible domain representation. N,
   N..M, and D1 \/ D2 are dreps, if D1 and D2 are dreps.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

is_drep(N)      :- integer(N).
is_drep(N..M)   :- drep_bound(N), drep_bound(M), N \== sup, M \== inf.
is_drep(D1\/D2) :- is_drep(D1), is_drep(D2).
is_drep({AI})   :- is_and_integers(AI).
is_drep(\D)     :- is_drep(D).

is_and_integers(I)     :- integer(I).
is_and_integers((A,B)) :- is_and_integers(A), is_and_integers(B).

drep_bound(I)   :- integer(I).
drep_bound(sup).
drep_bound(inf).

drep_to_intervals(I)        --> { integer(I) }, [n(I)-n(I)].
drep_to_intervals(N..M)     -->
        (   { defaulty_to_bound(N, N1), defaulty_to_bound(M, M1),
              N1 cis_leq M1} -> [N1-M1]
        ;   []
        ).
drep_to_intervals(D1 \/ D2) -->
        drep_to_intervals(D1), drep_to_intervals(D2).
drep_to_intervals(\D0) -->
        { drep_to_domain(D0, D1),
          domain_complement(D1, D),
          domain_to_drep(D, Drep) },
        drep_to_intervals(Drep).
drep_to_intervals({AI}) -->
        and_integers_(AI).

and_integers_(I)     --> { integer(I) }, [n(I)-n(I)].
and_integers_((A,B)) --> and_integers_(A), and_integers_(B).

drep_to_domain(DR, D) :-
        must_be(ground, DR),
        (   is_drep(DR) -> true
        ;   domain_error(clpz_domain, DR)
        ),
        phrase(drep_to_intervals(DR), Is0),
        merge_intervals(Is0, Is1),
        intervals_to_domain(Is1, D).

merge_intervals(Is0, Is) :-
        keysort(Is0, Is1),
        merge_overlapping(Is1, Is).

merge_overlapping([], []).
merge_overlapping([A-B0|ABs0], [A-B|ABs]) :-
        merge_remaining(ABs0, B0, B, Rest),
        merge_overlapping(Rest, ABs).

merge_remaining([], B, B, []).
merge_remaining([N-M|NMs], B0, B, Rest) :-
        Next cis B0 + n(1),
        (   N cis_gt Next -> B = B0, Rest = [N-M|NMs]
        ;   B1 cis max(B0,M),
            merge_remaining(NMs, B1, B, Rest)
        ).

domain(V, Dom) :-
        (   fd_get(V, Dom0, VPs) ->
            domains_intersection(Dom, Dom0, Dom1),
            %format("intersected\n: ~w\n ~w\n==> ~w\n\n", [Dom,Dom0,Dom1]),
            fd_put(V, Dom1, VPs),
            reinforce(V)
        ;   domain_contains(Dom, V)
        ).

domains([], _).
domains([V|Vs], D) :- domain(V, D), domains(Vs, D).
