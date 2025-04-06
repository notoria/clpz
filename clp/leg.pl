%% #>=(?X, ?Y)
%
% Same as Y #=< X. When reasoning over integers, replace (>=)/2 by (#>=)/2
% to obtain more general relations.

X #>= Y :- clpz_geq(X, Y).

clpz_geq(X, Y) :- clpz_geq_(X, Y), reinforce(X), reinforce(Y).

%% #=<(?X, ?Y)
%
% The arithmetic expression X is less than or equal to Y. When
% reasoning over integers, replace (=<)/2 by (#=<)/2 to obtain more
% general relations.

X #=< Y :- Y #>= X.

%% #=(?X, ?Y)
%
% The arithmetic expression X equals Y. When reasoning over integers,
% replace `(is)/2` by `(#=)/2` to obtain more general relations.

X #= Y :- clpz_equal(X, Y).

clpz_equal(X, Y) :- clpz_equal_(X, Y), reinforce(X).
