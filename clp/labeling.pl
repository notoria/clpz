%% indomain(?Var)
%
% Bind Var to all feasible values of its domain on backtracking. The
% domain of Var must be finite.

indomain(Var) :- label([Var]).

order_dom_next(up, Dom, Next)   :- domain_infimum(Dom, n(Next)).
order_dom_next(down, Dom, Next) :- domain_supremum(Dom, n(Next)).


%% label(+Vars)
%
% Equivalent to labeling([], Vars).

label(Vs) :- labeling([], Vs).

%% labeling(+Options, +Vars)
%
% Assign a value to each variable in Vars. Labeling means systematically
% trying out values for the finite domain   variables  Vars until all of
% them are ground. The domain of each   variable in Vars must be finite.
% Options is a list of options that   let  you exhibit some control over
% the search process. Several categories of options exist:
%
% The variable selection strategy lets you specify which variable of
% Vars is labeled next and is one of:
%
%   * leftmost
%   Label the variables in the order they occur in Vars. This is the
%   default.
%
%   * ff
%   _|First fail|_. Label the leftmost variable with smallest domain next,
%   in order to detect infeasibility early. This is often a good
%   strategy.
%
%   * ffc
%   Of the variables with smallest domains, the leftmost one
%   participating in most constraints is labeled next.
%
%   * min
%   Label the leftmost variable whose lower bound is the lowest next.
%
%   * max
%   Label the leftmost variable whose upper bound is the highest next.
%
% The value order is one of:
%
%   * up
%   Try the elements of the chosen variable's domain in ascending order.
%   This is the default.
%
%   * down
%   Try the domain elements in descending order.
%
% The branching strategy is one of:
%
%   * step
%   For each variable X, a choice is made between X = V and X #\= V,
%   where V is determined by the value ordering options. This is the
%   default.
%
%   * enum
%   For each variable X, a choice is made between X = V_1, X = V_2
%   etc., for all values V_i of the domain of X. The order is
%   determined by the value ordering options.
%
%   * bisect
%   For each variable X, a choice is made between X #=< M and X #> M,
%   where M is the midpoint of the domain of X.
%
% At most one option of each category can be specified, and an option
% must not occur repeatedly.
%
% The order of solutions can be influenced with:
%
%   * min(Expr)
%   * max(Expr)
%
% This generates solutions in ascending/descending order with respect
% to the evaluation of the arithmetic expression Expr. Labeling Vars
% must make Expr ground. If several such options are specified, they
% are interpreted from left to right, e.g.:
%
% ```
% ?- [X,Y] ins 10..20, labeling([max(X),min(Y)],[X,Y]).
% ```
%
% This generates solutions in descending order of X, and for each
% binding of X, solutions are generated in ascending order of Y. To
% obtain the incomplete behaviour that other systems exhibit with
% "maximize(Expr)" and "minimize(Expr)", use once/1, e.g.:
%
% ```
% once(labeling([max(Expr)], Vars))
% ```
%
% Labeling is always complete, always terminates, and yields no
% redundant solutions.
%

labeling(Options, Vars) :-
        must_be(list, labeling(Options, Vars)-1, Options),
        fd_must_be_list(Vars, labeling(Options, Vars)-2),
        list_map(finite_domain(labeling(Options, Vars), 2), Vars),
        label(Options, Options, default(leftmost), default(up), default(step), [], upto_ground, Vars).


finite_domain(Goal, Arg, Var) :-
        (   fd_get(Var, Dom, _) ->
            (   domain_infimum(Dom, n(_)), domain_supremum(Dom, n(_)) -> true
            ;   instantiation_error(Dom)
            )
        ;   integer(Var) -> true
        ;   must_be(integer, Goal-Arg, Var)
        ).

finite_domain(Var) :-
        finite_domain(finite_domain(Var), 1, Var).


