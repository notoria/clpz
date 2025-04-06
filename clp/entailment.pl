/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Entailment detection. Subject to change.

   Currently, Goals entail E if posting ({#\ E} U Goals), then
   labeling all variables, fails. E must be reifiable. Examples:

   %?- clpz:goals_entail([X#>2], X #> 3).
   %@ false.

   %?- clpz:goals_entail([X#>1, X#<3], X #= 2).
   %@ true.

   %?- clpz:goals_entail([X#=Y+1], X #= Y+1).
   %@ ERROR: Arguments are not sufficiently instantiated
   %@    Exception: (15) throw(error(instantiation_error, _G2680)) ?

   %?- clpz:goals_entail([[X,Y] ins 0..10, X#=Y+1], X #= Y+1).
   %@ true.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

goals_entail(Goals, E) :-
        must_be(list, Goals),
        \+ (   maplist(call, Goals), #\ E,
               term_variables(Goals-E, Vs),
               label(Vs)
           ).
