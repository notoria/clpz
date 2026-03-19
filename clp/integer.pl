/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Integer
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

integer(I, _) :-
    var(I),
    throw(error(instantiation_error,integer/2)).
integer(I, Truth) :-
    (   integer(I)
    ->  Truth = true
    ;   Truth = false
    ).

% integer_compare(_, A, B) :-
%     member(C, [A,B]),
%     nonvar(C),
%     \+ integer(C),
%     !,
%     false.
integer_compare(_, A, B) :-
    var(A),
    var(B),
    throw(error(instantiation_error,integer_compare/3)).
integer_compare(_, A, B) :-
    var(A),
    integer(B),
    throw(error(instantiation_error,integer_compare/3)).
integer_compare(_, A, B) :-
    integer(A),
    var(B),
    throw(error(instantiation_error,integer_compare/3)).
integer_compare(O, A, B) :-
    '@integer_compare'(O, A, B).

'@integer_compare'(O, A, B) :-
    integer(A),
    integer(B),
    compare(O, A, B).

'@integer_compare'(>, A, B, B, A).
'@integer_compare'(=, A, A, A, A).
'@integer_compare'(<, A, B, A, B).

integer_compare(O, A0, B0, A, B) :-
    integer_compare(O, A0, B0),
    '@integer_compare'(O, A0, B0, A, B).

integer_eq(A, B) :-
    integer_compare(=, A, B).

integer_ne(A, B) :-
    \+ integer_compare(=, A, B).

integer_lt(A, B) :-
    integer_compare(<, A, B).

integer_le(A, B) :-
    integer_compare(_, A, B, A, B).

integer_ge(A, B) :-
    integer_compare(_, A, B, B, A).

integer_gt(A, B) :-
    integer_compare(>, A, B).

integer_if(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_if/3)).
integer_if(0, _, Else_0) :-
    call(Else_0).
integer_if(1, Then_0, _) :-
    call(Then_0).

% integer_cmp(A < B, Truth) :-
%     integer_compare(O, A, B),
%     '@integer_less'(O, A, B, Truth).
% 
% '@integer_less'(>, _, _, false).
% '@integer_less'(=, A, A, false).
% '@integer_less'(<, _, _, true).

integer_eq(A, B, Truth) :-
    integer_compare(O, A, B),
    '@integer_eq'(O, A, B, Truth).

'@integer_eq'(>, _, _, false).
'@integer_eq'(=, A, A,  true).
'@integer_eq'(<, _, _, false).

integer_ne(A, B, Truth) :-
    if_(integer_eq(A, B), Truth = false, Truth = true).

integer_le(A, B, Truth) :-
    integer_compare(O, A, B),
    '@integer_le'(O, A, B, Truth).

'@integer_le'(>, _, _, false).
'@integer_le'(=, A, A,  true).
'@integer_le'(<, _, _,  true).

integer_ge(A, B, Truth) :-
    integer_le(B, A, Truth).

integer_lt(A, B, Truth) :-
    if_(integer_ge(A, B), Truth = false, Truth = true).

integer_gt(A, B, Truth) :-
    integer_lt(B, A, Truth).

% integer_between(L, U, I) :-
%     member(T, [L,U,I]),
%     nonvar(T),
%     \+ integer(T),
%     !,
%     false.
integer_between(L, U, _) :-
    var(L),
    var(U),
    throw(error(instantiation_error,integer_between/3)).
integer_between(L, U, _) :-
    var(L),
    integer(U),
    throw(error(instantiation_error,integer_between/3)).
integer_between(L, U, _) :-
    integer(L),
    var(U),
    throw(error(instantiation_error,integer_between/3)).
integer_between(L, U, I) :-
    integer(L),
    integer(U),
    L @=< U,
    (   var(I)
    ->  '@integer_between'(L, U, I)
    ;   integer(I),
        L @=< I,
        I @=< U
    ).