label([O|Os], Options, Selection, Order, Choice, Optim, Consistency, Vars) :-
        (   var(O)-> instantiation_error(O)
        ;   override(selection, Selection, O, Options, S1) ->
            label(Os, Options, S1, Order, Choice, Optim, Consistency, Vars)
        ;   override(order, Order, O, Options, O1) ->
            label(Os, Options, Selection, O1, Choice, Optim, Consistency, Vars)
        ;   override(choice, Choice, O, Options, C1) ->
            label(Os, Options, Selection, Order, C1, Optim, Consistency, Vars)
        ;   optimisation(O) ->
            label(Os, Options, Selection, Order, Choice, [O|Optim], Consistency, Vars)
        ;   consistency(O, O1) ->
            label(Os, Options, Selection, Order, Choice, Optim, O1, Vars)
        ;   domain_error(labeling_option, O)
        ).
label([], _, Selection, Order, Choice, Optim0, Consistency, Vars) :-
        list_map(arg(1), [Selection,Order,Choice], [S,O,C]),
        (   Optim0 == [] ->
            label(Vars, S, O, C, Consistency)
        ;   list_reversed(Optim0, Optim),
            exprs_singlevars(Optim, SVs),
            call_cleanup(optimise(Vars, [S,O,C], SVs),
                         retractall(extremum(_)))
        ).

% Introduce new variables for each min/max expression to avoid
% reparsing expressions during optimisation.

exprs_singlevars([], []).
exprs_singlevars([E|Es], [SV|SVs]) :-
        E =.. [F,Expr],
        #Single #= Expr,
        SV =.. [F,Single],
        exprs_singlevars(Es, SVs).

label(Vars, Selection, Order, Choice, Consistency) :-
        (   Vars = [] -> (Consistency = upto_in(I0,I) -> I0 = I ; true)
        ;   Vars = [V|Vs], nonvar(V) -> label(Vs, Selection, Order, Choice, Consistency)
        ;   select_var(Selection, Vars, Var, RVars),
            (   var(Var) ->
                (   Consistency = upto_in(I0,I), fd_get(Var, _, Ps), propagators_dead(Ps) ->
                    fd_size(Var, Size),
                    integer_mul(Size, I0, I1), % I1 #= I0*Size,
                    label(RVars, Selection, Order, Choice, upto_in(I1,I))
                ;   Consistency = upto_in, fd_get(Var, _, Ps), propagators_dead(Ps) ->
                    label(RVars, Selection, Order, Choice, Consistency)
                ;   choice_order_variable(Choice, Order, Var, RVars, Vars, Selection, Consistency)
                )
            ;   label(RVars, Selection, Order, Choice, Consistency)
            )
        ).

choice_order_variable(step, Order, Var, Vars, Vars0, Selection, Consistency) :-
        fd_get(Var, Dom, _),
        order_dom_next(Order, Dom, Next),
        (   Var = Next,
            label(Vars, Selection, Order, step, Consistency)
        ;   neq_num(Var, Next),
            label(Vars0, Selection, Order, step, Consistency)
        ).
choice_order_variable(enum, Order, Var, Vars, _, Selection, Consistency) :-
        fd_get(Var, Dom0, _),
        domain_direction_element(Dom0, Order, Var),
        label(Vars, Selection, Order, enum, Consistency).
