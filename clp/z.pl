% :- include("../core").
% :- include("../dcg").

:- include("header").
monotonic.
:- include("compatibility").
:- include("operators").
:- include("introduction").
:- include("duodcg").
:- include("attr").
% Domain
:- include("cis").
:- include("domain").
% Labeling
:- include("in").
:- include("labeling").
:- include("contracting").
:- include("fds_sespsize").
:- include("optimise").
% Global Constraints
:- include("difference").
% Scalar Product
:- include("scalar_product"). % linsum?
% Parse Arithmetic Constraints
:- include("parse_clpz").
:- include("leg"). % parsing? lng?
% Goal Expansion
:- include("clpz_expansion").
%%
:- include("linsum"). % scalar_product?
:- include("integer_tools").
:- include("lng"). % leg?
% Parse Reified Constraints
:- include("reifiable"). % parsing?
:- include("parse_reified_clpz").
:- include("reify").
:- include("reify_tuples_in"). % ??
:- include("skeleton").
:- include("drep"). % domain
:- include("fd"). % constraint propagation?
:- include("reinforce"). % constraint propagation?
% Constraint Propagation?
:- include("propagator0").
:- include("variants").
:- include("kill").
:- include("queue"). % propagator queue?
:- include("propagator1").
%%
:- include("lex_chain"). % export?
:- include("tuples_in"). % export?
:- include("run_propagator"). % constraint propagation?
:- include("add_mul_bounds").
:- include("internal_tools").
% Export
:- include("serialized").
:- include("element").
:- include("global_cardinality").
:- include("circuit").
:- include("cumulative").
:- include("disjoint2").
:- include("automaton").
:- include("zcompare").
:- include("chain").
%%
:- include("reflection").
:- include("entailment"). % unused?
:- include("uhcp"). % constraint propagation?
:- include("psp"). % scalar product?
:- include("reified").
:- include("generated").
