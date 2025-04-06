%% #\(+Q)
%
% The reifiable constraint Q does _not_ hold. For example, to obtain
% the complement of a domain:
%
% ```
% ?- #\ X in -3..0\/10..80.
% X in inf.. -4\/1..9\/81..sup.
% ```

#\ Q       :- reify(Q, 0).

%% #<==>(?P, ?Q)
%
% P and Q are equivalent. For example:
%
% ```
% ?- X #= 4 #<==> B, X #\= 4.
% B = 0,
% X in inf..3\/5..sup.
% ```
% The following example uses reified constraints to relate a list of
% finite domain variables to the number of occurrences of a given value:
%
% ```
% vs_n_num(Vs, N, Num) :-
%         maplist(eq_b(N), Vs, Bs),
%         sum(Bs, #=, Num).
%
% eq_b(X, Y, B) :- X #= Y #<==> B.
% ```
%
% Sample queries and their results:
%
% ```
% ?- Vs = [X,Y,Z], Vs ins 0..1, vs_n_num(Vs, 4, Num).
% Vs = [X, Y, Z],
% Num = 0,
% X in 0..1,
% Y in 0..1,
% Z in 0..1.
%
% ?- vs_n_num([X,Y,Z], 2, 3).
% X = 2,
% Y = 2,
% Z = 2.
% ```

L #<==> R  :- reify(L, B), reify(R, B).

%% #==>(?P, ?Q)
%
% P implies Q.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Implication is special in that created auxiliary constraints can be
   retracted when the implication becomes entailed, for example:

   %?- X + 1 #= Y #==> Z, Z #= 1.
   %@ Z = 1,
   %@ X in inf..sup,
   %@ Y in inf..sup.

   We cannot use propagator_init_trigger/1 here because the states of
   auxiliary propagators are themselves part of the propagator.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

L #==> R   :-
        reify(L, LB, LPs),
        reify(R, RB, RPs),
        append(LPs, RPs, Ps),
        propagator_init_trigger([LB,RB], pimpl(LB,RB,Ps)).

%% #<==(?P, ?Q)
%
% Q implies P.

L #<== R   :- R #==> L.

%% #/\(?P, ?Q)
%
% P and Q hold.

L #/\ R    :- reify(L, 1), reify(R, 1).

conjunctive_neqs_var_drep(Eqs, Var, Drep) :-
        conjunctive_neqs_var(Eqs, Var),
        phrase(conjunctive_neqs_vals(Eqs), Vals),
        list_to_domain(Vals, Dom),
        domain_complement(Dom, C),
        domain_to_drep(C, Drep).

conjunctive_neqs_var(V0, V) :-
    nonvar(V0),
    conjunctive_neqs_var_(V0, V).

conjunctive_neqs_var_(L #\= R, Var) :-
        (   var(L), integer(R) -> Var = L
        ;   integer(L), var(R) -> Var = R
        ;   false
        ).
conjunctive_neqs_var_(A #/\ B, VA) :-
        conjunctive_neqs_var(A, VA),
        conjunctive_neqs_var(B, VB),
        VA == VB.

conjunctive_neqs_vals(L #\= R) --> ( { integer(L) } -> [L] ; [R] ).
conjunctive_neqs_vals(A #/\ B) -->
        conjunctive_neqs_vals(A),
        conjunctive_neqs_vals(B).

%% #\/(?P, ?Q)
%
% P or Q holds. For example, the sum of natural numbers below 1000
% that are multiples of 3 or 5:
%
% ```
% ?- findall(N, (N mod 3 #= 0 #\/ N mod 5 #= 0, N in 0..999,
%                indomain(N)),
%            Ns),
%    sum(Ns, #=, Sum).
% Ns = [0, 3, 5, 6, 9, 10, 12, 15, 18|...],
% Sum = 233168.
% ```

L #\/ R :-
        (   disjunctive_eqs_var_drep(L #\/ R, Var, Drep) -> Var in Drep
        ;   reify(L, X, Ps1),
            reify(R, Y, Ps2),
            propagator_init_trigger([X,Y], reified_or(X,Ps1,Y,Ps2,1))
        ).

disjunctive_eqs_var_drep(Eqs, Var, Drep) :-
        disjunctive_eqs_var(Eqs, Var),
        phrase(disjunctive_eqs_vals(Eqs), Vals),
        list_to_drep(Vals, Drep).

disjunctive_eqs_var(V0, V) :-
    nonvar(V0),
    disjunctive_eqs_var_(V0, V).

disjunctive_eqs_var_(V in I, V) :- var(V), integer(I).
disjunctive_eqs_var_(L #= R, Var) :-
        (   var(L), integer(R) -> Var = L
        ;   integer(L), var(R) -> Var = R
        ;   false
        ).
disjunctive_eqs_var_(A #\/ B, VA) :-
        disjunctive_eqs_var(A, VA),
        disjunctive_eqs_var(B, VB),
        VA == VB.

disjunctive_eqs_vals(L #= R)  --> ( { integer(L) } -> [L] ; [R] ).
disjunctive_eqs_vals(_ in I)  --> [I].
disjunctive_eqs_vals(A #\/ B) -->
        disjunctive_eqs_vals(A),
        disjunctive_eqs_vals(B).

%% #\(?P, ?Q)
%
% Either P holds or Q holds, but not both.

L #\ R :- (L #\/ R) #/\ #\ (L #/\ R).