'@integer_between'(L, U, I) :-
    (   L == U
    ->  I = L
    ;   I = L
    ;   M is L+1,
        '@integer_between'(M, U, I)
    ).

% integer_neg(A, B) :-
%     member(C, [A,B]),
%     nonvar(C),
%     \+ integer(C),
%     !,
%     false.
integer_neg(A, B) :-
    var(A),
    var(B),
    throw(error(instantiation_error,integer_neg/2)).
integer_neg(A, B) :-
    once('@integer_neg'(A, B)).

'@integer_neg'(A, B) :-
    var(A),
    integer(B),
    A is -B.
'@integer_neg'(A, B) :-
    % var(B),
    nonvar(A), integer(A),
    B is -A.

% integer_abs(A, B) :-
%     member(C, [A,B]),
%     nonvar(C),
%     \+ integer(C),
%     !,
%     false.
integer_abs(_, B) :-
    nonvar(B),
    B @< 0,
    !,
    false.
integer_abs(A, _) :-
    var(A),
    throw(error(instantiation_error,integer_abs/2)).
integer_abs(A, B) :-
    '@integer_abs'(A, B).

'@integer_abs'(A, B) :-
    B is abs(A).

% integer_sgn(A, B) :-
%     member(C, [A,B]),
%     nonvar(C),
%     \+ integer(C),
%     !,
%     false.
integer_sgn(_, B) :-
    nonvar(B),
    \+ member(B, [-1,0,1]),
    !,
    false.
integer_sgn(A, _) :-
    var(A),
    throw(error(instantiation_error,integer_sgn/2)).
integer_sgn(A, B) :-
    '@integer_sgn'(A, B).

'@integer_sgn'(A, B) :-
    B is sign(A).

% integer_lsb(A, B) :-
%     member(C, [A,B]),
%     nonvar(C),
%     \+ integer(C),
%     !,
%     false.
% integer_lsb(_, B) :-
%     nonvar(B),
%     B @< 0,
%     !,
%     false.
integer_lsb(A, _) :-
    var(A),
    throw(error(instantiation_error,integer_lsb/2)).
integer_lsb(A, B) :-
    '@integer_lsb'(A, B).

'@integer_lsb'(A, B) :-
    B is msb(A/\(\A+1)).

% integer_msb(A, B) :-
%     member(C, [A,B]),
%     nonvar(C),
%     \+ integer(C),
%     !,
%     false.
% integer_msb(_, B) :-
%     nonvar(B),
%     B @< 0,
%     !,
%     false.
integer_msb(A, _) :-
    var(A),
    throw(error(instantiation_error,integer_msb/2)).
integer_msb(A, B) :-
    '@integer_msb'(A, B).

'@integer_msb'(A, B) :-
    B is msb(A).

% integer_ct1(A, B) :-
%     member(C, [A,B]),
%     nonvar(C),
%     \+ integer(C),
%     !,
%     false.
% integer_ct1(_, B) :-
%     nonvar(B),
%     B @< 0,
%     !,
%     false.
integer_ct1(A, _) :-
    var(A),
    throw(error(instantiation_error,integer_ct1/2)).
integer_ct1(A, B) :-
    '@integer_ct1'(A, B).

% '@integer_ct1'(A, B) :-
%     B is popcount(A).
'@integer_ct1'(A, B) :-
    compare(O, 0, A),
    '@integer_ct1'(O, A, 0, B).

'@integer_ct1'(=, 0, S, S).
'@integer_ct1'(<, N0, S0, S) :-
    N is N0/\(N0-1),
    S1 is 1+S0,
    compare(O, 0, N),
    '@integer_ct1'(O, N, S1, S).

