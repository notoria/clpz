% Ordines
%:- include("../../ordines/z").

% SICStus
:- include("../utils").
:- include("../integer").
:- include("../../sicstus/compatibility").
:- use_module('../../sicstus/call_nth').
% sicstus -f -l env/sicstus/iso.pl -l env/sicstus/z.pl -l env/clp/test/answer.pl

map(_G__2, [], []) --> [].
map(G__2, [E0|Es0], [E|Es]) --> call(G__2, E0, E), map(G__2, Es0, Es).

equations(X, Y) --> call('@equations'(X, Y)).

'@equations'(X, Y, Eqs0, Eqs) :-
    phrase('@equations'(Eqs0, X, Y), Eqs0, Eqs).

'@equations'(Eqs0, X, Y) -->
    (   { X == Y }
    ->  []
    ;   { nonvar(X), nonvar(Y) }
    ->  {   functor(X, N, A), functor(Y, N, A),
            X =.. [N|Xs0], Y =.. [N|Ys0]
        },
        map('@equations'(Eqs0), Xs0, Ys0)
    ;   { list_element([X=Y,Y=X], Eq), \+ list_map(\==(Eq), Eqs0) }
    ->  []
    ;   [X=Y]
    ).

variant(T, U) :-
    copy_term(T, T0),
    subsumes_term(T0, U),
    subsumes_term(U, T0).

unfold_conjunction(G) -->
    (   { G == true }
    ->  []
    ;   { \+ subsumes_term((_,_), G) }
    ->  [G]
    ;   { G = (G0,G1) },
        unfold_conjunction(G0),
        unfold_conjunction(G1)
    ).

'@answer'(G, Gs) :-
    (   G \= [],
        G \= [_|_]
    ->  phrase(unfold_conjunction(G), Gs)
    ;   Gs = G
    ).

answer(E, Vs, Gs) :-
    copy_term(E, F, Gs0),
    '@answer'(Gs0, Gs1),
    term_variables(F+Gs0, Vs),
    Gs = Gs1.

permutation(Es0, Es) :-
    list_equisized(Es0, Es),
    list_foldl(list_select, Es, Es0, []).

