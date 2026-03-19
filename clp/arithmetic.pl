/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Arithmetic Expression
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

% TODO: Move this.
'@integer'(X) :-
    (   var(X)
    ->  (   get_attr(X, clpz, _)
        ->  true
        ;   domain_from_bounds(inf, sup, D),
            propagators_empty(Ps),
            queue_empty(Q),
            put_attr(W, clpz, clpz_attr(no,no,no,D,Ps,Q)),
            X = W
        )
    ;   integer(X)
    ).

armt_from_term(T, E) :-
    (   acyclic_term(T),
        '@armt_from_term'(T, E0)
    ->  E = E0
    ;   throw(error(domain_error(clpz_arithmetic_expression,T),_))
    ).

'@armt_from_term'(T, E) :-
    (   var(T)
    ->  (   monotonic,
            throw(error(instantiation_error,_))
        ;   E = #T
        )
    ;   integer(T)
    ->  E = #T
    ;   '@@armt_from_term'(T, E)
    ).

armt_goal(N, As, G) :-
    G =.. [N|As].

armt_clause0(N/A) -->
    {   functor(T, N, A),
        functor(E, N, A),
        T =.. [N|Ts],
        E =.. [N|Es],
        list_transpose([Ts,Es], Ass),
        list_map(armt_goal('@armt_from_term'), Ass, Gs),
        goals_goal(',', Gs, Body)
    },
    [('@@armt_from_term'(T, E) :- Body)].