% integer_add(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_add(A, B, _) :-
    var(A),
    var(B),
    throw(error(instantiation_error,integer_add/3)).
integer_add(A, _, C) :-
    var(A),
    var(C),
    throw(error(instantiation_error,integer_add/3)).
integer_add(_, B, C) :-
    var(B),
    var(C),
    throw(error(instantiation_error,integer_add/3)).
integer_add(A, B, C) :-
    once('@integer_add'(A, B, C)).

'@integer_add'(A, B, C) :-
    var(A),
    integer(B),
    integer(C),
    A is C-B.
'@integer_add'(A, B, C) :-
    var(B),
    integer(C),
    integer(A),
    B is C-A.
'@integer_add'(A, B, C) :-
    % var(C),
    nonvar(A), integer(A),
    nonvar(B), integer(B),
    C is A+B.

% integer_mul(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_mul(A, B, _) :-
    var(A),
    var(B),
    throw(error(instantiation_error,integer_mul/3)).
integer_mul(A, _, C) :-
    var(A),
    var(C),
    throw(error(instantiation_error,integer_mul/3)).
integer_mul(_, B, C) :-
    var(B),
    var(C),
    throw(error(instantiation_error,integer_mul/3)).
integer_mul(A, B, C) :-
    once('@integer_mul'(A, B, C)).

'@integer_mul'(A, B, C) :-
    var(A),
    integer(B),
    integer(C),
    0 is C mod B,
    A is C div B.
'@integer_mul'(A, B, C) :-
    var(B),
    integer(C),
    integer(A),
    0 is C mod A,
    B is C div A.
'@integer_mul'(A, B, C) :-
    % var(C),
    nonvar(A), integer(A),
    nonvar(B), integer(B),
    C is A*B.

% integer_ddqr(_, A, B, C, D) :-
%     member(E, [A,B,C,D]),
%     nonvar(E),
%     \+ integer(E),
%     !,
%     false.
integer_ddqr(M, _, _, _, _) :-
    var(M),
    throw(error(instantiation_error,integer_ddqr/5)).
integer_ddqr(_, A, _, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_ddqr/5)).
integer_ddqr(_, _, B, _, _) :-
    var(B),
    throw(error(instantiation_error,integer_ddqr/5)).
integer_ddqr(M, A, B, C, D) :-
    '@integer_ddqr'(M, A, B, C, D).

'@integer_ddqr'( ceil, A, B, C, D) :-
    C is -(-A div B),
    D is A-B*C.
'@integer_ddqr'(trunc, A, B, C, D) :-
    S is sign(A)*sign(B),
    C is S*(abs(A) div abs(B)),
    D is A-B*C.
'@integer_ddqr'(floor, A, B, C, D) :-
    C is A div B,
    D is A mod B.

% integer_exp(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_exp(A, B, _) :-
    var(A),
    var(B),
    throw(error(instantiation_error,integer_exp/3)).
integer_exp(A, _, C) :-
    var(A),
    var(C),
    throw(error(instantiation_error,integer_exp/3)).
integer_exp(_, B, C) :-
    var(B),
    var(C),
    throw(error(instantiation_error,integer_exp/3)).
integer_exp(A, B, C) :-
    '@integer_exp'(A, B, C).

'@integer_exp'(A, B, C) :-
    (abs(A) =:= 1 -> true ; 0 @=< B),
    C is A^B.

% integer_gcd(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_gcd(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_gcd/3)).
integer_gcd(_, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_gcd/3)).
integer_gcd(A, B, C) :-
    '@integer_gcd'(A, B, C).

'@integer_gcd'(A, B, C) :-
    C is gcd(A,B).

% integer_lcm(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_lcm(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_lcm/3)).
integer_lcm(_, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_lcm/3)).
integer_lcm(A, B, C) :-
    '@integer_lcm'(A, B, C).

'@integer_lcm'(A, B, C) :-
    C is abs(A*B) div max(1,gcd(A,B)).
    % C is max(abs(A),abs(B)) div max(1,gcd(A,B))*min(abs(A),abs(B)).

