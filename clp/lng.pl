%% #\=(?X, ?Y)
%
% The arithmetic expressions X and Y evaluate to distinct integers.
% When reasoning over integers, replace (=\=)/2 by (#\=)/2 to obtain more
% general relations.

X #\= Y :- clpz_neq(X, Y).

% X #\= Y + Z

x_neq_y_plus_z(X, Y, Z) :-
        propagator_init_trigger(x_neq_y_plus_z(X,Y,Z)).

% X is distinct from the number N. This is used internally, and does
% not reinforce other constraints.

neq_num(X, N) :-
        (   fd_get(X, XD, XPs) ->
            domain_remove(XD, N, XD1),
            fd_put(X, XD1, XPs)
        ;   X =\= N
        ).

neq_num(X, N) -->
        (   { fd_get(X, XD, XPs) } ->
            { domain_remove(XD, N, XD1) },
            fd_put(X, XD1, XPs)
        ;   X =\= N
        ).


%% #>(?X, ?Y)
%
% Same as Y #< X.

X #> Y  :- X #>= Y + 1.

%% #<(?X, ?Y)
%
% The arithmetic expression X is less than Y. When reasoning over
% integers, replace `(<)/2` by `(#<)/2` to obtain more general relations.
%
% In addition to its regular use in tasks that require it, this
% constraint can also be useful to eliminate uninteresting symmetries
% from a problem. For example, all possible matches between pairs
% built from four players in total:
%
% ```
% ?- Vs = [A,B,C,D], Vs ins 1..4,
%         all_different(Vs),
%         A #< B, C #< D, A #< C,
%    findall(pair(A,B)-pair(C,D), label(Vs), Ms).
% Ms = [ pair(1, 2)-pair(3, 4),
%        pair(1, 3)-pair(2, 4),
%        pair(1, 4)-pair(2, 3)].
% ```

X #< Y  :- Y #> X.