armt_from_term([
    (+)/2,(-)/2,(*)/2,
    % (/)/2, % This raises some issues.
    (^)/2,
    min/2,max/2,
    (div)/2,(mod)/2,
    (//)/2,(rem)/2,
    (-)/1,abs/1,sign/1,
    % bitwise operations
    (<<)/2,
    (>>)/2,
    (/\)/2,
    (\/)/2,
    (xor)/2,
    (\)/1,
    msb/1,
    lsb/1,
    popcount/1
]).

term_expansion(armt_from_term) -->
    [('@@armt_from_term'(#T, #E) :- (var(T) -> E = T ; integer(T), E = T))],
    % [(
    %     '@@armt_from_term'(#T, #E) :-
    %         (   var(T)
    %         ->  E = T
    %         ;   integer(T),
    %             E = T
    %         )
    % )],
    { armt_from_term(Fs) },
    map(armt_clause0, Fs).

armt_from_term.

armt_constraints([
    E #= E0+E1      => [c(iadd(E0,E1,E))],
    E #= E0-E1      => [c(iadd(E,E1,E0))],
    E #= E0*E1      => [c(imul(E0,E1,E))],
    % E #= E0/E1      => [c(pneq(0,E1)),c(imul(E,E1,E0))],
    E #= E0/E1      => [E1 in \{0},c(imul(E,E1,E0))],
    E #= E0^E1      => [c(iexp(E0,E1,E))],
    E #= min(E0,E1) => [c(pleq(E,E0)),c(pleq(E,E1)),c(imin(E0,E1,E))],
    E #= max(E0,E1) => [c(pleq(E0,E)),c(pleq(E1,E)),c(imax(E0,E1,E))],
    E #= E0 div E1  => [e((#E0 - #E0 mod #E1) / #E1,E)],
    % E #= E0 mod E1  => [c(pneq(0,E1)),c(imod(E0,E1,E))],
    E #= E0 mod E1  => [E1 in \{0},c(imod(E0,E1,E))],
    E #= E0//E1     => [e((#E0 - #E0 rem #E1) / #E1,E)],
    % E #= E0 rem E1  => [c(pneq(0,E1)),c(irem(E0,E1,E))],
    E #= E0 rem E1  => [E1 in \{0},c(irem(E0,E1,E))],
    E #= -E0        => [e(#E + #E0,0)],
    % E #= abs(E0)    => [c(pleq(0,E)),c(iabs(E0,E))],
    E #= abs(E0)    => [E in 0..sup,c(iabs(E0,E))],
    % E #= sign(E0)   => [c(pleq(-1,E)),c(pleq(E,1)),c(isgn(E0,E))],
    E #= sign(E0)   => [E in -1..1,c(isgn(E0,E))],
    % bitwise operations
    E #= E0<<E1     => [c(ishl(E0,E1,E))],
    E #= E0>>E1     => [c(ishr(E0,E1,E))],
    E #= E0/\E1     => [c(iand(E0,E1,E))],
    E #= E0\/E1     => [c(iior(E0,E1,E))],
    E #= xor(E0,E1) => [c(ixor(E0,E1,E))],
    E #= \E0        => [c(ixor(-1,E0,E))],
    % E #= msb(E0)    => [c(pleq(0,E)),c(pleq(1,E0)),c(imsb(E0,E))],
    E #= msb(E0)    => [E in 0..sup,E0 in 1..sup,c(imsb(E0,E))],
    % E #= lsb(E0)    => [c(pleq(0,E)),c(pleq(1,E0)),c(ilsb(E0,E))],
    E #= lsb(E0)    => [E in 0..sup,E0 in 1..sup,c(ilsb(E0,E))],
    % E #= popcount(E0) => [c(pleq(0,E)),c(pleq(0,E0)),c(ict1(E0,E))]
    E #= popcount(E0) => [E in 0..sup,E0 in 0..sup,c(ict1(E0,E))]
]).

'@armt_constraint'(V in D0) -->
    { drep_to_domain(D0, D) },
    ['@in'(D, V)].
'@armt_constraint'(c(C)) -->
    { term_variables(C, Vs) },
    [propagator_from_constraint(C, P),propagator_trigger(P, Vs)].
'@armt_constraint'(e(E0,E)) -->
    [armt_constrain(E0, E)].

armt_clause1(E #= E0 => Is) -->
    {   copy_term(E0, E1),
        E0 =.. [N|Es0],
        E1 =.. [N|Es1],
        list_transpose([Es1,Es0], Ess),
        list_map(armt_goal(armt_constrain), Ess, Gs0),
        drep_to_domain(inf..sup, D),
        phrase(
            (   ['@in'(D, E)],
                map(identity, Gs0),
                map('@armt_constraint', Is)
            ),
            Gs
        ),
        goals_goal(',', Gs, Body)
    },
    [(armt_constrain(E1, E) :- Body)].

term_expansion(armt_constrain) -->
    { drep_to_domain(inf..sup, D) },
    [(armt_constrain(#E, E) :- '@in'(D, E))],
    { armt_constraints(Is) },
    map(armt_clause1, Is).

armt_constrain.

% ?- term_expansion(armt_constrain, Cs, []), list_element(Cs, C), portray_clause(user_output, C), false.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Arithmetic Relations
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

%% #=<(?X, ?Y)
%
% The arithmetic expression X is less than or equal to Y. When
% reasoning over integers, replace (=<)/2 by (#=<)/2 to obtain more
% general relations.

E0 #=< E1 :-
    catch(armt_from_term(E0, E2), error(E,_), throw(error(E,(#=<)/2))),
    catch(armt_from_term(E1, E3), error(E,_), throw(error(E,(#=<)/2))),
    armt_constrain(E2, E4),
    armt_constrain(E3, E5),
    propagator_from_constraint(pleq(E4,E5), P),
    propagator_trigger(P, [E4,E5]),
    term_variables([E0,E1], Vs),
    list_map(reinforce, Vs).
% X #=< Y :- Y #>= X.

%% #>=(?X, ?Y)
%
% Same as Y #=< X. When reasoning over integers, replace (>=)/2 by (#>=)/2
% to obtain more general relations.

E0 #>= E1 :- E1 #=< E0.
% X #>= Y :- clpz_geq(X, Y).

clpz_geq(X, Y) :- clpz_geq_(X, Y), reinforce(X), reinforce(Y).

%% #=(?X, ?Y)
%
% The arithmetic expression X equals Y. When reasoning over integers,
% replace `(is)/2` by `(#=)/2` to obtain more general relations.

E0 #= E1 :-
    catch(armt_from_term(E0, E2), error(E,_), throw(error(E,(#=)/2))),
    catch(armt_from_term(E1, E3), error(E,_), throw(error(E,(#=)/2))),
    armt_constrain(E2, E4),
    armt_constrain(E3, E5),
    E4 = E5,
    term_variables([E0,E1], Vs),
    list_map(reinforce, Vs).
% X #= Y :- clpz_equal(X, Y).

clpz_equal(X, Y) :- clpz_equal_(X, Y), reinforce(X).

%% #\=(?X, ?Y)
%
% The arithmetic expressions X and Y evaluate to distinct integers.
% When reasoning over integers, replace (=\=)/2 by (#\=)/2 to obtain more
% general relations.

E0 #\= E1 :-
    catch(armt_from_term(E0, E2), error(E,_), throw(error(E,(#\=)/2))),
    catch(armt_from_term(E1, E3), error(E,_), throw(error(E,(#\=)/2))),
    armt_constrain(E2, E4),
    armt_constrain(E3, E5),
    propagator_from_constraint(pneq(E4,E5), P),
    propagator_trigger(P, [E4,E5]),
    term_variables([E0,E1], Vs),
    list_map(reinforce, Vs).
% X #\= Y :- clpz_neq(X, Y).

% X #\= Y + Z

x_neq_y_plus_z(X, Y, Z) :-
    propagator_from_constraint(x_neq_y_plus_z(X,Y,Z), P),
    term_variables([X,Y,Z], Vs),
    propagator_trigger(P, Vs).

% X is distinct from the number N. This is used internally, and does
% not reinforce other constraints.

neq_num(X, N) :-
    (   fd_get(X, XD0, XPs)
    ->  domain_remove(N, XD0, XD),
        fd_put(X, XD, XPs)
    ;   X =\= N
    ).

neq_num(X, N) -->
    (   { fd_get(X, XD, XPs) }
    ->  { domain_remove(N, XD, XD1) },
        fd_put(X, XD1, XPs)
    ;   { X =\= N }
    ).


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

E0 #< E1  :-
    catch(armt_from_term(E0, E2), error(E,_), throw(error(E,(#<)/2))),
    catch(armt_from_term(E1, E3), error(E,_), throw(error(E,(#<)/2))),
    E2 #= #E4, E3 #= #E5, #E4 #=< #E5, #E4 #\= #E5.
% X #< Y  :- Y #> X.

%% #>(?X, ?Y)
%
% Same as Y #< X.

X #> Y  :- Y #< X.
% X #> Y  :- X #>= Y + 1.