% integer_min(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_min(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_min/3)).
integer_min(_, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_min/3)).
integer_min(A, B, C) :-
    '@integer_min'(A, B, C).

'@integer_min'(A, B, C) :-
    C is min(A,B).

% integer_max(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_max(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_max/3)).
integer_max(_, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_max/3)).
integer_max(A, B, C) :-
    '@integer_max'(A, B, C).

'@integer_max'(A, B, C) :-
    C is max(A,B).

% integer_nrt(_, A, B, C) :-
%     member(E, [A,B,C]),
%     nonvar(E),
%     \+ integer(E),
%     !,
%     false.
integer_nrt(M, _, _, _) :-
    var(M),
    throw(error(instantiation_error,integer_nrt/5)).
integer_nrt(_, A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_nrt/5)).
integer_nrt(_, _, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_nrt/5)).
integer_nrt(M, A, B, C) :-
    A @> 0,
    B @>= 0,
    once('@integer_nrt'(M, A, B, C)).

% C ^ A #= B
'@integer_nrt'( ceil, A, B, C) :-
    (   % '@integer_ddqr'(ceil, B, 2, Z0, _),
        % Zs = [Z0|_],
        % list_chain('@@integer_nrt'(A, B), Zs),
        % list_append(_, [Z1,Z2], Zs),
        '@integer_add'(1, B, Y0), '@integer_msb'(Y0, Y1), '@integer_add'(1, Y1, Y2), '@integer_ddqr'(ceil, Y2, A, Y3, _), '@integer_exp'(2, Y3, Y4),
        '@integer_ddqr'(ceil, B, 2, Y5, _), '@integer_min'(Y4, Y5, Z0),
        '@@@integer_nrt'(A, B, B-Z0, Z1-Z2),
        Z1 @=< Z2
    ->  (   '@integer_exp'(Z1, A, Z3),
            B @=< Z3
        ->  C = Z1
        ;   '@integer_add'(1, Z1, C)
        )
    ).
'@integer_nrt'(floor, A, B, C) :-
    (   % '@integer_ddqr'(ceil, B, 2, Z0, _),
        % Zs = [Z0|_],
        % list_chain('@@integer_nrt'(A, B), Zs),
        % list_append(_, [Z1,Z2], Zs),
        '@integer_add'(1, B, Y0), '@integer_msb'(Y0, Y1), '@integer_add'(1, Y1, Y2), '@integer_ddqr'(ceil, Y2, A, Y3, _), '@integer_exp'(2, Y3, Y4),
        '@integer_ddqr'(ceil, B, 2, Y5, _), '@integer_min'(Y4, Y5, Z0),
        '@@@integer_nrt'(A, B, B-Z0, Z1-Z2),
        Z1 @=< Z2
    ->  (   '@integer_exp'(Z2, A, Z3),
            Z3 @=< B
        ->  C = Z2
        ;   '@integer_add'(1, C, Z2)
        )
    ).

'@@integer_nrt'(N, A, X0, X) :-
    % X #= ((N-1)*X0^N+A)div(N*X0^(N-1))
    '@integer_add'(1, N0, N),
    '@integer_exp'(X0,  N, XN),
    '@integer_mul'(N0, XN, X1),
    '@integer_add'(A, X1, X2),
    '@integer_exp'(X0, N0, XN0),
    '@integer_mul'(N, XN0, X3),
    '@integer_ddqr'(floor, X2, X3, X, _).
% '@@integer_nrt'(N, A, X0, X) :-
%     % X #= X0+(A div X0^(N-1)-X0) div N
%     '@integer_add'(1, N0, N),
%     '@integer_exp'(X0, N0, X1),
%     '@integer_max'(1, X1, X2), % for zero
%     '@integer_ddqr'(floor, A, X2, X3, _),
%     '@integer_add'(X4, X0, X3),
%     '@integer_ddqr'(floor, X4, N, X5, _),
%     '@integer_add'(X0, X5, X).

