/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A constraint that is being reified need not hold. Therefore, in
   X/Y, Y can as well be 0, for example. Note that it is OK to
   constrain the *result* of an expression (which does not appear
   explicitly in the expression and is not visible to the outside),
   but not the operands, except for requiring that they be integers.

   In contrast to parse_clpz/2, the result of an expression can now
   also be undefined, in which case the constraint cannot hold.
   Therefore, the committed-choice language is extended by an element
   d(D) that states D is 1 iff all subexpressions are defined. a(V)
   means that V is an auxiliary variable that was introduced while
   parsing a compound expression. a(X,V) means V is auxiliary unless
   it is (==)/2 X, and a(X,Y,V) means V is auxiliary unless it is
   (==)/2 X or Y. l(L) means the literal L occurs in the described
   list, and ls(Ls) means the literals Ls occur in the described list.

   When a constraint becomes entailed or subexpressions become
   undefined, created auxiliary constraints are killed, and the
   "clpz" attribute is removed from auxiliary variables.

   For (//)/2, (mod)/2 and (rem)/2, we create a skeleton propagator
   and remember it as an auxiliary constraint. The pskeleton
   propagator can use the skeleton when the constraint is defined.

   We cannot use a skeleton propagator for (/)/2, since (/)/2 can
   fail in cases such as 0 #==> X #= 1/2, where we expect success.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

parse_reified(E, R, D,
              [g(cyclic_term(E)) => [g(domain_error(clpz_expression, E))],
               g(var(E))     => [g(non_monotonic(E)),
                                 g(constrain_to_integer(E)), g(R = E), g(D=1)],
               g(integer(E)) => [g(R=E), g(D=1)],
               ?(E)          => [g(must_be_fd_integer(E)), g(R=E), g(D=1)],
               #E            => [g(must_be_fd_integer(E)), g(R=E), g(D=1)],
               m(A+B)        => [d(D), p(pplus(A,B,R)), a(A,B,R)],
               m(A*B)        => [d(D), p(ptimes(A,B,R)), a(A,B,R)],
               m(A-B)        => [d(D), p(pplus(R,B,A)), a(A,B,R)],
               m(-A)         => [d(D), p(pplus(A,R,0)), a(R)],
               m(max(A,B))   => [d(D), p(pgeq(R, A)), p(pgeq(R, B)), p(pmax(A,B,R)), a(A,B,R)],
               m(min(A,B))   => [d(D), p(pgeq(A, R)), p(pgeq(B, R)), p(pmin(A,B,R)), a(A,B,R)],
               m(abs(A))     => [d(D), g(#R#>=0), p(pabs(A, R)), a(A,R)],
               m(A^B)        => [d(D1), p(preified_exp(A,B,D2,R)),
                                 p(reified_and(D1,[],D2,[],D)),a(D2),a(A,B,R)],
               m(A/B)        => [d(D1), p(preified_slash(A,B,D2,R)),
                                 p(reified_and(D1,[],D2,[],D)),a(D2),a(A,B,R)],
               m(A div B)    => [d(D1),
                                 g(phrase(parse_reified_clpz(((A-(A mod B)) // B), R, D2), Ps)),
                                 ls(Ps),
                                 p(reified_and(D1,[],D2,[],D)),a(D2),a(A,B,R)],
               m(A//B)       => [skeleton(A,B,D,R,ptzdiv)],
               m(A mod B)    => [skeleton(A,B,D,R,pmod)],
               m(A rem B)    => [skeleton(A,B,D,R,prem)],
               % bitwise operations
               m(\A)         => [function(D,\,A,R)],
               m(msb(A))     => [function(D,msb,A,R)],
               m(lsb(A))     => [function(D,lsb,A,R)],
               m(popcount(A)) => [function(D,popcount,A,R)],
               m(sign(A))    => [d(D), p(psign(A, R)), a(A,R)],
               m(A<<B)       => [function(D,<<,A,B,R)],
               m(A>>B)       => [function(D,>>,A,B,R)],
               m(A/\B)       => [function(D,/\,A,B,R)],
               m(A\/B)       => [function(D,\/,A,B,R)],
               m(xor(A, B))  => [skeleton(A,B,D,R,pxor)],
               g(true)       => [g(domain_error(clpz_expression, E))]]
             ).

% Again, we compile this to a predicate, parse_reified_clpz//3. This
% time, it is a DCG that describes the list of auxiliary variables and
% propagators for the given expression, in addition to relating it to
% its reified (Boolean) finite domain variable and its Boolean
% definedness.

make_parse_reified(Clauses) :-
        parse_reified_clauses(Clauses0),
        maplist(goals_goal_dcg, Clauses0, Clauses).

goals_goal_dcg((Head --> Goals), Clause) :-
        list_goal(Goals, Body),
        expand_term((Head --> Body), Clause).

parse_reified_clauses(Clauses) :-
        parse_reified(E, R, D, Matchers),
        maplist(parse_reified(E, R, D), Matchers, Clauses).

parse_reified(E, R, D, Matcher, Clause) :-
        Matcher = (Condition0 => Goals0),
        phrase((reified_condition(Condition0, E, Head, Ds),
                reified_goals(Goals0, Ds)), Goals, [a(D)]),
        Clause = (parse_reified_clpz(Head, R, D) --> Goals).

reified_condition(g(Goal), E, E, []) --> [{Goal}, !].
reified_condition(?(E), _, ?(E), []) --> [!].
reified_condition(#E, _, #E, [])     --> [!].
reified_condition(m(Match), _, Match0, Ds) -->
        [!],
        { copy_term(Match, Match0),
          term_variables(Match0, Vs0),
          term_variables(Match, Vs)
        },
        reified_variables(Vs0, Vs, Ds).

reified_variables([], [], []) --> [].
reified_variables([V0|Vs0], [V|Vs], [D|Ds]) -->
        [parse_reified_clpz(V0, V, D)],
        reified_variables(Vs0, Vs, Ds).

reified_goals([], _) --> [].
reified_goals([G|Gs], Ds) --> reified_goal(G, Ds), reified_goals(Gs, Ds).

reified_goal(d(D), Ds) -->
        (   { Ds = [X] } -> [{D=X}]
        ;   { Ds = [X,Y] } ->
            { phrase(reified_goal(p(reified_and(X,[],Y,[],D)), _), Gs),
              list_goal(Gs, Goal) },
            [( {X==1, Y==1} -> {D = 1} ; Goal )]
        ;   { domain_error(one_or_two_element_list, Ds) }
        ).
reified_goal(g(Goal), _) --> [{Goal}].
reified_goal(p(Vs, Prop), _) -->
        [{make_propagator(Prop, P)}],
        parse_init_dcg(Vs, P),
        [{variables_same_queue(Vs),
          trigger_once(P)}],
        [( { propagator_state(P, S), S == dead } -> [] ; [p(P)])].
reified_goal(p(Prop), Ds) -->
        { term_variables(Prop, Vs) },
        reified_goal(p(Vs,Prop), Ds).
reified_goal(function(D,Op,A,B,R), Ds) -->
        reified_goals([d(D),p(pfunction(Op,A,B,R)),a(A,B,R)], Ds).
reified_goal(function(D,Op,A,R), Ds) -->
        reified_goals([d(D),p(pfunction(Op,A,R)),a(A,R)], Ds).
reified_goal(skeleton(A,B,D,R,F), Ds) -->
        { Prop =.. [F,X,Y,Z] },
        reified_goals([d(D1),l(p(P)),g(make_propagator(Prop, P)),
                       p([A,B,D2,R], pskeleton(A,B,D2,[X,Y,Z]-P,R,F)),
                       p(reified_and(D1,[],D2,[],D)),a(D2),a(A,B,R)], Ds).
reified_goal(a(V), _)     --> [a(V)].
reified_goal(a(X,V), _)   --> [a(X,V)].
reified_goal(a(X,Y,V), _) --> [a(X,Y,V)].
reified_goal(l(L), _)     --> [[L]].
reified_goal(ls(Ls), _)   --> [seq(Ls)].

parse_init_dcg([], _)     --> [].
parse_init_dcg([V|Vs], P) --> [{init_propagator(V, P)}], parse_init_dcg(Vs, P).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
?- use_module(library(lists)),
   use_module(library(format)),
   clpz:parse_reified_clauses(Cs),
   maplist(portray_clause, Cs).
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
