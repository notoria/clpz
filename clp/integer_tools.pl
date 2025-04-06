even(N) :- N mod 2 =:= 0.

odd(N) :- \+ even(N).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   k-th root of N, if N is a k-th power.

   TODO: Replace this when the GMP function becomes available.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

integer_kth_root(N, K, R) :-
        (   even(K) ->
            N >= 0
        ;   true
        ),
        (   K < 0 ->
            (   N =:= 1 -> R = 1
            ;   N =:= -1 -> odd(K), R = -1
            ;   false
            )
        ;   (   N < 0 ->
                odd(K),
                integer_kroot(N, 0, N, K, R)
            ;   integer_kroot(0, N, N, K, R)
            )
        ).

integer_kroot(L, U, N, K, R) :-
        (   L =:= U -> N =:= L^K, R = L
        ;   L + 1 =:= U ->
            (   L^K =:= N -> R = L
            ;   U^K =:= N -> R = U
            ;   false
            )
        ;   Mid is (L + U)//2,
            (   Mid^K > N ->
                integer_kroot(L, Mid, N, K, R)
            ;   integer_kroot(Mid, U, N, K, R)
            )
        ).

integer_log_b(N, B, Log0, Log) :-
        T is B^Log0,
        (   T =:= N -> Log = Log0
        ;   T < N,
            Log1 is Log0 + 1,
            integer_log_b(N, B, Log1, Log)
        ).

floor_integer_log_b(N, B, Log0, Log) :-
        T is B^Log0,
        (   T > N -> Log is Log0 - 1
        ;   T =:= N -> Log = Log0
        ;   T < N,
            Log1 is Log0 + 1,
            floor_integer_log_b(N, B, Log1, Log)
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Largest R such that R^K =< N.

   TODO: Replace this when the GMP function becomes available.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

integer_kth_root_leq(N, K, R) :-
        (   even(K) ->
            N >= 0
        ;   true
        ),
        (   N < 0 ->
            odd(K),
            integer_kroot_leq(N, 0, N, K, R)
        ;   integer_kroot_leq(0, N, N, K, R)
        ).

integer_kroot_leq(L, U, N, K, R) :-
        (   L =:= U -> R = L
        ;   L + 1 =:= U ->
            (   U^K =< N -> R = U
            ;   R = L
            )
        ;   Mid is (L + U)//2,
            (   Mid^K > N ->
                integer_kroot_leq(L, Mid, N, K, R)
            ;   integer_kroot_leq(Mid, U, N, K, R)
            )
        ).