expr(s(#E,L), s(E,L)) --> [].
expr(s(E0+E1,L0), s(E,L)) -->
    { succ(L1, L0) },
    expr(s(E0,L1), s(E2,L2)),
    expr(s(E1,L2), s(E3,L)),
    [#E2+ #E3#= #E].
% expr(s(E0-E1,L0), s(E,L)) -->
%     { succ(L1, L0) },
%     expr(s(E0,L1), s(E2,L2)),
%     expr(s(E1,L2), s(E3,L)),
%     [#E2- #E3#= #E].
expr(s(E0*E1,L0), s(E,L)) -->
    { succ(L1, L0) },
    expr(s(E0,L1), s(E2,L2)),
    expr(s(E1,L2), s(E3,L)),
    [#E2* #E3#= #E].
expr(s(E0^E1,L0), s(E,L)) -->
    { succ(L1, L0) },
    expr(s(E0,L1), s(E2,L2)),
    expr(s(E1,L2), s(E3,L)),
    [#E2^ #E3#= #E].
expr(s(min(E0,E1),L0), s(E,L)) -->
    { succ(L1, L0) },
    expr(s(E0,L1), s(E2,L2)),
    expr(s(E1,L2), s(E3,L)),
    [min(#E2,#E3)#= #E].
expr(s(max(E0,E1),L0), s(E,L)) -->
    { succ(L1, L0) },
    expr(s(E0,L1), s(E2,L2)),
    expr(s(E1,L2), s(E3,L)),
    [max(#E2,#E3)#= #E].
% expr(s(E0 div E1,L0), s(E,L)) -->
%     { succ(L1, L0) },
%     expr(s(E0,L1), s(E2,L2)),
%     expr(s(E1,L2), s(E3,L)),
%     [#E2 div #E3#= #E].
expr(s(E0 mod E1,L0), s(E,L)) -->
    { succ(L1, L0) },
    expr(s(E0,L1), s(E2,L2)),
    expr(s(E1,L2), s(E3,L)),
    [#E2 mod #E3#= #E].
% expr(s(-E0,L0), s(E,L)) -->
%     { succ(L1, L0) },
%     expr(s(E0,L1), s(E1,L)),
%     [- #E1#= #E].
expr(s(abs(E0),L0), s(E,L)) -->
    { succ(L1, L0) },
    expr(s(E0,L1), s(E1,L)),
    [abs(#E1)#= #E].
expr(s(sign(E0),L0), s(E,L)) -->
    { succ(L1, L0) },
    expr(s(E0,L1), s(E1,L)),
    [sign(#E1)#= #E].
% expr(s(xor(E0,E1),L0), s(E,L)) -->
%     { succ(L1, L0) },
%     expr(s(E0,L1), s(E2,L2)),
%     expr(s(E1,L2), s(E3,L)),
%     [xor(#E2,#E3)#= #E].

expr(#E, L, L) --> [E].
expr(E0+E1, L0, L) -->
    { succ(L1, L0) },
    expr(E0, L1, L2),
    expr(E1, L2,  L).
% expr(E0-E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
expr(E0*E1, L0, L) -->
    { succ(L1, L0) },
    expr(E0, L1, L2),
    expr(E1, L2,  L).
% expr(E0^E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(min(E0,E1), L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(max(E0,E1), L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(E0 div E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(E0 mod E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(E0 // E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(E0 rem E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(-E0, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1,  L).
% expr(abs(E0), L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1,  L).
% expr(sign(E0), L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1,  L).
% expr(E0>>E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(E0<<E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(E0/\E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(E0\/E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(xor(E0,E1), L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(\E0, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1,  L).
% expr(lsb(E0), L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1,  L).
% expr(msb(E0), L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1,  L).
% expr(popcount(E0), L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1,  L).

'@variation'(Vs0-Gs0, Vs-Gs) :-
    list_equisized(Vs0, Vs),
    list_equisized(Gs0, Gs),
    permutation(Vs0, Vs1),
    variant(Vs1, Vs),
    Vs = Vs1,
    permutation(Gs0, Gs1),
    Gs == Gs1.

variation([]).
variation([VGs|VGss]) :-
    list_map('@variation'(VGs), VGss),
    variation(VGss).

test_answer(M) :-
    % foldl(succ, 0, D),
    integer_between(0, 2, D),
    test_answer(D, M).

test_answer(D, M) :-
    portray_clause(user_error, depth(D)),
    integer_abs(M, U),
    integer_neg(U, L),
    % phrase(expr(E0, D, 0), Vs0, [V0]), E = (#V0#=E0),
    phrase(expr(s(E0,D), s(V0,0)), Eqs0), E = (E0#= #V0),
    once((\+subsumes_term((_^_)^_, E0), \+subsumes_term(_^(_^_), E0))),
    term_variables(E, Vs0),
    portray_clause(user_error, E),
    list_split(Vs0, _, Vs),
    \+ list_equisized(Vs0, Vs),
    list_equisized(Vs, Is),
    list_map(between(L,U), Is),
    phrase(equations(Vs, Is), Eqs1),
    findall(
        Ws-Gs,
        (   permutation([E|Eqs1], Eqs),
            list_map(call, Eqs),
            Vs0 ins inf..sup,
            Vs0 ins inf..sup,
            % list_map(call, Eqs0),
            \+ ground(E),
            answer(E+Eqs0, Ws, Gs)
        ),
        WGss
    ),
    WGss \= [],
    \+ variation(WGss),
    list_length(WGss, N),
    portray_clause(user_error, [Vs0,E,Eqs1]),
    portray_clause(user_error, N-WGss),
    halt.
