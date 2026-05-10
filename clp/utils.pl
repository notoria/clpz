/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Utils
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

identity(E) --> [E].

variable(E) -->
    (   { var(E) }
    ->  [E]
    ;   []
    ).

% mapl
map(_G__1, []) --> [].
map(G__1, [E|Es]) --> call(G__1, E), map(G__1, Es).

% mapr
rev(_G__1, []) --> [].
rev(G__1, [E|Es]) --> rev(G__1, Es), call(G__1, E).

foldl(_G__3, [], S, S) --> [].
foldl(G__3, [E|Es], S0, S) --> call(G__3, E, S0, S1), foldl(G__3, Es, S1, S).

foldl(_G_2, S, S).
foldl(G_2, S0, S) :-
    call(G_2, S0, S1),
    foldl(G_2, S1, S).

% '@goals_goal'(',', [], true).
% '@goals_goal'(',', [G0|Gs0], G) :-
%     list_foldl(goal(','), Gs0, G0, G).
% '@goals_goal'(';', [], false).
% '@goals_goal'(';', [G0|Gs0], G) :-
%     list_foldl(goal(';'), Gs0, G0, G).

goals_first(',', [], [true]).
goals_first(',', [G|Gs], [G|Gs]).
goals_first(';', [], [false]).
goals_first(';', [G|Gs], [G|Gs]).

goals_goal(',', Gs0, G) :-
    list_reversed(Gs0, Gs1),
    goals_first(',', Gs1, [G2|Gs2]),
    list_foldl(goal(','), Gs2, G2, G).
goals_goal(';', Gs0, G) :-
    list_reversed(Gs0, Gs1),
    goals_first(',', Gs1, [G2|Gs2]),
    list_foldl(goal(';'), Gs2, G2, G).

goal(',', G, S, (G,S)).
goal(';', G, S, (G;S)).
