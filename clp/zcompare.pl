%% zcompare(?Order, ?A, ?B)
%
% Analogous to compare/3, with finite domain variables A and B.
%
% This predicate allows you to make several predicates over integers
% deterministic while preserving their generality and completeness.
% For example:
%
% ```
% n_factorial(N, F) :-
%         zcompare(C, N, 0),
%         n_factorial_(C, N, F).
%
% n_factorial_(=, _, 1).
% n_factorial_(>, N, F) :-
%         F #= F0*N, N1 #= N - 1,
%         n_factorial(N1, F0).
% ```
%
% This version is deterministic if the first argument is instantiated,
% because first argument indexing can distinguish the two different
% clauses:
%
% ```
% ?- n_factorial(30, F).
%    F = 265252859812191058636308480000000.
% ```
%
% The predicate can still be used in all directions, including the
% most general query:
%
% ```
% ?- n_factorial(N, F).
%    N = 0, F = 1
% ;  N = 1, F = 1
% ;  N = 2, F = 2
% ;  ... .
% ```

zcompare(Order, A, B) :-
        (   nonvar(Order) ->
            zcompare_(Order, A, B)
        ;   integer(A), integer(B) ->
            compare(Order, A, B)
        ;   freeze(Order, zcompare_(Order, A, B)),
            fd_variable(A),
            fd_variable(B),
            propagator_init_trigger([A,B], pzcompare(Order, A, B))
        ).

zcompare_(O, A, B) :-
        (   member(O, "<=>") -> true
        ;   domain_error(order, O, zcompare/3)
        ),
        zcompare__(O, A, B).

zcompare__(=, A, B) :- #A #= #B.
zcompare__(<, A, B) :- #A #< #B.
zcompare__(>, A, B) :- #A #> #B.
