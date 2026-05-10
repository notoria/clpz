% Ordines
% :- include("../../ordines/z").

% SICStus
:- include("../utils").
:- include("../integer").
:- include("../../sicstus/compatibility").
:- use_module('../../sicstus/call_nth').
% sicstus -f -l env/sicstus/iso.pl -l env/sicstus/z.pl -l env/clp/test/expr.pl

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

alleq([]).
alleq([A|As]) :-
    list_split(As, Bs, Cs),
    list_map(=(A), Bs),
    alleq(Cs).

alleq([], []).
alleq([A|As], [A|Vs]) :-
    list_split(As, Bs, Cs),
    list_map(=(A), Bs),
    alleq(Cs, Vs).

expr(s(E0,L), s(E,L)) --> { var(E0), E = E0 }.
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
% expr(s(sign(E0),L0), s(E,L)) -->
%     { succ(L1, L0) },
%     expr(s(E0,L1), s(E1,L)),
%     [sign(#E1)#= #E].
% expr(s(xor(E0,E1),L0), s(E,L)) -->
%     { succ(L1, L0) },
%     expr(s(E0,L1), s(E2,L2)),
%     expr(s(E1,L2), s(E3,L)),
%     [xor(#E2,#E3)#= #E].

expr(#E, L, L) --> [E].
% expr(E0+E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
% expr(E0-E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
expr(E0*E1, L0, L) -->
    { succ(L1, L0) },
    expr(E0, L1, L2),
    expr(E1, L2,  L).
expr(E0^E1, L0, L) -->
    { succ(L1, L0) },
    expr(E0, L1, L2),
    expr(E1, L2,  L).
expr(min(E0,E1), L0, L) -->
    { succ(L1, L0) },
    expr(E0, L1, L2),
    expr(E1, L2,  L).
expr(max(E0,E1), L0, L) -->
    { succ(L1, L0) },
    expr(E0, L1, L2),
    expr(E1, L2,  L).
% expr(E0 div E1, L0, L) -->
%     { succ(L1, L0) },
%     expr(E0, L1, L2),
%     expr(E1, L2,  L).
expr(E0 mod E1, L0, L) -->
    { succ(L1, L0) },
    expr(E0, L1, L2),
    expr(E1, L2,  L).
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
expr(abs(E0), L0, L) -->
    { succ(L1, L0) },
    expr(E0, L1,  L).
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

pfml(#B, L, L) -->
    { B in 0..1 },
    [B].
pfml(#\P0, L0, L) -->
    { succ(L1, L0) },
    pfml(P0, L1,  L).
pfml(P0#/\P1, L0, L) -->
    { succ(L1, L0) },
    pfml(P0, L1, L2),
    pfml(P1, L2,  L).
pfml(P0#\/P1, L0, L) -->
    { succ(L1, L0) },
    pfml(P0, L1, L2),
    pfml(P1, L2,  L).
pfml(P0#<==>P1, L0, L) -->
    { succ(L1, L0) },
    pfml(P0, L1, L2),
    pfml(P1, L2,  L).
% pfml(P0#==>P1, L0, L) -->
%     { succ(L1, L0) },
%     pfml(P0, L1, L2),
%     pfml(P1, L2,  L).

test_armt(M) :-
    integer_between(0, 2, N),
    test_armt(N, M).

test_armt(N, M) :-
    integer_abs(M, U),
    integer_neg(U, L),
    G_1 = between(L, U),
    % foldl(integer_add(1), 0, N), portray_clause(user_error, N),
    % E0 = (_^(_*_)), %
    phrase(expr(s(E0,N), s(E,0)), Es0, Es1),
    % subsumes_term(E0, (_^(_*_))), %
    once((\+subsumes_term((_^_)^_, E0), \+subsumes_term(_^(_^_), E0))),
    portray_clause(user_error, E0 #= E),
    copy_term(E0+E, F0+F),
    phrase(equations(E0, F0), Es1, [E=F]),
    % (once(list_element(Es0, max(_,_)#=_)) ; once(list_element(Es0, min(_,_)#=_))),
    list_equisized(Es0, Es),
    term_variables(F0, Vs),
    list_map(G_1, Vs),
    % portray_clause(user_error, Es0), %
    catch(F is F0, _, test_failure((true ; call(G_1, F)), Es0, Es)),
    test_success(Es0, Es).

test_failure(G_0, Es0, Es) :-
    call(G_0),
    list_foldl(list_select, Es, Es0, []),
    \+ \+ catch(list_map(call, Es), _, true),
    portray_clause(user_output, false-Es),
    halt.

test_success(Es0, Es) :-
    list_foldl(list_select, Es, Es0, []),
    \+ catch(list_map(call, Es), _, false),
    portray_clause(user_output, true-Es),
    halt.

test_pfml :-
    foldl(integer_add(1), 0, L),
    phrase(pfml(E, L, 0), Vs),
    B in 0..1,
    portray_clause(user_output, E),
    alleq(Vs),
    term_variables([B|Vs], Ws0),
    list_equisized(Ws0, Ws),
    list_foldl(list_select, Ws, Ws0, []),
    findall(Ws-E, (E #<==> #B, list_map(between(0,1), Ws)), Es0),
    findall(Ws-E, (list_map(between(0,1), Ws), E #<==> #B), Es1),
    \+ list_equisized(Es0, Es1),
    portray_clause(user_output, [E,Es0,Es1]),
    halt.

test_pfml(M) :-
    integer_between(0, 2, N),
    test_pfml(N, M).

test_pfml(D, M) :-
    portray_clause(user_error, depth(D)),
    integer_abs(M, U),
    integer_neg(U, L),
    G_1 = between(L, U),
    phrase(expr(E0, D, 0), Vs),
    % call_nth(phrase(expr(E0, D, 0), Vs), Nth),
    % Nth @>= 45,
    % portray_clause(user_error, expr(Nth,E0)),
    once((\+subsumes_term((_^_)^_, E0), \+subsumes_term(_^(_^_), E0))),
    alleq(Vs),
    list_element([#\ E0 #= #E,#\ E0 #\= #E,#\ E0 #>= #E,#\ E0 #> #E], G_0),
    term_variables([E|Vs], Ws0),
    list_equisized(Ws0, Ws),
    list_foldl(list_select, Ws, Ws0, []),
    findall(Ws-G_0, (G_0, list_map(G_1, Ws)), Es0),
    findall(Ws-G_0, (Ws ins L..U, G_0, list_map(G_1, Ws)), Es1),
    findall(Ws-G_0, (G_0, Ws ins L..U, list_map(G_1, Ws)), Es2),
    findall(Ws-G_0, (list_map(G_1, Ws), G_0), Es3),
    \+ list_map(list_length, [Es0,Es1,Es2,Es3], [S,S,S,S]),
    portray_clause(user_output, Es0),
    portray_clause(user_output, Es1),
    portray_clause(user_output, Es2),
    portray_clause(user_output, Es3),
    list_map(list_length, [Es0,Es1,Es2,Es3], [L0,L1,L2,L3]),
    portray_clause(user_output, [L..U,G_0,Ws,[L0,L1,L2,L3]]),
    halt.

domain(L0, U0, L..U) :-
    integer_between(L0, U0, L),
    integer_between(L, U0, U).

test_dmn(M) :-
    integer_abs(M, U),
    integer_neg(U, L),
    list_element(
        [   % #E0 + #E1 #= #E2, % Good?
            % #E0 * #E1 #= #E2, % Good?
            %% #E0 ^ #E1 #= #E2, % Too hard
            % min(#E0,#E1) #= #E2, % Good?
            % max(#E0,#E1) #= #E2, % Good?
            % #E0 div #E1 #= #E2, % Also hard
            #E0 mod #E1 #= #E2, % Incomplete
            % #E0 // #E1 #= #E2,
            % #E0 rem #E1 #= #E2,
            % abs(#E0) #= #E1, % Good
            % sign(#E0) #= #E1, % Good
            % #E0 << #E1 #= #E2, % Incomplete
            % #E0 >> #E1 #= #E2, % Incomplete
            % #E0 /\ #E1 #= #E2, % Unclear
            % #E0 \/ #E1 #= #E2, % Unclear
            % xor(#E0,#E1) #= #E2, % Unclear
            % msb(#E0) #= #E1, % Good?
            % lsb(#E0) #= #E1, % Not possible
            % popcount(#E0) #= #E1, % Not possible
            false
        ],
        E
    ),
    \+ \+ E,
    portray_clause(user_error, E),
    term_variables(E, Vs),
    copy_term(E+Vs, F+Ws),
    list_equisized(Vs, Ds),
    list_map(domain(L, U), Ds),
    list_map(in, Vs, Ds),
    (   call(E), \+ \+ labeling([], Vs)
    ->  false,
        list_element(Vs, V),
        var(V),
        labeling([], [V]),
        % clpz:contract(Vs),
        findall(Vs, labeling([], Vs), Vss),
        list_equisized(Vs, Vs0),
        Vs0 ins inf..sup,
        tuples_in([Vs0], Vss),
        (   false
        ->  list_map(fd_dom, Vs0, Es0),
            list_map(fd_dom, Vs, Es)
        ;   list_map(fd_inf, Vs0, Is0),
            list_map(fd_sup, Vs0, Ss0),
            list_map(fd_inf, Vs, Is),
            list_map(fd_sup, Vs, Ss),
            list_map(dom, Is0, Ss0, Es0),
            list_map(dom, Is, Ss, Es)
        ),
        Es0 \= Es,
        portray_clause(user_output, [true,F,Ws,Es,Es0,E]),
        halt, false
    ;   call(E), \+ \+ clpz:contracting(Vs)
    ->  findall(E, (list_element(Vs, V), var(V), labeling([], [V])), Es),
        Es = [_|_],
        portray_clause(user_output, [fail,F,Ws,Ds+Es]),
        halt
    ;   \+ E,
        labeling([], Vs),
        call(E),
        portray_clause(user_output, [fail,F,Ws,Ds+E]),
        halt
    ),
    false.

dom(L, U, L..U).

'@test_dmn'(E, Vs) :-
    E = Vs.