choice_order_variable(bisect, Order, Var, _, Vars0, Selection, Consistency) :-
        fd_get(Var, Dom, _),
        domain_infimum(Dom, n(I)),
        domain_supremum(Dom, n(S)),
        integer_add(I, S, R0), integer_ddqr(trunc, R0, 2, Mid0, _), % Mid0 #= (I + S) // 2,
        (   Mid0 =:= S -> integer_add(1, Mid, Mid0) /* Mid #= Mid0 - 1 */ ; Mid = Mid0 ),
        (   Order == up -> ( #Var #=< Mid ; #Var #> Mid )
        ;   Order == down -> ( #Var #> Mid ; #Var #=< Mid )
        ;   domain_error(bisect_up_or_down, Order)
        ),
        label(Vars0, Selection, Order, bisect, Consistency).

override(What, Prev, Value, Options, Result) :-
        call(What, Value),
        override_(Prev, Value, Options, Result).

override_(default(_), Value, _, user(Value)).
override_(user(Prev), Value, Options, _) :-
        (   Value == Prev ->
            domain_error(nonrepeating_labeling_options, Options)
        ;   domain_error(consistent_labeling_options, Options)
        ).

selection(ff).
selection(ffc).
selection(min).
selection(max).
selection(leftmost).

choice(step).
choice(enum).
choice(bisect).

order(up).
order(down).

consistency(upto_in(I), upto_in(1, I)).
consistency(upto_in, upto_in).
consistency(upto_ground, upto_ground).

optimisation(min(_)).
optimisation(max(_)).

select_var(leftmost, [Var|Vars], Var, Vars).
select_var(min, [V|Vs], Var, RVars) :-
        find_min(Vs, V, Var),
        delete_eq([V|Vs], Var, RVars).
select_var(max, [V|Vs], Var, RVars) :-
        find_max(Vs, V, Var),
        delete_eq([V|Vs], Var, RVars).
select_var(ff, [V|Vs], Var, RVars) :-
        fd_size_(V, n(S)),
        find_ff(Vs, V, S, Var),
        delete_eq([V|Vs], Var, RVars).
select_var(ffc, [V|Vs], Var, RVars) :-
        find_ffc(Vs, V, Var),
        delete_eq([V|Vs], Var, RVars).

find_min([], Var, Var).
find_min([V|Vs], CM, Min) :-
        (   min_lt(V, CM) ->
            find_min(Vs, V, Min)
        ;   find_min(Vs, CM, Min)
        ).

find_max([], Var, Var).
find_max([V|Vs], CM, Max) :-
        (   max_gt(V, CM) ->
            find_max(Vs, V, Max)
        ;   find_max(Vs, CM, Max)
        ).

find_ff([], Var, _, Var).
find_ff([V|Vs], CM, S0, FF) :-
        (   nonvar(V) -> find_ff(Vs, CM, S0, FF)
        ;   (   fd_size_(V, n(S1)), S1 < S0 ->
                find_ff(Vs, V, S1, FF)
            ;   find_ff(Vs, CM, S0, FF)
            )
        ).

find_ffc([], Var, Var).
find_ffc([V|Vs], Prev, FFC) :-
        (   ffc_lt(V, Prev) ->
            find_ffc(Vs, V, FFC)
        ;   find_ffc(Vs, Prev, FFC)
        ).


ffc_lt(X, Y) :-
        (   fd_get(X, XD, XPs) ->
            domain_length(XD, n(NXD))
        ;   NXD = 1, XPs = []
        ),
        (   fd_get(Y, YD, YPs) ->
            domain_length(YD, n(NYD))
        ;   NYD = 1, YPs = []
        ),
        (   NXD < NYD -> true
        ;   NXD =:= NYD,
            propagators_number(XPs, NXPs),
            propagators_number(YPs, NYPs),
            NXPs > NYPs
        ).

min_lt(X,Y) :- bounds(X,LX,_), bounds(Y,LY,_), LX < LY.

max_gt(X,Y) :- bounds(X,_,UX), bounds(Y,_,UY), UX > UY.

bounds(X, L, U) :-
        (   fd_get(X, Dom, _) ->
            domain_infimum(Dom, n(L)),
            domain_supremum(Dom, n(U))
        ;   L = X, U = L
        ).

delete_eq([], _, []).
delete_eq([X|Xs], Y, List) :-
        (   nonvar(X) -> delete_eq(Xs, Y, List)
        ;   X == Y -> List = Xs
        ;   List = [X|Tail],
            delete_eq(Xs, Y, Tail)
        ).
