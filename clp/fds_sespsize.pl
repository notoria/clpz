/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   fds_sespsize(Vs, S).

   S is an upper bound on the search space size with respect to finite
   domain variables Vs.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

fds_sespsize(Vs, S) :-
        must_be(list, Vs),
        maplist(fd_variable, Vs),
        fds_sespsize(Vs, n(1), S1),
        bound_portray(S1, S).

fd_size_(V, S) :-
        (   fd_get(V, D, _) ->
            domain_num_elements(D, S)
        ;   S = n(1)
        ).

fds_sespsize([], S, S).
fds_sespsize([V|Vs], S0, S) :-
        fd_size_(V, S1),
        S2 cis S0*S1,
        fds_sespsize(Vs, S2, S).
