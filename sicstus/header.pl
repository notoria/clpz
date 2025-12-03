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

:- module(clpz, [
    (#>)/2,
    (#<)/2,
    (#>=)/2,
    (#=<)/2,
    (#=)/2,
    (#\=)/2,
    (#\)/1,
    (#<==>)/2,
    (#==>)/2,
    (#<==)/2,
    (#\/)/2,
    (#\)/2,
    (#/\)/2,
    (in)/2,
    (ins)/2,
    all_different/1,
    all_distinct/1,
    nvalue/2,
    sum/3,
    scalar_product/4,
    tuples_in/2,
    labeling/2,
    label/1,
    indomain/1,
    lex_chain/1,
    serialized/2,
    global_cardinality/2,
    global_cardinality/3,
    circuit/1,
    cumulative/1,
    cumulative/2,
    disjoint2/1,
    element/3,
    automaton/3,
    automaton/8,
    zcompare/3,
    chain/2,
    fd_var/1,
    fd_inf/2,
    fd_sup/2,
    fd_size/2,
    fd_dom/2,

    % for use in predicates from library(reif)
    clpz_t/2,
    (#=)/3,
    (#<)/3

    % called from goal_expansion
    % clpz_equal/2,
    % clpz_geq/2
]).
