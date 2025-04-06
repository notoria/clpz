fd_get(X, Dom, Ps) :-
        (   get_attr(X, clpz, Attr) -> Attr = clpz_attr(_,_,_,Dom,Ps,_)
        ;   var(X) -> default_domain(Dom), Ps = fd_props([],[],[])
        ).

fd_get(X, Dom, Inf, Sup, Ps) :-
        fd_get(X, Dom, Ps),
        domain_infimum(Dom, Inf),
        domain_supremum(Dom, Sup).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Constraint propagation always terminates. Currently, this is
   ensured by allowing the left and right boundaries, as well as the
   distance between the smallest and largest number occurring in the
   domain representation to be changed at most once after a constraint
   is posted, unless the domain is bounded.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

fd_put(X, Dom, Ps) --> put_terminating(X, Dom, Ps).

fd_put(X, Dom, Ps) :-
        new_queue(Q),
        phrase((put_terminating(X, Dom, Ps),
%                { portray_clause(done_terminating) },
                do_queue), [Q], _).

put_terminating(X, Dom, Ps) -->
        Dom \== empty,
        (   Dom = from_to(F, F) -> queue_goal(F = n(X))
        ;   (   { get_attr(X, clpz, Attr) } ->
                { Attr = clpz_attr(Left,Right,Spread,OldDom, _OldPs,Q),
                  put_attr(X, clpz, clpz_attr(Left,Right,Spread,Dom,Ps,Q)) },
                (   { OldDom == Dom } -> []
                ;   { (   Left == (.) -> Bounded = yes
                      ;   domain_infimum(Dom, Inf),
                          domain_supremum(Dom, Sup),
                          (   Inf = n(_), Sup = n(_) ->
                              Bounded = yes
                          ;   Bounded = no
                          )
                    ) },
                    (   { Bounded == yes } ->
                        { put_attr(X, clpz, clpz_attr(.,.,.,Dom,Ps,Q)) },
                        trigger_props(Ps, X, OldDom, Dom)
                    ;   % infinite domain; consider border and spread changes
                        { domain_infimum(OldDom, OldInf),
                          (   Inf == OldInf -> LeftP = Left
                          ;   LeftP = yes
                          ),
                          domain_supremum(OldDom, OldSup),
                          (   Sup == OldSup -> RightP = Right
                          ;   RightP = yes
                          ),
                          domain_spread(OldDom, OldSpread),
                          domain_spread(Dom, NewSpread),
                          (   NewSpread == OldSpread -> SpreadP = Spread
                          ;   NewSpread cis_lt OldSpread -> SpreadP = no
                          ;   SpreadP = yes
                          ),
                          put_attr(X, clpz, clpz_attr(LeftP,RightP,SpreadP,Dom,Ps,Q)) },
                        (   { RightP == yes, Right = yes } -> []
                        ;   { LeftP == yes, Left = yes } -> []
                        ;   { SpreadP == yes, Spread = yes } -> []
                        ;   trigger_props(Ps, X, OldDom, Dom)
                        )
                    )
                )
            ;   { var(X) } ->
                { new_queue(Q),
                  put_attr(X, clpz, clpz_attr(no,no,no,Dom,Ps,Q)) }
            ;   []
            )
        ).

new_queue(queue(_Goals,_Fast,_Slow,_Aux)).

queue_goal(Goal) --> insert_queue(Goal, 1).
queue_fast(Prop) --> insert_queue(Prop, 2).
queue_slow(Prop) --> insert_queue(Prop, 3).

insert_queue(Element, Which) -->
        state(Queue),
        { arg(Which, Queue, Arg),
          (   get_atts(Arg, +queue(Head0,Tail0)) ->
              Head = Head0,
              Tail0 = [Element|Tail]
          ;   Head = [Element|Tail]
          ),
          put_atts(Arg, +queue(Head,Tail)) }.


domain_spread(Dom, Spread) :-
        domain_smallest_finite(Dom, S),
        domain_largest_finite(Dom, L),
        Spread cis L - S.

smallest_finite(inf, Y, Y).
smallest_finite(n(N), _, n(N)).

domain_smallest_finite(from_to(F,T), S)   :- smallest_finite(F, T, S).
domain_smallest_finite(split(_, L, _), S) :- domain_smallest_finite(L, S).

largest_finite(sup, Y, Y).
largest_finite(n(N), _, n(N)).

domain_largest_finite(from_to(F,T), L)   :- largest_finite(T, F, L).
domain_largest_finite(split(_, _, R), L) :- domain_largest_finite(R, L).
