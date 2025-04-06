% DCG variants

kill(State) --> { kill(State) }.

kill(State, Ps) --> { kill(State, Ps) }.

T =.. Ls --> { T =.. Ls }.

A = A --> [].

A == B --> { A == B }.

A \== B --> { A \== B }.

integer(I) --> { integer(I) }.
nonvar(X) --> { nonvar(X) }.
var(V) --> { var(V) }.
ground(T) --> { ground(T) }.

true --> [].
false --> { false }.

X >= Y  --> { X >= Y }.
X =< Y  --> { X =< Y }.
X =:= Y --> { X =:= Y }.
X =\= Y --> { X =\= Y }.
X is E  --> { X is E }.
X > Y   --> { X > Y }.
X < Y   --> { X < Y }.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Duo DCG variants
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

A = B ++> { A = B }.
A < B ++> { A < B }.
A is B ++> { A is B }.
