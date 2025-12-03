/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if_/3
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

if_(Test_1, Then_0, Else_0) :-
    call(Test_1, T),
    (   var(T)
    ->  throw(error(instantiation_error,if_/2))
    ;   T == true
    ->  call(Then_0)
    ;   T == false
    ->  call(Else_0)
    ;   throw(error(type_error(boolean,T),if_/2))
    ).

','(G0_1, G1_1, T) :-
    if_(G0_1, if_(G1_1, T = true, T = false), T = false).

';'(G0_1, G1_1, T) :-
    if_(G0_1, T = true, if_(G1_1, T = true, T = false)).
