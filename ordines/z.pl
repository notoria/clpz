/*  CLP(ℤ): Constraint Logic Programming over Integers.

    Author:        Markus Triska
    E-mail:        triska@metalevel.at
    WWW:           https://www.metalevel.at
    Copyright (C): 2016-2024 Markus Triska

    This library provides CLP(ℤ):

              Constraint Logic Programming over Integers
              ==========================================

    Highlights:

    -) DECLARATIVE implementation of integer arithmetic.
    -) Fully relational, MONOTONIC execution mode.
    -) Always TERMINATING labeling.


    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use, copy,
    modify, merge, publish, distribute, sublicense, and/or sell copies
    of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.

*/

:- flag(occurs_check, false).

:- include("../core").

% Tools
:- include("../reif").
:- include("compatibility").
:- include("../clp/utils").
%
:- include("../clp/operators").
:- include("../clp/declarations").
:- include("../clp/introduction").
:- include("../clp/duodcg").
:- include("attr").
% Domain
:- include("../clp/integer").
:- include("../clp/bound").
:- include("../clp/cis").
:- include("../clp/interval").
:- include("../clp/domain").
:- include("../clp/drep").
% Queue
:- include("../clp/queue").
%
:- include("../clp/fd"). % constraint propagation?
% Reflection
:- include("../clp/reflection").
% Reinforce
:- include("../clp/reinforce"). % constraint propagation?
% Labeling
:- include("../clp/membership"). % Membership Constraints.
:- include("../clp/labeling").
:- include("../clp/contracting").
:- include("../clp/fds_sespsize").
:- include("../clp/optimise").
% Global Constraints
:- include("../clp/difference"). % Arithmetic-Logical Constraints.
% Scalar Product
:- include("../clp/scalar_product"). % linsum?
% Parse Arithmetic Constraints
:- include("../clp/parse_clpz").
:- include("../clp/arithmetic"). % Arithmetic Constraints.
% Goal Expansion
% :- include("../clp/clpz_expansion").
%%
:- include("../clp/linsum"). % scalar_product?
% Parse Reified Constraints
:- include("../clp/propositional"). % 	Propositional Constraints.
% :- include("../clp/reifiable"). % parsing?
:- include("../clp/parse_reified_clpz").
:- include("../clp/reify").
:- include("../clp/reify_tuples_in"). % ??
:- include("../clp/skeleton").
% Constraint & Propagation
:- include("../clp/constraint").
:- include("../clp/variants").
:- include("../clp/kill").
:- include("../clp/propagator").
:- include("../clp/propagate").
:- include("../clp/add_mul_bounds").
:- include("../clp/internal_tools").
% Export
:- include("../clp/tuples_in"). % Extensional Constraints.
:- include("../clp/lex_chain"). % Arithmetic-Logical Constraints.
:- include("../clp/serialized"). % Scheduling Constraints?
:- include("../clp/element"). % Extensional Constraints.
:- include("../clp/global_cardinality"). % Arithmetic-Logical Constraints.
:- include("../clp/circuit"). % Graph Constraints.
:- include("../clp/cumulative"). % Scheduling Constraints.
:- include("../clp/disjoint2"). % Placement Constraints.
:- include("../clp/automaton"). % Sequence Constraints.
:- include("../clp/zcompare").
:- include("../clp/chain").
%%
:- include("../clp/entailment"). % unused?
:- include("../clp/uhcp"). % verifier, reifier
:- include("../clp/psp"). % scalar product?
:- include("../clp/reified").
:- include("../clp/generated").
?- true.
