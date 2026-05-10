% Ordines
%:- include("../../ordines/z").

% SICStus
:- include("../utils").
:- include("../integer").
:- include("../../sicstus/compatibility").
:- use_module('../../sicstus/call_nth').
% sicstus -f -l env/sicstus/iso.pl -l env/sicstus/z.pl -l env/clp/test/element.pl

unfold_conjunction(G) -->
    (   { G == true }
    ->  []
    ;   { \+ subsumes_term((_,_), G) }
    ->  [G]
    ;   { G = (G0,G1) },
        unfold_conjunction(G0),
        unfold_conjunction(G1)
    ).

'@answer'(G, Gs) :-
    (   G \= [],
        G \= [_|_]
    ->  phrase(unfold_conjunction(G), Gs)
    ;   Gs = G
    ).

answer(E, Vs, Gs) :-
    copy_term(E, F, Gs0),
    '@answer'(Gs0, Gs1),
    term_variables(F+Gs0, Vs),
    Gs = Gs1.

test :-
    Es = [_,_,_,_],
    G = element(_,Es,_),
    term_variables(G, Vs),
    list_map(list_element([_,1,2,4]), Vs),
    call(G),
    answer(G, Ws, Gs),
    portray_clause(user_output, [G,Ws,Gs]),
    false.
