%% disjoint2(+Rectangles)
%
%  True iff Rectangles are not overlapping. Rectangles is a list of
%  terms of the form F(X_i, W_i, Y_i, H_i), where F is any functor,
%  and the arguments are finite domain variables or integers that
%  denote, respectively, the X coordinate, width, Y coordinate and
%  height of each rectangle.

disjoint2(Rs0) :-
        must_be(list, Rs0),
        list_map(=.., Rs0, Rs),
        non_overlapping(Rs).

non_overlapping([]).
non_overlapping([R|Rs]) :-
        list_map(non_overlapping_(R), Rs),
        non_overlapping(Rs).

non_overlapping_(A, B) :-
        a_not_in_b(A, B),
        a_not_in_b(B, A).

a_not_in_b([_,AX,AW,AY,AH], [_,BX,BW,BY,BH]) :-
        #AX #=< #BX #/\ #BX #< #AX + #AW #==>
                   #AY + #AH #=< #BY #\/ #BY + #BH #=< #AY,
        #AY #=< #BY #/\ #BY #< #AY + #AH #==>
                   #AX + #AW #=< #BX #\/ #BX + #BW #=< #AX.
