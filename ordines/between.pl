between(L, U, I) :-
    integer(L),
    integer(U),
    L @=< U,
    (   var(I)
    ->  '@between'(L, U, I)
    ;   integer(I),
        L @=< I,
        I @=< U
    ).

'@between'(L, U, I) :-
    (   L == U
    ->  I = L
    ;   I = L
    ;   M is L+1,
        '@between'(M, U, I)
    ).
