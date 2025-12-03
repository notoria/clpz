:- op(1199,  fx, attribute).
:- op( 600, xfy, :).
:- op( 500, yfx, xor).
:- op( 200,  fy, +).


\+(G_0) :-
    (   call(G_0)
    ->  false
    ;   true
    ).

\=(A, B) :-
    (   A = B
    ->  false
    ;   true
    ).

copy_term_nat(T0, T) :-
    copy_term(T0, T).

% copy_term(T0, T) :-
%     findall(T0, true, [T]).

term_compare(R, X0, Y0, X, Y) :-
    term_compare(R, X0, Y0),
    '@term_compare'(R, X0, Y0, X, Y).

'@term_compare'(<, X, Y, X, Y).
'@term_compare'(=, X, Y, X, Y).
'@term_compare'(>, X, Y, Y, X).

element([E|Es], E0) :-
    '@element'(Es, E, E0).

'@element'(_, E, E).
'@element'([E|Es], _, E0) :-
    '@element'(Es, E, E0).

expand_term(T0, T) :-
    (   term_expansion(T0, Ts, [])
    ->  element(Ts, T1),
        expand_term(T1, T)
    ;   T = T0
    ).

% :- op( 950,  fx, *). *(_). goal_expansion(*_, true).
