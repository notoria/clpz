% Ordines
% :- include("../../ordines/z").

% SICStus
:- use_module('../../sicstus/z').
% :- use_module(library(clpfd)). '@in'(D, V) :- V in D. :- op( 700, xfx, ins). Vs ins D :- list_map('@in'(D), Vs).
:- include("../utils").
:- include("../integer").
:- include("../../sicstus/compatibility").
:- use_module('../../sicstus/call_nth').
:- use_module('../../sicstus/countall').
% sicstus -f -l env/sicstus/iso.pl -l env/clp/test/serialized.pl

upper(Ss, U) :-
    (   foldl(succ, 0, U),
        Ss ins 0..U,
        \+ \+ labeling([], Ss)
    ->  true
    ).

test_serialized(L, N) :-
    list_length(Ss, L),
    list_equisized(Ss, Ds0),
    chain(#=<, Ds0),
    list_map(between(0, N), Ds0),
    list_equisized(Ds0, Ds),
    findall(
        U-C,
        (   list_foldl(list_select, Ds, Ds0, []),
            serialized(Ss, Ds),
            upper(Ss, U),
            countall(labeling([], Ss), C)
        ),
        UCs
    ),
    list_map(=(U-C), UCs),
    portray_clause(user_output, Ds0-U-C),
    false.
