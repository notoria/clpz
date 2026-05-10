% Ordines
% :- include("../z").

% SICStus
:- include("../utils").
:- include("../integer").
:- include("../sicstus/compatibility").
:- use_module('../sicstus/call_nth').
% sicstus -f -l env/sicstus/iso.pl -l env/sicstus/z.pl -l env/clp/test/conjecture.pl

map(_, [], []) --> [].
map(G__2, [E0|Es0], [E|Es]) --> call(G__2, E0, E), map(G__2, Es0, Es).

% S = S0 \ T
diff(T, S0, S) :-
    list_append(T, S0, S1),
    uniques(S1, S2), % S2 = T union S0
    list_append(T, S, S2). % S = S2 \ T

% S = T inter S0
inter(T, S0, S) :-
    list_append(S0, T, S1),
    singles(S1, S2), % S2 = T symdiff S0
    diff(S2, S1, S). % S = (S0 union T) \ (T symdiff S0)

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

set(Es) :-
    XL = -10, XU = 10,
    YL = -5, YU = 5,
    between(XL, XU, X),
    between(YL, YU, Y),
    findall(exp(X,Y,Z), '$integer_exp'(X, Y, Z), Es).

atomic_formula(_<_).
% atomic_formula(_=<_).
atomic_formula(_=_).
atomic_formula(_\=_).

% g(X, Y, Z, Cs) --> [X=:=Y].
% g(X, Y, Z, Cs) --> [Y=:=Z].
% g(X, Y, Z, Cs) --> [Z=:=X].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [X=:=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [Y=:=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [Z=:=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(X)=:=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(Y)=:=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(Z)=:=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [X=\=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [Y=\=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [Z=\=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(X)=\=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(Y)=\=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(Z)=\=C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [X<C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [Y<C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [Z<C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(X)<C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(Y)<C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(Z)<C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [X>C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [Y>C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [Z>C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(X)>C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(Y)>C].
% g(X, Y, Z, Cs) --> { list_element(Cs, C) }, [abs(Z)>C].

hold([X,Y,Z]-Gs, exp(X0,Y0,Z0)) :-
    \+ \+ (
        X = X0,
        Y = Y0,
        Z = Z0,
        list_map(call, Gs)
    ).

exp(Z is X^Y) -->
    { dif(X, Z), dif(Y, Z) },
    { X in -100..100, Y in -10..10 },
    [Z,X,Y].

ops(X + Y =:= Z) --> [X,Y,Z].
ops(X * Y =:= Z) --> [X,Y,Z].
ops(max(X, Y) =:= Z) --> [X,Y,Z].
ops(min(X, Y) =:= Z) --> [X,Y,Z].
ops(X mod Y =:= Z) -->
    { Y in \{0} },
    [X,Y,Z].
% ops(X div Y =:= Z) -->
%     { Y in \{0} },
%     [X,Y,Z].
ops(abs(X) =:= Y) --> [X,Y].
ops(sign(X) =:= Y) --> [X,Y].

rel(X mod 2 =:= 0) --> { freeze(X, false) }, [X].
rel(X mod 2 =:= 1) --> { freeze(X, false) }, [X].
% rel(X = Y) --> { dif(X, Y), freeze(X, freeze(Y, false)) }, [X,Y].
rel(X < Y) --> { dif(X, Y), freeze(X, false), freeze(Y, false) }, [X,Y].
rel(X =< Y) --> { dif(X, Y), freeze(X, freeze(Y, false)) }, [X,Y].

% imply([X,Y], E, Es, Fs, _) :-
%     labeling([min(abs(#X)+1<<abs(#Y))], [X,Y]),
imply(Vs, E, Es, Fs, _) :-
    label(Vs),
    catch(E, _, false),
    % \+ (list_map(call, Fs) ; \+ list_map(call, Es)),
    (\+ list_map(call, Fs), list_map(call, Es)),
    !,
    false.
imply(Vs, E, Es, Fs, N) :-
    % \+ \+ (label(Vs), catch(E, _, false), list_map(call, Es), list_map(call, Fs)).
    findall(t, (label(Vs), catch(E, _, false), list_map(call, Es), list_map(call, Fs)), Ts), list_length(Ts, N), N >= 5.

sorted(Es0) :-
    copy_term(Es0, Es),
    term_variables(Es, Vs),
    list_append(Vs, _, [_|Vs]),
    sort(Es, Fs),
    Es == Fs.

constant(_).
constant(V) :-
    between(-2, 2, V).

conjecture :-
    foldl(succ, 2, N),
    conjecture(N).

conjecture(N) :-
    portray_clause(user_error, N),
    M is -N,
    Es1 = [_],
    phrase(exp(E0), Vs0),
    [_|Vs] = Vs0,
    Vs0 ins M..N,
    phrase(map(rel, Es1), Vs1),
    sorted(Es1),
    (   true
    ;   list_element(Vs, X),
        between(-1, 1, X)
    % ;   list_map(constant, Vs1)
    %     % list_element(Vs1, V1),
    %     % between(-2, 2, V1)
    ),
    list_map(constant, Vs1),
    Es = [E0|Es1],
    between(1, 3, Fn),
    list_length(Fs, Fn),
    phrase(map(rel, Fs), Vs2),
    sorted(Fs),
    list_map(constant, Vs2),
    % (   true
    % ;   list_map(constant, Vs2)
    %     % list_element(Vs2, V2),
    %     % between(-2, 2, V2)
    % ),
    list_append([Vs0,Vs1,Vs2], Vs3),
    term_variables(Vs3, Vs4),
    between(1, 3, Wn),
    list_length(Ws, Wn),
    alleq(Vs4, Ws),
    \+ ground(Vs),
    term_variables(Vs0, Ws0),
    term_variables(Vs4, Ws1),
    list_equisized(Ws0, Ws1),
    uniques(Es, Es),
    uniques(Fs, Fs),
    inter(Es, Fs, []),
    \+ (list_element(Es, _A<_B), list_element(Es, _C=<_D), _A == _C, _B == _D),
    \+ (list_element(Es, _A<_B), list_element(Fs, _C=<_D), _A == _C, _B == _D),
    \+ (list_element(Fs, _A<_B), list_element(Fs, _C=<_D), _A == _C, _B == _D),
    copy_term(Es+Fs+Vs+Vs0+E0, Es_+Fs_+Vs_+Vs0_+E0_),
    [X_,Y_] = Vs_, X_ in -100..100, Y_ in -100..100,
    Vs_ ins M..N,
    % portray_clause(user_error, Es=>Fs),
    imply(Vs_, E0_, Es_, Fs_, Count),
    portray_clause(user_output, [M..N,Vs,Es=>Fs,Count]),
    flush_output,
    false.
