portray_propagator(propagator(P,_), F) :- functor(P, F, _).

init_propagator_([], _) --> [].
init_propagator_([V|Vs], Prop) -->
        (   { fd_get(V, Dom, Ps0) } ->
            { insert_propagator(Prop, Ps0, Ps) },
            fd_put(V, Dom, Ps)
        ;   []
        ),
        init_propagator_(Vs, Prop).

init_propagator(Var, Prop) :-
        (   fd_get(Var, Dom, Ps0) ->
            insert_propagator(Prop, Ps0, Ps),
            fd_put(Var, Dom, Ps)
        ;   true
        ).

constraint_wake(pneq, ground).
constraint_wake(x_neq_y_plus_z, ground).
constraint_wake(absdiff_neq, ground).
constraint_wake(pdifferent, ground).
constraint_wake(pexclude, ground).
constraint_wake(scalar_product_neq, ground).
constraint_wake(x_eq_abs_plus_v, ground).

constraint_wake(x_leq_y_plus_c, bounds).
constraint_wake(scalar_product_eq, bounds).
constraint_wake(scalar_product_leq, bounds).
constraint_wake(pplus, bounds).
constraint_wake(pgeq, bounds).
constraint_wake(pgcc_single, bounds).
constraint_wake(pgcc_check_single, bounds).

global_constraint(pdistinct).
global_constraint(pnvalue).
global_constraint(pgcc).
global_constraint(pgcc_single).
global_constraint(pcircuit).
%global_constraint(rel_tuple).
%global_constraint(scalar_product_eq).

insert_propagator(Prop, Ps0, Ps) :-
        Ps0 = fd_props(Gs,Bs,Os),
        arg(1, Prop, Constraint),
        functor(Constraint, F, _),
        (   constraint_wake(F, ground) ->
            Ps = fd_props([Prop|Gs], Bs, Os)
        ;   constraint_wake(F, bounds) ->
            Ps = fd_props(Gs, [Prop|Bs], Os)
        ;   Ps = fd_props(Gs, Bs, [Prop|Os])
        ).
