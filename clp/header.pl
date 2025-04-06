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


:- include("../core").
:- include("../assoc").
:- include("../pairs").
:- include("../lists").
:- include("../atts").
:- include("../dcg").
:- include("../error").
:- include("../freeze").

:- module(clpz, [
                 op(760, yfx, #<==>),
                 op(750, xfy, #==>),
                 op(750, yfx, #<==),
                 op(740, yfx, #\/),
                 op(730, yfx, #\),
                 op(720, yfx, #/\),
                 op(710,  fy, #\),
                 op(700, xfx, #>),
                 op(700, xfx, #<),
                 op(700, xfx, #>=),
                 op(700, xfx, #=<),
                 op(700, xfx, #=),
                 op(700, xfx, #\=),
                 op(700, xfx, in),
                 op(700, xfx, ins),
                 op(450, xfx, ..), % should bind more tightly than \/
                 op(150, fx, #),
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


:- use_module(library(assoc), [empty_assoc/1,assoc_to_list/2,get_assoc/3,put_assoc/4]).
:- use_module(library(pairs), [pairs_keys_values/3,pairs_keys/2,pairs_values/2,map_list_to_pairs/3]).
:- use_module(library(between), [between/3]).
:- use_module(library(lists), [append/2,append/3,foldl/4,foldl/5,maplist/2,maplist/3,maplist/4,member/2,select/3,same_length/2,sum_list/2,reverse/2,nth0/3,nth1/3,length/2]).
:- use_module(library(atts)).
:- use_module(library(iso_ext)).
:- use_module(library(dcgs), [phrase/2,phrase/3]).
% :- use_module(library(terms)).
:- use_module(library(error), [domain_error/3,type_error/3,can_be/2]).
:- use_module(library(si), [list_si/1]).
:- use_module(library(freeze)).
:- use_module(library(debug)).
:- use_module(library(format)).

% :- use_module(library(types)).

:- attribute
        clpz/1,
        clpz_aux/1,
        clpz_relation/1,
        edges/1,
        flow/1,
        parent/1,
        free/1,
        g0_edges/1,
        used/1,
        lowlink/1,
        value/1,
        visited/1,
        index/1,
        in_stack/1,
        clpz_gcc_vs/1,
        clpz_gcc_num/1,
        clpz_gcc_occurred/1,
        queue/2,
        disabled/0.

:- dynamic(monotonic/0).
:- dynamic(clpz_equal_/2).
:- dynamic(clpz_geq_/2).
:- dynamic(clpz_neq/2).
