:- include("core").
:- include("dcg").

% freezer(X0, X1, Gs0, Gs) :-
%     (   get_attribute(+, X0, frozen(G0))
%     ->  (   var(X1)
%         ->  (   get_attribute(+, X1, frozen(G1))
%             ->  put_attribute(+, X1, frozen((G1,G0)))
%             ;   put_attribute(+, X1, frozen(G0))
%             ),
%             Gs = Gs0
%         ;   [G0|Gs] = Gs0
%         )
%     ;   Gs = Gs0
%     ).

freezer(X0, X1) -->
    (   { get_attribute(+, X0, frozen(G0)) }
    ->  (   { var(X1) }
        ->  {   get_attribute(+, X1, frozen(G1))
            ->  put_attribute(+, X1, frozen((G1,G0)))
            ;   put_attribute(+, X1, frozen(G0)),
                put_verifier(+, X1, freezer),
                put_reifier(+, X1, frozen)
            }
        ;   [G0]
        )
    ;   []
    ).

freeze(X, G) :-
    (   var(X)
    ->  put_attribute(+, Y, frozen(G)),
        put_verifier(+, Y, freezer),
        put_reifier(+, Y, frozen),
        Y = X % Best/"Right" orientation
        % X = Y
    ;   call(G)
    ).

frozen(X) -->
    { get_attribute(+, X, frozen(G)) },
    [freeze:freeze(X, G)].

