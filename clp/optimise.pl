/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Optimisation uses the clause database to save the computed extremum
   over backtracking. Failure is used to get rid of copies of
   attributed variables that are created in intermediate steps.

   Example:

     ?- X in 1..3, call_residue_vars(labeling([min(X)], [X]), Vs).
     %@    X = 1, Vs = []
     %@ ;  X = 2, Vs = []
     %@ ;  X = 3, Vs = []
     %@ ;  false.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- dynamic(extremum/1).

optimise(Vars, Options, Whats) :-
        Whats = [What|WhatsRest],
        asserta(extremum(mark)),
        (   catch(store_extremum(Vars, Options, What),
                  time_limit_exceeded,
                  false)
        ;   once(extremum(Val0)),
            retract_until_mark,
            Val0 = n(Val),
            arg(1, What, Expr),
            append(WhatsRest, Options, Options1),
            (   Expr #= Val,
                labeling(Options1, Vars)
            ;   Expr #\= Val,
                optimise(Vars, Options, Whats)
            )
        ).

retract_until_mark :-
        (   retract(extremum(E)), E == mark -> true
        ;   retract_until_mark
        ).

store_extremum(Vars, Options, What) :-
        catch((labeling(Options, Vars), throw(w(What))), w(What1), true),
        functor(What, Direction, _),
        maplist(arg(1), [What,What1], [Expr,Expr1]),
        optimise(Direction, Options, Vars, Expr1, Expr).

optimise(Direction, Options, Vars, Expr0, Expr) :-
        must_be(ground, Expr0),
        update_extremum(Expr0),
        catch((tighten(Direction, Expr, Expr0),
               labeling(Options, Vars),
               throw(v(Expr))), v(Expr1), true),
        optimise(Direction, Options, Vars, Expr1, Expr).


update_extremum(Expr) :-
        (   once(extremum(Prev)),
            Prev = n(_) ->
            once(retract(extremum(_)))
        ;   true
        ),
        asserta(extremum(n(Expr))).

tighten(min, E, V) :- E #< V.
tighten(max, E, V) :- E #> V.
