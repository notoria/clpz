/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Compactified `(is)/2` and predicates for several arithmetic expressions
   with infinities, tailored for the modes needed by this solver.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

% cis_compare(_, A, B) :-
%     member(C, [A,B]),
%     % var(C),
%     % throw(error(instantiation_error,cis_compare/3)).
%     \+ bound(C),
%     throw(error(domain_error(bound,C),cis_compare/3)).
cis_compare(_, A, B) :-
    var(A),
    var(B),
    throw(error(instantiation_error,cis_compare/3)).
cis_compare(_, A, B) :-
    var(A),
    bound(B),
    throw(error(instantiation_error,cis_compare/3)).
cis_compare(_, A, B) :-
    bound(A),
    var(B),
    throw(error(instantiation_error,cis_compare/3)).
cis_compare(=, inf, inf). % Extension
cis_compare(<, inf, n(_)).
cis_compare(<, inf, sup).
cis_compare(>, n(_), inf).
cis_compare(O, n(A), n(B)) :-
    compare(O, A, B).
cis_compare(<, n(_), sup).
cis_compare(>, sup, inf).
cis_compare(>, sup, n(_)).
cis_compare(=, sup, sup). % Extension

'@cis_compare'(>, A, B, B, A).
'@cis_compare'(=, A, A, A, A).
'@cis_compare'(<, A, B, A, B).

cis_compare(R, A0, B0, A, B) :-
    cis_compare(R, A0, B0),
    '@cis_compare'(R, A0, B0, A, B).

cis_lt(A, B) :- cis_compare(<, A, B).

'@cis_le'(=).
'@cis_le'(<).

cis_le(A, B) :- cis_compare(O, A, B), '@cis_le'(O).

'@cis_ge'(>).
'@cis_ge'(=).

cis_ge(A, B) :- cis_compare(O, A, B), '@cis_ge'(O).

cis_gt(A, B) :- cis_compare(>, A, B).

cis_min(A, B, C) :- cis_compare(_, A, B, C, _).

cis_max(A, B, C) :- cis_compare(_, A, B, _, C).

cis_add(inf, inf, inf).
cis_add(inf, n(_), inf).
cis_add(n(_), inf, inf).
cis_add(n(A), n(B), n(C)) :- integer_add(A, B, C). % C #= A+B.
cis_add(n(_), sup, sup).
cis_add(sup, n(_), sup).
cis_add(sup, sup, sup).

cis_sub(A, B0, C) :-
    cis_neg(B0, B),
    cis_add(A, B, C).

cis_neg(inf, sup).
cis_neg(n(A), n(B)) :- integer_neg(A, B). % B #= -A.
cis_neg(sup, inf).

cis_abs(inf, sup).
cis_abs(n(A), n(B)) :- integer_abs(A, B). % B #= abs(A).
cis_abs(sup, sup).

cis_mul(inf, B, C) :-
    cis_compare(R, n(0), B),
    cis_mul_inf(R, C).
cis_mul(n(A), inf, C) :-
    cis_compare(R, n(0), n(A)),
    cis_mul_inf(R, C).
cis_mul(n(A), n(B), n(C)) :-
    integer_mul(A, B, C). % C #= A*B.
cis_mul(n(A), sup, C) :-
    cis_compare(R, n(0), n(A)),
    cis_mul_sup(R, C).
cis_mul(sup, B, C) :-
    cis_compare(R, n(0), B),
    cis_mul_sup(R, C).

cis_mul_inf(<, inf).
cis_mul_inf(=, n(0)). % Extension
cis_mul_inf(>, sup).

cis_mul_sup(<, sup).
cis_mul_sup(=, n(0)). % Extension
cis_mul_sup(>, inf).

cis_exp(inf, n(B), C) :- % Undefined Behavior if negative
    B @>= 0,
    integer_sgn(B, R0), % R0 #= sign(B),
    integer_ddqr(floor, B, 2, T0, _), integer_mul(2, T0, T1), integer_add(-1, T1, R1), % R1 #= 2*(B mod 2)-1,
    cis_mul(inf, n(R1), C0),
    cis_mul(n(R0), C0, C1),
    cis_add(n(1), C1, C).
cis_exp(n(A), n(B), n(C)) :- % Undefined Behavior if negative
    integer_exp(A, B, C). % C #= A^B.
cis_exp(n(1), inf, n(1)).
cis_exp(n(A), sup, sup) :-
    A @> 1.
cis_exp(n(1), sup, n(1)).
cis_exp(n(0), sup, n(0)).
cis_exp(sup, n(B), C) :- % Undefined Behavior if negative
    B @>= 0,
    integer_sgn(B, R0), % R0 #= sign(B),
    cis_mul(sup, n(R0), C0),
    cis_add(n(1), C0, C).
cis_exp(sup, sup, sup).

cis_sign(inf, n(-1)).
cis_sign(n(A), n(B)) :- integer_sgn(A, B). % B #= sign(A).
cis_sign(sup, n(1)).

cis_div(inf, n(B), C) :-
    cis_compare(R, n(0), n(B)),
    cis_div_inf(R, C).