'@@@integer_nrt'(N, A, X0-X1, Y0-Y) :-
    (   X0 @=< X1
    ->  Y0 = X0,
        Y = X1
    ;   '@@integer_nrt'(N, A, X1, X2),
        '@@@integer_nrt'(N, A, X1-X2, Y0-Y)
    ).

% integer_log(_, A, B, C) :-
%     member(E, [A,B,C]),
%     nonvar(E),
%     \+ integer(E),
%     !,
%     false.
integer_log(M, _, _, _) :-
    var(M),
    throw(error(instantiation_error,integer_log/5)).
integer_log(_, A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_log/5)).
integer_log(_, _, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_log/5)).
integer_log(M, A, B, C) :-
    A @> 1,
    B @> 0,
    once('@integer_log'(M, A, B, C)).

% A ^ C #= B
'@integer_log'( ceil, A, B, C) :-
    (   '@integer_msb'(A, Z0),
        '@integer_add'(1, Z0, Z1),
        '@integer_msb'(B, Z2),
        '@integer_ddqr'(floor, Z2, Z1, Z3, _),
        foldl('@integer_add'(1), Z3, Z4),
        '@integer_exp'(A, Z4, Z5),
        Z5 @>= B
    ->  C = Z4
    ).
'@integer_log'(floor, A, B, C) :-
    (   '@integer_msb'(A, Z0),
        '@integer_add'(1, Z0, Z1),
        '@integer_msb'(B, Z2),
        '@integer_ddqr'(floor, Z2, Z1, Z3, _),
        foldl('@integer_add'(1), Z3, Z4),
        '@integer_exp'(A, Z4, Z5),
        Z5 @> B
    ->  '@integer_add'(1, C, Z4)
    ).

% integer_shl(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_shl(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_shl/3)).
integer_shl(_, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_shl/3)).
integer_shl(A, B, C) :-
    '@integer_shl'(A, B, C).

'@integer_shl'(A, B, C) :-
    C is B<<A.

% integer_shr(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_shr(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_shr/3)).
integer_shr(_, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_shr/3)).
integer_shr(A, B, C) :-
    '@integer_shr'(A, B, C).

'@integer_shr'(A, B, C) :-
    C is B>>A.

% integer_xor(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_xor(A, B, _) :-
    var(A),
    var(B),
    throw(error(instantiation_error,integer_xor/3)).
integer_xor(A, _, C) :-
    var(A),
    var(C),
    throw(error(instantiation_error,integer_xor/3)).
integer_xor(_, B, C) :-
    var(B),
    var(C),
    throw(error(instantiation_error,integer_xor/3)).
integer_xor(A, B, C) :-
    once('@integer_xor'(A, B, C)).

'@integer_xor'(A, B, C) :-
    var(A),
    integer(B),
    integer(C),
    A is xor(B,C).
'@integer_xor'(A, B, C) :-
    var(B),
    integer(C),
    integer(A),
    B is xor(C,A).
'@integer_xor'(A, B, C) :-
    % var(C),
    nonvar(A), integer(A),
    nonvar(B), integer(B),
    C is xor(A,B).

% integer_ior(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_ior(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_ior/3)).
integer_ior(_, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_ior/3)).
integer_ior(A, B, C) :-
    '@integer_ior'(A, B, C).

'@integer_ior'(A, B, C) :-
    C is A\/B.

% integer_and(A, B, C) :-
%     member(D, [A,B,C]),
%     nonvar(D),
%     \+ integer(D),
%     !,
%     false.
integer_and(A, _, _) :-
    var(A),
    throw(error(instantiation_error,integer_and/3)).
integer_and(_, B, _) :-
    var(B),
    throw(error(instantiation_error,integer_and/3)).
integer_and(A, B, C) :-
    '@integer_and'(A, B, C).

'@integer_and'(A, B, C) :-
    C is A/\B.
