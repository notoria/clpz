% Ordines
:- include("../../ordines/z").
%:- include("../../ordines/clpz").

% SICStus
% :- include("../utils").
% :- include("../integer").
% :- include("../../sicstus/compatibility").
% :- use_module('../../sicstus/call_nth').
% sicstus -f -l env/sicstus/iso.pl -l env/sicstus/z.pl -l env/clp/test/simple.pl

test((#>)/2, 0) :-
    \+ #0 #> #1.
test((#>)/2, 1) :-
    #1 #> #0.
test((#>)/2, 2) :-
    #_ #> #0.
test((#>)/2, 3) :-
    #0 #> #_.
test((#>)/2, 4) :-
    #0 #> #_.
test((#>)/2, 5) :-
    #_ #> #_.
test((#>)/2, 6) :-
    \+ #A #> #A.
test((#<)/2, 0) :-
    #0 #< #1.
test((#<)/2, 1) :-
    \+ #1 #< #0.
test((#<)/2, 2) :-
    #_ #< #0.
test((#<)/2, 3) :-
    #0 #< #_.
test((#<)/2, 4) :-
    #0 #< #_.
test((#<)/2, 5) :-
    #_ #< #_.
test((#<)/2, 6) :-
    \+ #A #< #A.
test((#>=)/2, 0) :-
    \+ #0 #>= #1.
test((#>=)/2, 1) :-
    #1 #>= #0.
test((#>=)/2, 2) :-
    #_ #>= #0.
test((#>=)/2, 3) :-
    #0 #>= #_.
test((#>=)/2, 4) :-
    #_ #>= #_.
test((#>=)/2, 5) :-
    #A #>= #A.
test((#=<)/2, 0) :-
    #0 #=< #1.
test((#=<)/2, 1) :-
    \+ #1 #=< #0.
test((#=<)/2, 2) :-
    #_ #=< #0.
test((#=<)/2, 3) :-
    #0 #=< #_.
test((#=<)/2, 4) :-
    #_ #=< #_.
test((#=<)/2, 5) :-
    #A #=< #A.
test((#=)/2, 0) :-
    \+ #0 #= #1.
test((#=)/2, 1) :-
    \+ #1 #= #0.
test((#=)/2, 2) :-
    #_ #= #0.
test((#=)/2, 3) :-
    #0 #= #_.
test((#=)/2, 5) :-
    #_ #= #_.
test((#=)/2, 6) :-
    #A #= #A.
test((#\=)/2, 0) :-
    #0 #\= #1.
test((#\=)/2, 1) :-
    #1 #\= #0.
test((#\=)/2, 2) :-
    #_ #\= #0.
test((#\=)/2, 3) :-
    #0 #\= #_.
test((#\=)/2, 5) :-
    #_ #\= #_.
test((#\=)/2, 6) :-
    \+ #A #\= #A.
test((#\)/1, 0) :-
    #\ #0.
test((#\)/1, 1) :-
    #\ #1.
test((#\)/1, 2) :-
    #\ #_.
test((#<==>)/2, 0) :-
    #0 #<==> #0.
test((#<==>)/2, 1) :-
    \+ #0 #<==> #1.
test((#<==>)/2, 2) :-
    \+ #1 #<==> #0.
test((#<==>)/2, 3) :-
    #1 #<==> #1.
test((#<==>)/2, 4) :-
    #_ #<==> #_.
test((#==>)/2, 0) :-
    #0 #==> #0.
test((#==>)/2, 1) :-
    #0 #==> #1.
test((#==>)/2, 2) :-
    \+ #1 #==> #0.
test((#==>)/2, 3) :-
    #1 #==> #1.
test((#==>)/2, 4) :-
    #_ #==> #_.
test((#<==)/2, 0) :-
    false,
    throw(unimplemented).
test((#\/)/2, 0) :-
    \+ #0 #\/ #0.
test((#\/)/2, 1) :-
    #1 #\/ #0.
test((#\/)/2, 2) :-
    #0 #\/ #1.
test((#\/)/2, 3) :-
    #1 #\/ #1.
test((#\/)/2, 4) :-
    #_ #\/ #_.
test((#\)/2, 0) :-
    false,
    throw(unimplemented).
test((#/\)/2, 0) :-
    \+ #0 #/\ #0.
test((#/\)/2, 1) :-
    \+ #0 #/\ #1.
test((#/\)/2, 2) :-
    \+ #1 #/\ #0.
test((#/\)/2, 3) :-
    #1 #/\ #1.
test((#/\)/2, 4) :-
    #_ #/\ #_.
test((in)/2, 0) :-
    _ in 0..1.
test((ins)/2, 0) :-
    Vs = [_,_,_],
    Vs ins 0..1.
test(all_different/1, 0) :-
    Vs = [_,_,_],
    all_different(Vs).
test(all_different/1, 1) :-
    Vs = [_,_,_],
    all_different(Vs),
    \+ Vs = [0,0,_].
test(all_distinct/1, 0) :-
    Vs = [_,_,_],
    all_distinct(Vs).
test(nvalue/2, 0) :-
    Vs = [_,_,_],
    nvalue(2, Vs).
test(sum/3, 0) :-
    false,
    throw(unimplemented).
test(scalar_product/4, 0) :-
    false,
    throw(unimplemented).
test(tuples_in/2, 0) :-
    tuples_in([[_,_]], [[1,2],[1,5],[4,0],[4,3]]).
test(labeling/2, 0) :-
    X in 0..1,
    \+ \+ labeling([], [X]).
test(label/1, 0) :-
    X in 0..1,
    \+ \+ label([X]).
test(indomain/1, 0) :-
    X in 0..1,
    \+ \+ indomain(X).
test(lex_chain/1, 0) :-
    lex_chain([[_,_],[_,_]]).
test(serialized/2, 0) :-
    Vs = [_,_,_],
    Vs ins 0..3,
    serialized(Vs, [1,2,3]),
    \+ \+ label(Vs).
test(global_cardinality/2, 0) :-
    Vs = [_,_,_],
    global_cardinality(Vs, [1-2,3-_]),
    \+ \+ label(Vs).
test(global_cardinality/3, 0) :-
    false,
    throw(unimplemented).
test(circuit/1, 0) :-
    Vs = [_,_,_],
    circuit(Vs),
    \+ \+ label(Vs).
test(cumulative/2, 0) :-
    % slow
    false,
    Ss = [S0,S1,S2],
    Ss ins 0..4,
    Ts = [task(S0,3,_,1,_),task(S1,2,_,1,_),task(S2,2,_,1,_)],
    cumulative(Ts, [limit(2)]).
    % * \+ \+ label(Ss).
test(disjoint2/1, 0) :-
    Ds = [d(0,1,0,1),d(1,1,1,1)],
    disjoint2(Ds).
% ?- element(A, [2,2,3], B), B = 2. % weak result.
test(element/3, 0) :-
    element(_, [2,3,5], _).
test(element/3, 1) :-
    \+ element(0, [2,3,5], _).
% test(element/3, 2) :-
%     \+ element(0, [2,3,5], _).
test(automaton/3, 0) :-
    Vs = [_,_,_],
    Ns = [source(a),sink(c)],
    As = [arc(a,0,a),arc(a,1,b),arc(b,0,a),arc(b,1,c),arc(c,0,c),arc(c,1,c)],
    automaton(Vs, Ns, As).
test(automaton/8, 0) :-
    false,
    throw(unimplemented).
test(zcompare/3, 0) :-
    zcompare(<, 0, 1).
test(chain/2, 0) :-
    chain(#<, []).
test(chain/2, 1) :-
    chain(#<, [0]).
test(chain/2, 2) :-
    chain(#<, [0,1]).
test(chain/2, 3) :-
    \+ chain(#<, [0,0]).
test(fd_var/1, 0) :-
    A in 0..1,
    fd_var(A),
    \+ fd_var(_).
test(fd_inf/2, 0) :-
    A in 0..1,
    fd_inf(A, 0).
test(fd_sup/2, 0) :-
    A in 0..1,
    fd_sup(A, 1).
test(fd_size/2, 0) :-
    A in 0..1,
    fd_size(A, 2).
test(fd_dom/2, 0) :-
    A in 0..1,
    fd_dom(A, 0..1).