cis_div(n(_), inf, n(0)).
% cis_div(n(A), n(B), C) :-
%     cis_compare(R, n(0), n(B)),
%     cis_div_num(R, A, B, C).
cis_div(n(A), n(B), n(C)) :-
    \+ cis_compare(=, n(0), n(B)),
    integer_ddqr(floor, A, B, C, _). % C #= A div B.
cis_div(n(_), sup, n(0)).
cis_div(sup, n(B), C) :-
    cis_compare(R, n(0), n(B)),
    cis_div_sup(R, C).

cis_div_inf(<, inf).
% cis_div_inf(=, inf). % stable
cis_div_inf(>, sup).

cis_div_num(<, A, B, n(C)) :-
    integer_ddqr(floor, A, B, C, _). % C #= A div B.
% cis_div_num(=, A, 0, C) :-
%     \+ cis_compare(=, n(0), A),
%     cis_mul(sup, A, C).
cis_div_num(>, A, B, n(C)) :-
    integer_ddqr(floor, A, B, C, _). % C #= A div B.

cis_div_sup(<, sup).
% cis_div_sup(=, sup). % stable
cis_div_sup(>, inf).

cis_slash(inf, n(B), C) :-
    cis_compare(R, n(0), n(B)),
    cis_slash_inf(R, C).
cis_slash(n(_), inf, n(0)).
% cis_slash(n(A), n(B), C) :-
%     cis_compare(R, n(0), n(B)),
%     cis_slash_num(R, A, B, C).
cis_slash(n(A), n(B), n(C)) :-
    \+ cis_compare(=, n(0), n(B)),
    integer_ddqr(trunc, A, B, C, _). % C #= A//B.
cis_slash(n(_), sup, n(0)).
cis_slash(sup, n(B), C) :-
    cis_compare(R, n(0), n(B)),
    cis_slash_sup(R, C).

cis_slash_inf(<, inf).
% cis_slash_inf(=, inf). % stable
cis_slash_inf(>, sup).

cis_slash_sup(<, sup).
% cis_slash_sup(=, sup). % stable
cis_slash_sup(>, inf).

cis(_, E) :-
    var(E),
    throw(error(instantiation_error,(cis)/2)).
cis(E, inf) :-
    E = inf.
cis(E, n(N)) :-
    integer(N),
    E = n(N).
cis(E, sup) :-
    E = sup.
cis(E, sign(E0)) :-
    cis(E1, E0),
    cis_sign(E1, E).
cis(E, abs(E0)) :-
    cis(E1, E0),
    cis_abs(E1, E).
cis(E, -E0) :-
    cis(E1, E0),
    cis_neg(E1, E).
cis(E, E0+E1) :-
    cis(E2, E0),
    cis(E3, E1),
    cis_add(E2, E3, E).
cis(E, E0-E1) :-
    cis(E2, E0),
    cis(E3, E1),
    cis_sub(E2, E3, E).
cis(E, min(E0,E1)) :-
    cis(E2, E0),
    cis(E3, E1),
    cis_min(E2, E3, E).
cis(E, max(E0,E1)) :-
    cis(E2, E0),
    cis(E3, E1),
    cis_max(E2, E3, E).
cis(E, E0*E1) :-
    cis(E2, E0),
    cis(E3, E1),
    cis_mul(E2, E3, E).
cis(E, E0 div E1) :-
    cis(E2, E0),
    cis(E3, E1),
    cis_div(E2, E3, E).
cis(E, E0//E1) :-
    cis(E2, E0),
    cis(E3, E1),
    cis_slash(E2, E3, E).
cis(E, E0^E1) :-
    cis(E2, E0),
    cis(E3, E1),
    cis_exp(E2, E3, E).

% cis(A, B) :-
%     phrase(cis_goals(B, A), Goals),
%     list_map(call, Goals).

% cis_goals(V, _)          --> { var(V), !, instantiation_error(V) }.
% cis_goals(E, R)          --> { var(E) }, !, [R cis E].
cis_goals(inf, inf)      --> [].
cis_goals(n(N), R)       --> { integer(N), R = n(N) }.
cis_goals(sup, sup)      --> [].
cis_goals(sign(A0), R)   --> cis_goals(A0, A), [cis_sign(A, R)].
cis_goals(abs(A0), R)    --> cis_goals(A0, A), [cis_abs(A, R)].
cis_goals(-A0, R)        --> cis_goals(A0, A), [cis_neg(A, R)].
cis_goals(A0+B0, R)      -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_add(A, B, R)].
cis_goals(A0-B0, R)      -->
        cis_goals(A0, A),
        cis_goals(B0, B),
        [cis_sub(A, B, R)].
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
        [cis_mul(A, B, R)].
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

goal_expansion(
    cis(R, E),
    (call(cis(R0, E)) -> R = R0 ; throw(error(cis_error(E),(cis)/2)))
).

% goal_expansion(A cis B, Expansion) :-
%         phrase(cis_goals(B, A), Goals),
%         goals_goal(',', Goals, Expansion).
