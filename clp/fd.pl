fd_get(X, Dom, Ps) :-
    (   get_attr(X, clpz, Attr)
    ->  Attr = clpz_attr(_,_,_,Dom,Ps,_)
    ;   var(X)
    ->  portray_clause(user_output, unconstrained),
        domain_from_bounds(inf, sup, Dom),
        propagators_empty(Ps)
    ).
    % var(X),
    % (   get_atts(X, +clpz(Attr))
    % ->  Attr = clpz_attr(_,_,_,Dom,Ps,_)
    % ;   domain_from_bounds(inf, sup, Dom),
    %     propagators_empty(Ps)
    % ).

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
        queue_empty(Q),
        phrase((put_terminating(X, Dom, Ps),
%                { portray_clause(done_terminating) },
                propagator_catalyze), [Q], _).

put_terminating(X, Dom, Ps) -->
        { domain_empty(Dom, false) },
        % (   { domain_singleton(Dom, F) } -> queue_pgoal(F = n(X))
        ({ domain_singleton(Dom, n(I)) } -> queue_pgoal(X = I) ; []),
        (   (   { get_attr(X, clpz, Attr) } ->
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
                        propagators_queuegb(Ps, X, OldDom, Dom)
                    % ;   { put_attr(X, clpz, clpz_attr(yes,yes,yes,Dom,Ps,Q)) }
                    ;   % infinite domain; consider border and spread changes
                        { domain_infimum(OldDom, OldInf),
                          (   Inf == OldInf -> LeftP = Left
                          ;   LeftP = yes
                          ),
                          domain_supremum(OldDom, OldSup),
                          (   Sup == OldSup -> RightP = Right
                          ;   RightP = yes
                          ),
                          % domain_spread(OldDom, OldSpread),
                          % domain_spread(Dom, NewSpread),
                          % (   NewSpread == OldSpread -> SpreadP = Spread
                          % ;   NewSpread cis_lt OldSpread -> SpreadP = no
                          % ;   SpreadP = yes
                          % ),
                          SpreadP = no,
                          put_attr(X, clpz, clpz_attr(LeftP,RightP,SpreadP,Dom,Ps,Q)) },
                        (   { RightP == yes, Right = yes } -> []
                        ;   { LeftP == yes, Left = yes } -> []
                        ;   { SpreadP == yes, Spread = yes } -> []
                        ;   propagators_queuegb(Ps, X, OldDom, Dom)
                        )
                    )
                )
            ;   { var(X) } ->
                { queue_empty(Q),
                  put_attr(X, clpz, clpz_attr(no,no,no,Dom,Ps,Q)) }
            ;   [] % QUESTION: why?
            )
        ).
