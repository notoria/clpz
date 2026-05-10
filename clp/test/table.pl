% Ordines
% :- include("../../ordines/z").

% SICStus
% :- use_module('../../sicstus/z').
:- use_module(library(clpfd)). '@in'(D, V) :- V in D. :- op( 700, xfx, ins). Vs ins D :- list_map('@in'(D), Vs). tuples_in(Vss, Tss) :- table(Vss, Tss).
:- include("../utils").
:- include("../integer").
:- include("../../sicstus/compatibility").
:- use_module('../../sicstus/call_nth').
:- use_module('../../sicstus/countall').
% sicstus -f -l env/sicstus/iso.pl -l env/clp/test/table.pl

generate(N, Ts0, Tss) :-
    copy_term(Ts0, Ts),
    list_map(between(0, N), Ts),
    [Ts|_] = Tss,
    list_chain('@generate'(N), Tss).

'@generate'(N, Ts0, Ts) :-
    list_equisized(Ts0, Ts),
    list_map(between(0, N), Ts),
    Ts0 @< Ts.

test_table(L, N) :-
    % L #=< N,
    list_length(Vs, L),
    generate(N, Vs, Tss),
    tuples_in([Vs], Tss),
    % portray_clause(user_error, Tss),
    % findall(., labeling([], Vs), Es), list_length(Es, C),
    countall(labeling([], Vs), C),
    portray_clause(user_output, C),
    false.
