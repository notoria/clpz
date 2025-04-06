% goal_expansion(A cis B, Expansion) :-
%         phrase(cis_goals(B, A), Goals),
%         list_goal(Goals, Expansion).
% goal_expansion(A cis_lt B, B cis_gt A).
% goal_expansion(A cis_leq B, B cis_geq A).
% goal_expansion(A cis_geq B, cis_leq_numeric(B, N)) :- nonvar(A), A = n(N).
% goal_expansion(A cis_geq B, cis_geq_numeric(A, N)) :- nonvar(B), B = n(N).
% goal_expansion(A cis_gt B, cis_lt_numeric(B, N))   :- nonvar(A), A = n(N).
% goal_expansion(A cis_gt B, cis_gt_numeric(A, N))   :- nonvar(B), B = n(N).

A cis B :-
    phrase(cis_goals(B, A), Goals),
    list_goal(Goals, Expansion),
    call(Expansion).
A cis_lt B :-
    B cis_gt A.
A cis_leq B :-
    B cis_geq A.
% Defined elsewhere.
% A cis_geq B :-
%      nonvar(A), A = n(N),
%      cis_leq_numeric(B, N).
% A cis_geq B :-
%     nonvar(B), B = n(N),
%     cis_geq_numeric(A, N).
% A cis_gt B :-
%     nonvar(A), A = n(N),
%     cis_lt_numeric(B, N).
% A cis_gt B :-
%     nonvar(B), B = n(N),
%     cis_gt_numeric(A, N).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A bound is either:

   n(N):    integer N
   inf:     infimum of Z (= negative infinity)
   sup:     supremum of Z (= positive infinity)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

is_bound(n(N)) :- integer(N).
is_bound(inf).
is_bound(sup).

defaulty_to_bound(D, P) :- ( integer(D) -> P = n(D) ; P = D ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Compactified is/2 and predicates for several arithmetic expressions
   with infinities, tailored for the modes needed by this solver.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

% cis_gt only works for terms of depth 0 on both sides
cis_gt(sup, B0) :- B0 \== sup.
cis_gt(n(N), B) :- cis_lt_numeric(B, N).

cis_lt_numeric(inf, _).
cis_lt_numeric(n(B), A) :- B < A.

cis_gt_numeric(sup, _).
cis_gt_numeric(n(B), A) :- B > A.

cis_geq(inf, inf).
cis_geq(sup, _).
cis_geq(n(N), B) :- cis_leq_numeric(B, N).

cis_leq_numeric(inf, _).
cis_leq_numeric(n(B), A) :- B =< A.

cis_geq_numeric(sup, _).
cis_geq_numeric(n(B), A) :- B >= A.

cis_min(inf, _, inf).
cis_min(sup, B, B).
cis_min(n(N), B, Min) :- cis_min_(B, N, Min).

cis_min_(inf, _, inf).
cis_min_(sup, N, n(N)).
cis_min_(n(B), A, n(M)) :- M is min(A,B).

cis_max(sup, _, sup).
cis_max(inf, B, B).
cis_max(n(N), B, Max) :- cis_max_(B, N, Max).

cis_max_(inf, N, n(N)).
cis_max_(sup, _, sup).
cis_max_(n(B), A, n(M)) :- M is max(A,B).

cis_plus(inf, _, inf).
cis_plus(sup, _, sup).
cis_plus(n(A), B, Plus) :- cis_plus_(B, A, Plus).

cis_plus_(sup, _, sup).
cis_plus_(inf, _, inf).
cis_plus_(n(B), A, n(S)) :- S is A + B.

cis_minus(inf, _, inf).
cis_minus(sup, _, sup).
cis_minus(n(A), B, M) :- cis_minus_(B, A, M).

cis_minus_(inf, _, sup).
cis_minus_(sup, _, inf).
cis_minus_(n(B), A, n(M)) :- M is A - B.

cis_uminus(inf, sup).
cis_uminus(sup, inf).
cis_uminus(n(A), n(B)) :- B is -A.

cis_abs(inf, sup).
cis_abs(sup, sup).
cis_abs(n(A), n(B)) :- B is abs(A).

cis_times(inf, B, P) :-
        (   B cis_lt n(0) -> P = sup
        ;   B cis_gt n(0) -> P = inf
        ;   P = n(0)
        ).
cis_times(sup, B, P) :-
        (   B cis_gt n(0) -> P = sup
        ;   B cis_lt n(0) -> P = inf
        ;   P = n(0)
        ).
cis_times(n(N), B, P) :- cis_times_(B, N, P).

cis_times_(inf, A, P)     :- cis_times(inf, n(A), P).
cis_times_(sup, A, P)     :- cis_times(sup, n(A), P).
cis_times_(n(B), A, n(P)) :- P is A * B.

cis_exp(inf, n(Y), R) :-
        (   even(Y) -> R = sup
        ;   R = inf
        ).
cis_exp(sup, _, sup).
cis_exp(n(N), Y, R) :- cis_exp_(Y, N, R).

cis_exp_(n(Y), N, n(R)) :- R is N^Y.
cis_exp_(sup, _, sup).
cis_exp_(inf, _, inf).

cis_goals(V, _)          --> { var(V), !, instantiation_error(V) }.
cis_goals(n(N), n(N))    --> [].
cis_goals(inf, inf)      --> [].
cis_goals(sup, sup)      --> [].
cis_goals(sign(A0), R)   --> cis_goals(A0, A), [cis_sign(A, R)].
cis_goals(abs(A0), R)    --> cis_goals(A0, A), [cis_abs(A, R)].
cis_goals(-A0, R)        --> cis_goals(A0, A), [cis_uminus(A, R)].
cis_goals(A0+B0, R)      -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_plus(A, B, R)].
cis_goals(A0-B0, R)      -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_minus(A, B, R)].
cis_goals(min(A0,B0), R) -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_min(A, B, R)].
cis_goals(max(A0,B0), R) -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_max(A, B, R)].
cis_goals(A0*B0, R)      -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_times(A, B, R)].
cis_goals(div(A0,B0), R) -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_div(A, B, R)].
cis_goals(A0//B0, R)     -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_slash(A, B, R)].
cis_goals(A0^B0, R)      -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_exp(A, B, R)].

list_goal([], true).
list_goal([G|Gs], Goal) :- foldl(list_goal_, Gs, G, Goal).

list_goal_(G, G0, (G0,G)).

cis_sign(sup, n(1)).
cis_sign(inf, n(-1)).
cis_sign(n(N), n(S)) :- S is sign(N).

cis_div(sup, Y, Z)  :- ( Y cis_geq n(0) -> Z = sup ; Z = inf ).
cis_div(inf, Y, Z)  :- ( Y cis_geq n(0) -> Z = inf ; Z = sup ).
cis_div(n(X), Y, Z) :- cis_div_(Y, X, Z).

cis_div_(sup, _, n(0)).
cis_div_(inf, _, n(0)).
cis_div_(n(Y), X, Z) :-
        (   Y =:= 0 -> (  X >= 0 -> Z = sup ; Z = inf )
        ;   Z0 is X // Y, Z = n(Z0)
        ).

cis_slash(sup, _, sup).
cis_slash(inf, _, inf).
cis_slash(n(N), B, S) :- cis_slash_(B, N, S).

cis_slash_(sup, _, n(0)).
cis_slash_(inf, _, n(0)).
cis_slash_(n(B), A, n(S)) :- S is A // B.
