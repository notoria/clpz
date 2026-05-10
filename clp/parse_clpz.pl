/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Parsing a CLP(ℤ) expression has two important side-effects: First,
   it constrains the variables occurring in the expression to
   integers. Second, it constrains some of them even more: For
   example, in X/Y and X mod Y, Y is constrained to be #\= 0.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

constrain_to_integer(X) :-
    (   var(X)
    ->  fd_get(X, D, Ps),
        fd_put(X, D, Ps)
    ;   integer(X)
    ).

power_var_num(P, X, N) :-
    (   var(P)
    ->  X = P,
        N = 1
    ;   P = #Q
    ->  must_be_fd_integer(Q),
        X = Q,
        N = 1
    ;   P = Left*Right,
        power_var_num(Left, XL, L),
        power_var_num(Right, XR, R),
        XL == XR,
        X = XL,
        integer_add(L, R, N)
    ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Given expression E, we obtain the finite domain variable R by
   interpreting a simple committed-choice language that is a list of
   conditions and bodies. In conditions, g(Goal) means literally Goal,
   and m(Match) means that E can be decomposed as stated. The
   variables are to be understood as the result of parsing the
   subexpressions recursively. In the body, g(Goal) means again Goal
   and p(Propagator) means to attach and trigger once a propagator.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

parse_clpz(E, R,
            [g(cyclic_term(E)) => [g(domain_error(clpz_expression, E))],
             g(var(E))         => [g(non_monotonic(E)),
                                   g(constrain_to_integer(E)), g(E = R)],
             g(integer(E))     => [g(R = E)],
             ?(E)              => [g(must_be_fd_integer(E)), g(R = E)],
             #E                => [g(must_be_fd_integer(E)), g(R = E)],
             m(A+B)            => [p(iadd(A,B,R))],
             % power_var_num/3 must occur before */2 to be useful
             % g(power_var_num(E, V, N)) => [p(iexp(V,N,R))],
             m(A*B)            => [p(imul(A, B, R))],
             m(A-B)            => [p(iadd(R,B,A))],
             m(-A)             => [p(iadd(A,R,0))],
             m(max(A,B))       => [g(A #=< #R), g(B #=< R), p(imax(A,B,R))],
             m(min(A,B))       => [g(A #>= #R), g(B #>= R), p(imin(A,B,R))],
             m(A mod B)        => [g(B #\= 0), p(imod(A,B,R))],
             m(A rem B)        => [g(B #\= 0), p(prem(A,B,R))],
             m(abs(A))         => [g(#R #>= 0), p(iabs(A,R))],
             m(A/B)            => [g(B #\= 0), p(imul(R,B,A))],
             m(A//B)           => [g(B #\= 0), p(ptzdiv(A,B,R))],
             m(A div B)        => [g(#R #= (A - (A mod B)) // B)],
             m(A^B)            => [p(iexp(A, B, R))],
             m(sign(A))        => [g(R in -1..1), p(isgn(A,R))],
             % bitwise operations
             m(\A)             => [p(pfunction(\,A,R))],
             m(msb(A))         => [p(pfunction(msb,A,R))],
             m(lsb(A))         => [p(pfunction(lsb,A,R))],
             m(popcount(A))    => [p(pfunction(popcount,A,R))],
             m(A<<B)           => [p(pfunction(<<,A,B,R))],
             m(A>>B)           => [p(pfunction(>>,A,B,R))],
             m(A/\B)           => [p(pfunction(/\,A,B,R))],
             m(A\/B)           => [p(pfunction(\/,A,B,R))],
             m(xor(A, B))      => [p(ixor(A,B,R))],
             g(true)           => [g(domain_error(clpz_expression, E))]
            ]).

non_monotonic(X) :-
    (   \+ fd_var(X),
        monotonic
    ->
        instantiation_error(X)
    ;   true
    ).

% Here, we compile the committed choice language to a single
% predicate, parse_clpz/2.

make_parse_clpz(Clauses) :-
        parse_clpz_clauses(Clauses0),
        list_map(goals_goal, Clauses0, Clauses).

goals_goal((Head :- Goals), (Head :- Body)) :-
        goals_goal(',', Goals, Body).

parse_clpz_clauses(Clauses) :-
        parse_clpz(E, R, Matchers),
        list_map(parse_matcher(E, R), Matchers, Clauses).

parse_matcher(E, R, Condition0 => Goals0, Clause) :-
    phrase((parse_condition(Condition0, E, Head), parse_goals(Goals0)), Goals),
    Clause = (parse_clpz(Head, R) :- Goals).

parse_condition(g(Goal), E, E)       --> [Goal, !].
parse_condition(?(E), _, ?(E))       --> [!].
parse_condition(#E, _, #E)           --> [!].
parse_condition(m(Match), _, Match0) -->
        [!],
        { copy_term(Match, Match0),
          term_variables(Match0, Vs0),
          term_variables(Match, Vs)
        },
        parse_match_variables(Vs0, Vs).

parse_match_variables([], []) --> [].
parse_match_variables([V0|Vs0], [V|Vs]) -->
        [parse_clpz(V0, V)],
        parse_match_variables(Vs0, Vs).

parse_goals([]) --> [].
parse_goals([G|Gs]) --> parse_goal(G), parse_goals(Gs).

parse_goal(g(Goal)) --> [Goal].
parse_goal(p(C)) -->
    { term_variables(C, Vs) },
    [propagator_from_constraint(C, P),propagator_trigger(P, Vs)].

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
?- use_module(library(lists)),
   use_module(library(format)),
   clpz:parse_clpz_clauses(Clauses),
   list_map(portray_clause, Clauses).
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neq(A, B) :-
    propagator_from_constraint(pneq(A,B), P),
    term_variables([A,B], Vs),
    propagator_trigger(P, Vs).

geq(A, B) :-
        queue_empty(Q),
        phrase((geq(A, B),propagator_catalyze), [Q], _).

geq(A, B) -->
        (   { fd_get(A, AD, APs) } ->
            { domain_infimum(AD, AI) },
            (   { fd_get(B, BD, _) } ->
                { domain_supremum(BD, BS) },
                (   { AI cis_ge BS } -> true
                ;   {   propagator_from_constraint(pleq(B,A), P),
                        term_variables([A,B], Vs),
                        propagator_trigger(P, Vs)
                    }
                )
            ;   (   { AI cis_ge n(B) } -> true
                ;   { domain_remove_less_than(B, AD, AD1) },
                    fd_put(A, AD1, APs)
                )
            )
        ;   { fd_get(B, BD, BPs) } ->
            { domain_remove_greater_than(A, BD, BD1) },
            fd_put(B, BD1, BPs)
        ;   A >= B
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Naive parsing of inequalities and disequalities can result in a lot
   of unnecessary work if expressions of non-trivial depth are
   involved: Auxiliary variables are introduced for sub-expressions,
   and propagation proceeds on them as if they were involved in a
   tighter constraint (like equality), whereas eventually only very
   little of the propagated information is actually used. For example,
   only extremal values are of interest in inequalities. Introducing
   auxiliary variables should be avoided when possible, and
   specialised propagators should be used for common constraints.

   We again use a simple committed-choice language for matching
   special cases of constraints. m_c(M,C) means that M matches and C
   holds. d(X, Y) means decomposition, i.e., it is short for
   g(parse_clpz(X, Y)). r(X, Y) means to rematch with X and Y.

   Two things are important: First, although the actual constraint
   functors (#\=2, #=/2 etc.) are used in the description, they must
   expand to the respective auxiliary predicates (match_expand/2)
   because the actual constraints are subject to goal expansion.
   Second, when specialised constraints (like scalar product) post
   simpler constraints on their own, these simpler versions must be
   handled separately and must occur before.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

match_expand(#>=, clpz_geq_).
match_expand(#=, clpz_equal_).
match_expand(#\=, clpz_neq).

symmetric(#=).
symmetric(#\=).

matches([
    m_c(any(X) #>= any(Y), left_right_linsum_const(X, Y, Cs, Vs, Const)) =>
       [g((   Cs = [1], Vs = [A] -> geq(A, Const)
          ;   Cs = [-1], Vs = [A] -> integer_neg(Const, Const1), geq(Const1, A)
          ;   Cs = [1,1], Vs = [A,B] -> #A + #B #= #S, geq(S, Const)
          ;   Cs = [1,-1], Vs = [A,B] ->
              (   Const =:= 0 -> geq(A, B)
              ;   integer_neg(Const, C1),
                  propagator_from_constraint(x_leq_y_plus_c(B,A,C1), P),
                  term_variables([B,A,C1], Ws),
                  propagator_trigger(P, Ws)
              )
          ;   Cs = [-1,1], Vs = [A,B] ->
              (   Const =:= 0 -> geq(B, A)
              ;   integer_neg(Const, C1),
                  propagator_from_constraint(x_leq_y_plus_c(A,B,C1), P),
                  term_variables([B,A,C1], Ws),
                  propagator_trigger(P, Ws)
              )
          ;   Cs = [-1,-1], Vs = [A,B] ->
              #A + #B #= #S, integer_neg(Const, Const1), geq(Const1, S)
          ;   '@scalar_product'(#>=, Cs, Vs, Const)
          ))],
    m(any(X) - any(Y) #>= integer(C))   =>
        [d(X, X1), d(Y, Y1), g(C1 is -C), p(x_leq_y_plus_c(Y1, X1, C1))],
    m(integer(X) #>= any(Z) + integer(A)) =>
        [g(C is X - A), r(C, Z)],
    m(abs(any(X)-any(Y)) #>= any(Z))    =>
        [d(X, X1), d(Y, Y1), d(Z, Z1), g((abs(#A)#= #B,Y1+A#=X1,Z1#=<B))],
    m(abs(any(X)) #>= integer(I))       =>
        [d(X, RX), g((I>0 -> I1 is -I, RX in inf..I1 \/ I..sup; true))],
    m(integer(I) #>= abs(any(X)))       =>
        [d(X, RX), g(I>=0), g(I1 is -I), g(RX in I1..I)],
    m(any(X) #>= any(Y))                =>
        [d(X, RX), d(Y, RY), g(geq(RX, RY))],

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    m(var(X) #= var(Y))         =>
        [g(constrain_to_integer(X)), g(X=Y)],
    m(var(X) #= var(Y)+var(Z))  =>
        [p(iadd(Y,Z,X))],
    m(var(X) #= var(Y)-var(Z))  =>
        [p(iadd(X,Z,Y))],
    m(var(X) #= var(Y)*var(Z))  =>
        [p(imul(Y,Z,X))],
    m(var(X) #= -var(Y))        =>
        [p(iadd(X,Y,0))],
    m_c(any(X) #= any(Y), left_right_linsum_const(X, Y, Cs, Vs, S)) =>
       [g('@scalar_product'(#=, Cs, Vs, S))],
    m_c(var(X) #= abs(var(Y))+any(V0), X == Y) =>
        [d(V0,V),p(x_eq_abs_plus_v(X,V))],
    m_c(var(X) #= abs(var(Y))-any(V0), X == Y) =>
        [d(-V0,V),p(x_eq_abs_plus_v(X,V))],
    m(var(X) #= any(Y))         =>
        [d(Y,X)],
    m(any(X) #= any(Y))         =>
        [d(X, RX), d(Y, RX)],

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    m(var(X) #\= integer(Y))            =>
        [g(neq_num(X, Y))],
    m(var(X) #\= var(Y))                =>
        [p(pneq(X,Y))],
    m(var(X) #\= var(Y) + var(Z))       =>
        [p(x_neq_y_plus_z(X, Y, Z))],
    m(var(X) #\= var(Y) - var(Z))       =>
        [p(x_neq_y_plus_z(Y, X, Z))],
    m(var(X) #\= var(Y)*var(Z))         =>
        [p(imul(Y,Z,P)), g(neq(X,P))],
    m(integer(X) #\= abs(any(Y)-any(Z))) =>
        [d(Y, Y1), d(Z, Z1), p(absdiff_neq(Y1, Z1, X))],
    m_c(any(X) #\= any(Y), left_right_linsum_const(X, Y, Cs, Vs, S)) =>
        [g('@scalar_product'(#\=, Cs, Vs, S))],
    m(any(X) #\= any(Y) + any(Z))       =>
        [d(X, X1), d(Y, Y1), d(Z, Z1), p(x_neq_y_plus_z(X1, Y1, Z1))],
    m(any(X) #\= any(Y) - any(Z))       =>
        [d(X, X1), d(Y, Y1), d(Z, Z1), p(x_neq_y_plus_z(Y1, X1, Z1))],
    m(any(X) #\= any(Y))                =>
        [d(X, RX), d(Y, RY), g(neq(RX, RY))]
]).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   We again compile the committed-choice matching language to the
   intended auxiliary predicates. We now must take care not to
   unintentionally unify a variable with a complex term.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

make_matches(Clauses) :-
        matches(Ms),
        findall(F, (member(M=>_, Ms), arg(1, M, M1), functor(M1, F, _)), Fs0),
        sort(Fs0, Fs),
        list_map(prevent_cyclic_argument, Fs, PrevCyclicClauses),
        phrase(map('@matcher', Ms), Clauses0),
        list_map(goals_goal, Clauses0, MatcherClauses),
        list_append(PrevCyclicClauses, MatcherClauses, Clauses1),
        sort_by_predicate(Clauses1, Clauses).

sort_by_predicate(Clauses, ByPred) :-
        map_list_to_pairs(predname, Clauses, Keyed),
        keysort(Keyed, KeyedByPred),
        pairs_values(KeyedByPred, ByPred).

predname(T, Key) :-
    (   T = (H:-_)
    ->  predname(H, Key)
    ;   T = M:H, Key = M:K
    ->  predname(H, K)
    ;   Key = Name/Arity
    ->  functor(T, Name, Arity)
    ).

prevent_cyclic_argument(F0, Clause) :-
        match_expand(F0, F),
        Head =.. [F,X,Y],
        Clause = (
            Head :-
                (   cyclic_term(X)
                ->  domain_error(clpz_expression, X)
                ;   cyclic_term(Y)
                ->  domain_error(clpz_expression, Y)
                ;   false
                )
        ).

'@matcher'(Condition => Goals) -->
    matcher(Condition, Goals).

matcher(m(M), Gs) --> matcher(m_c(M,true), Gs).
matcher(m_c(Matcher,Cond), Gs) -->
    [(Head0 :- Goals0)],
    { Matcher =.. [F,A,B],
      match_expand(F, Expand),
      Head0 =.. [Expand,X,Y],
      phrase((match(A, X), match(B, Y)), Goals0, [Cond,!|Goals1]),
      phrase(map(match_goal(Expand), Gs), Goals1) },
    (   { symmetric(F), \+ (subsumes_term(A, B), subsumes_term(B, A)) }
    ->  { Head1 =.. [Expand,Y,X] },
        [(Head1 :- Goals0)]
    ;   []
    ).

match(any(A), T)     --> [A = T].
match(var(V), T)     -->
    [(  nonvar(T), ( T = ?(Var) ; T = #Var )
    ->  must_be_fd_integer(Var),
        V = Var
    ;   v_or_i(T),
        V = T
    )].
match(integer(I), T) --> [integer(T), I = T].
match(-X, T)         --> [nonvar(T), T = -A], match(X, A).
match(abs(X), T)     --> [nonvar(T), T = abs(A)], match(X, A).
match(X+Y, T)        --> [nonvar(T), T = A + B], match(X, A), match(Y, B).
match(X-Y, T)        --> [nonvar(T), T = A - B], match(X, A), match(Y, B).
match(X*Y, T)        --> [nonvar(T), T = A * B], match(X, A), match(Y, B).

match_goal(F, r(X,Y))  --> { G =.. [F,X,Y] }, [G].
match_goal(_, d(X,Y))  --> [parse_clpz(X, Y)].
match_goal(_, g(Goal)) --> [Goal].
match_goal(_, p(C)) -->
    { term_variables(C, Vs) },
    [propagator_from_constraint(C, P), propagator_trigger(P, Vs)].
