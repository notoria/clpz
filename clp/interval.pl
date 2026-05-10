/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Interval
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

%
interval(I) :-
    var(I),
    throw(error(instantiation_error,interval/1)).
interval(F-T) :-
    F cis_le T,
    F \== sup,
    T \== inf.

%
interval_size(F-T, S) :-
    S cis T-F+n(1).

'@interval?'(>, _) --> [].
'@interval?'(=, I) --> [I].
'@interval?'(<, I) --> [I].

'@intervals_repair'(>, F-N, [N-T|Is]) --> '@intervals_repair'(F-T, Is).
'@intervals_repair'(=, F-_, [_-T|Is]) --> '@intervals_repair'(F-T, Is).
'@intervals_repair'(<, I0, [I|Is]) --> [I0], '@intervals_repair'(I, Is).

'@intervals_repair'(I0, []) --> [I0].
'@intervals_repair'(F0-T0, [F1-T1|Is]) -->
    % { F0 cis_le F1, T0 cis_le T1, F0 cis_le T1 },
    { D cis F1-T0, cis_compare(O, n(1), D) },
    '@intervals_repair'(O, F0-T0, [F1-T1|Is]).

'@intervals_repair'([]) --> [].
'@intervals_repair'([I|Is]) --> '@intervals_repair'(I, Is).

%
intervals_repair(Is0, Is) :-
    phrase('@intervals_repair'(Is0), Is).


% Source: https://ir.cwi.nl/pub/10478/10478D.pdf
'@interval_bound'(>, _-n(_), inf, inf).
'@interval_bound'(>, F-n(T), n(B0), n(B)) :-
    (   0 @< B0,
        foldl(integer_add(-1), B0, B1),
        N cis -(-F div n(B1)) * n(B1),
        N cis_le n(T)
    ->  B = B1
    ).
'@interval_bound'(>, _-n(_), sup, sup).
'@interval_bound'(>, _-sup, B, B).
'@interval_bound'(<, inf-_, B, B).
'@interval_bound'(<, n(_)-_, inf, inf).
'@interval_bound'(<, n(F)-T, n(B0), n(B)) :-
    (   n(B0) cis_le T,
        foldl(integer_add(1), B0, B1),
        N cis (T div n(B1)) * n(B1),
        n(F) cis_le N
    ->  B = B1
    ).
'@interval_bound'(<, n(_)-_, sup, sup).

% '@interval_lower_bound'(F-T, n(B0), n(B)) :-
%     (   N0 cis T div n(B0), n(0) cis_lt N0,
%         foldl(integer_add(1), B0, B1),
%         N cis (T div n(B1)) * n(B1),
%         n(F) cis_le N
%     ->  B = B1
%     ;   F = 0,
%         B = B0
%     ).
%
% '@interval_upper_bound'(F-T, B0, B) :-
%     false.

%
'@interval_factor'(<, <, <, <, ZL-ZU, YL0-YU0) -->
    (   {   '@interval_bound'(<, ZL-ZU, YL0, YL),
            '@interval_bound'(>, ZL-ZU, YU0, YU),
            YL cis_le YU
        }
    ->  {   L cis max(n(1),-(-ZL div YU)),
            U cis ZU div YL
        },
        [L-U]
    ;   []
    ).
'@interval_factor'(<, <, =, <, ZL-ZU, n(0)-YU0) -->
    % '@interval_factor'(<, <, <, <, ZL-ZU, n(1)-YU0).
    (   {   '@interval_bound'(<, ZL-ZU, n(1), YL),
            '@interval_bound'(>, ZL-ZU, YU0, YU)
        }
    ->  {   L cis max(n(1),-(-ZL div YU)),
            U cis ZU div YL
        },
        [L-U]
    ;   []
    ).
'@interval_factor'(<, <, =, =, _, n(0)-n(0)) --> [].
'@interval_factor'(<, <, >, =, ZI, YI0) -->
    {   intervals_expand(-1, [YI0], [YI]),
        phrase('@interval_factor'(<, <, =, <, ZI, YI), XIs0),
        intervals_expand(-1, XIs0, XIs)
    },
    map(identity, XIs).
% '@interval_factor'(<, <, >, =, ZL-ZU, YL0-n(0)) -->
%     (   {   '@interval_bound'(>, ZL-ZU, YL0, YL),
%             '@interval_bound'(<, ZL-ZU, n(-1), YU)
%         }
%     ->  {   U cis ZL div YL,
%             L cis -(-ZU div YU),
%             cis_compare(O, L, U)
%         },
%         '@interval?'(O, L-U)
%     ;   []
%     ).
'@interval_factor'(<, <, >, >, ZI, YI0) -->
    {   intervals_expand(-1, [YI0], [YI]),
        phrase('@interval_factor'(<, <, <, <, ZI, YI), XIs0),
        intervals_expand(-1, XIs0, XIs)
    },
    map(identity, XIs).
% '@interval_factor'(<, <, >, >, ZL-ZU, YL0-YU0) -->
%     (   {   '@interval_bound'(>, ZL-ZU, YL0, YL),
%             '@interval_bound'(<, ZL-ZU, YU0, YU)
%         }
%     ->  {   U cis ZL div YL,
%             L cis -(-ZU div YU),
%             cis_compare(O, L, U)
%         },
%         '@interval?'(O, L-U)
%     ;   []
%     ).
'@interval_factor'(<, <, >, <, ZI, YL-YU) -->
    '@interval_factor'(<, <, >, >, ZI, YL-n(-1)),
    '@interval_factor'(<, <, <, <, ZI, n(1)-YU).
%
'@interval_factor'(=, <, <, <, n(0)-ZU, YL-_) -->
    {   L = n(0),
        U cis ZU div YL
    },
    [L-U].
'@interval_factor'(=, <, =, <, n(0)-_, n(0)-_) --> [inf-sup].
'@interval_factor'(=, <, =, =, n(0)-_, n(0)-n(0)) --> [inf-sup].
'@interval_factor'(=, <, >, =, n(0)-_, _-n(0)) --> [inf-sup].
'@interval_factor'(=, <, >, >, ZI, YI0) -->
    {   intervals_expand(-1, [YI0], [YI]),
        phrase('@interval_factor'(=, <, <, <, ZI, YI), XIs0),
        intervals_expand(-1, XIs0, XIs)
    },
    map(identity, XIs).
% '@interval_factor'(=, <, >, >, n(0)-ZU, YL-YU) -->
%     {   L cis n(0),
%         U cis ZL div YU,
%         cis_compare(O, L, U)
%     },
%     '@interval?'(O, L-U).
'@interval_factor'(=, <, >, <, n(0)-_, _) --> [inf-sup].
%
'@interval_factor'(=, =, <, <, n(0)-n(0), _) --> [n(0)-n(0)].
'@interval_factor'(=, =, =, <, n(0)-n(0), n(0)-_) --> [inf-sup].
'@interval_factor'(=, =, =, =, n(0)-n(0), n(0)-n(0)) --> [inf-sup].
'@interval_factor'(=, =, >, =, n(0)-n(0), _-n(0)) --> [inf-sup].
'@interval_factor'(=, =, >, >, n(0)-n(0), _) --> [n(0)-n(0)].
'@interval_factor'(=, =, >, <, n(0)-n(0), _) --> [inf-sup].
%
'@interval_factor'(>, =, <, <, ZI0, YI) -->
    {   intervals_expand(-1, [ZI0], [ZI]),
        phrase('@interval_factor'(=, <, <, <, ZI, YI), XIs0),
        intervals_expand(-1, XIs0, XIs)
    },
    map(identity, XIs).
% '@interval_factor'(>, =, <, <, ZL-n(0), YL-YU) -->
%     {   U cis n(0),
%         L cis -(-ZL div YL),
%         cis_compare(O, L, U)
%     },
%     '@interval?'(O, L-U).
'@interval_factor'(>, =, =, <, _-n(0), n(0)-_) --> [inf-sup].
'@interval_factor'(>, =, =, =, _-n(0), n(0)-n(0)) --> [inf-sup].
'@interval_factor'(>, =, >, =, _-n(0), _-n(0)) --> [inf-sup].
'@interval_factor'(>, =, >, >, ZI0, YI0) -->
    {   intervals_expand(-1, [ZI0], [ZI]),
        intervals_expand(-1, [YI0], [YI]),
        phrase('@interval_factor'(=, <, <, <, ZI, YI), XIs)
    },
    map(identity, XIs).
% '@interval_factor'(>, =, >, >, ZL-n(0), YL-YU) -->
%     {   L cis n(0),
%         U cis ZL div YU,
%         cis_compare(O, L, U)
%     },
%     '@interval?'(O, L-U).
'@interval_factor'(>, =, >, <, _-n(0), _) --> [inf-sup].
%
'@interval_factor'(>, >, <, <, ZI0, YI) -->
    {   intervals_expand(-1, [ZI0], [ZI]),
        phrase('@interval_factor'(<, <, <, <, ZI, YI), XIs0),
        intervals_expand(-1, XIs0, XIs)
    },
    map(identity, XIs).
% '@interval_factor'(>, >, <, <, ZL-ZU, YL-YU) -->
%     {   U cis -(-ZU div YU),
%         L cis ZL div YL,
%         cis_compare(O, L, U)
%     },
%     '@interval?'(O, L-U).
'@interval_factor'(>, >, =, <, ZI0, YI) -->
    {   intervals_expand(-1, [ZI0], [ZI]),
        phrase('@interval_factor'(<, <, =, <, ZI, YI), XIs0),
        intervals_expand(-1, XIs0, XIs)
    },
    map(identity, XIs).
% '@interval_factor'(>, >, =, <, ZL-ZU, n(0)-YU) -->
%     {   U cis ZU div YL,
%         L cis ZL,
%         cis_compare(O, L, U)
%     },
%     '@interval?'(O, L-U).
'@interval_factor'(>, >, =, =, _, n(0)-n(0)) --> [].
'@interval_factor'(>, >, >, =, ZI0, YI0) -->
    {   intervals_expand(-1, [ZI0], [ZI]),
        intervals_expand(-1, [YI0], [YI]),
        phrase('@interval_factor'(<, <, =, <, ZI, YI), XIs)
    },
    map(identity, XIs).
% '@interval_factor'(>, >, >, =, ZL-ZU, YL0-n(0)) -->
%     (   {   '@interval_bound'(<, ZL-ZU, YL0, YL),
%             '@interval_bound'(>, ZL-ZU, n(-1), YU)
%         }
%     ->  {   L cis -(-ZU div YL),
%             U cis ZL div YU,
%             cis_compare(O, L, U)
%         },
%         '@interval?'(O, L-U)
%     ;   []
%     ).
'@interval_factor'(>, >, >, >, ZI0, YI0) -->
    {   intervals_expand(-1, [ZI0], [ZI]),
        intervals_expand(-1, [YI0], [YI]),
        phrase('@interval_factor'(<, <, <, <, ZI, YI), XIs)
    },
    map(identity, XIs).
% '@interval_factor'(>, >, >, >, ZL-ZU, YL0-YU0) -->
%     (   {   '@interval_bound'(>, ZL-ZU, YL0, YL),
%             '@interval_bound'(<, ZL-ZU, YU0, YU)
%         }
%     ->  {   L cis -(-ZU div YL),
%             U cis ZL div YU,
%             cis_compare(O, L, U)
%         },
%         '@interval?'(O, L-U)
%     ;   []
%     ).
%     % {   L cis -(-ZU div YL),
%     %     U cis ZL div YU,
%     %     cis_compare(O, L, U)
%     % },
%     % '@interval?'(O, L-U).
'@interval_factor'(>, >, >, <, ZI, YL-YU) -->
    '@interval_factor'(>, >, <, <, ZI, n(1)-YU), % The order is important
    '@interval_factor'(>, >, >, >, ZI, YL-n(-1)).
%
'@interval_factor'(>, <, <, <, ZL-ZU, YI) -->
    '@interval_factor'(>, =, <, <, ZL-n(0), YI),
    '@interval_factor'(=, <, <, <, n(0)-ZU, YI).
'@interval_factor'(>, <, =, <, _, _) --> [inf-sup].
'@interval_factor'(>, <, =, =, _, _) --> [inf-sup].
'@interval_factor'(>, <, >, =, _, _) --> [inf-sup].
'@interval_factor'(>, <, >, >, ZL-ZU, YI) -->
    '@interval_factor'(=, <, >, >, n(0)-ZU, YI), % The order is important
    '@interval_factor'(>, =, >, >, ZL-n(0), YI).
'@interval_factor'(>, <, >, <, _, _) --> [inf-sup].

'@interval_factor'(ZL-ZU, YL-YU) -->
    {   cis_compare(O0, n(0), ZL),
        cis_compare(O1, n(0), ZU),
        cis_compare(O2, n(0), YL),
        cis_compare(O3, n(0), YU)
        % atom_chars(A, [O0,O1,O2,O3])
    },
    '@interval_factor'(O0, O1, O2, O3, ZL-ZU, YL-YU).

%
interval_factor(ZI, YI, XIs) :-
    phrase('@interval_factor'(ZI, YI), XIs0),
    phrase('@intervals_repair'(XIs0), XIs).


'@interval'(_-T0, F1-_) :-
    D cis F1-T0,
    n(1) cis_lt D.

%
intervals(Is) :-
    var(Is),
    throw(error(instantiation_error,intervals/1)).
intervals(Is) :-
    list_map(interval, Is),
    list_chain('@interval', Is).


'@interval_size'(F-T, S0, S) :-
    S cis T-F+n(1)+S0.

%
intervals_size(Is, S) :-
    list_foldl('@interval_size', Is, n(0), S).


'@interval_from_number'(N, n(N)-n(N)).

%
intervals_from_numbers(Ns, Is) :-
    list_map('@interval_from_number', Ns, Is0),
    phrase('@intervals_repair'(Is0), Is).


'@interval_to_numbers_inf'(N0) -->
    { integer_add(1, N, N0) },
    '@interval_to_numbers_inf'(N), [N0].

'@interval_to_numbers_sup'(N0) -->
    { integer_add(1, N0, N) },
    [N0], '@interval_to_numbers_sup'(N).

'@interval_to_numbers'(=, T, T) --> [T].
'@interval_to_numbers'(<, F0, T) -->
    { integer_add(1, F0, F), integer_compare(O, F, T) },
    [F0], '@interval_to_numbers'(O, F, T).

'@interval_to_numbers'(inf-sup) -->
    { throw(error(instantiation_error,_)) }.
    % '@interval_to_numbers_inf'(0),
    % '@interval_to_numbers_sup'(0).
'@interval_to_numbers'(inf-n(_)) -->
    { throw(error(instantiation_error,_)) }.
    % '@interval_to_numbers_inf'(T).
'@interval_to_numbers'(n(_)-sup) -->
    { throw(error(instantiation_error,_)) }.
    % '@interval_to_numbers_sup'(F).
'@interval_to_numbers'(n(F)-n(T)) -->
    { integer_compare(O, F, T) },
    '@interval_to_numbers'(O, F, T).

%
intervals_to_numbers(Is, Ns) :-
    phrase(map('@interval_to_numbers', Is), Ns).


'@@intervals_union'(>, [F0-_|Is0], [F1-T1|Is1]) -->
    { F cis min(F0,F1) },
    '@intervals_union'(Is0, [F-T1|Is1]).
'@@intervals_union'(=, [F0-_|Is0], [_-T1|Is1]) -->
    '@intervals_union'(Is0, [F0-T1|Is1]).
'@@intervals_union'(<, [I|Is0], Is1) -->
    [I], '@intervals_union'(Is0, Is1).

'@intervals_union'(>, Is0, Is1) -->
    '@intervals_union'(<, Is1, Is0).
'@intervals_union'(=, [F0-T|Is0], [F1-T|Is1]) -->
    { F cis min(F0,F1) },
    '@intervals_union'(Is0, [F-T|Is1]).
'@intervals_union'(<, [F0-T0|Is0], [F1-T1|Is1]) -->
    { N cis F1-T0, cis_compare(O, n(1), N) },
    '@@intervals_union'(O, [F0-T0|Is0], [F1-T1|Is1]).

'@intervals_union'([], []) --> [].
'@intervals_union'([], [I1|Is1]) --> map(identity, [I1|Is1]).
'@intervals_union'([I0|Is0], []) --> map(identity, [I0|Is0]).
'@intervals_union'([F0-T0|Is0], [F1-T1|Is1]) -->
    { cis_compare(O, T0, T1) },
    '@intervals_union'(O, [F0-T0|Is0], [F1-T1|Is1]).

%
intervals_union(Is0, Is1, Is) :-
    phrase('@intervals_union'(Is0, Is1), Is).


'@@intervals_inter'(>, [F0-T0|Is0], [F1-T1|Is1]) -->
    { F cis max(F0,F1), T cis min(T0,T1) },
    [F-T], '@intervals_inter'(Is0, [T-T1|Is1]).
'@@intervals_inter'(=, [_-N|Is0], [N-T1|Is1]) -->
    [N-N], '@intervals_inter'(Is0, [N-T1|Is1]).
'@@intervals_inter'(<, [_|Is0], Is1) -->
    '@intervals_inter'(Is0, Is1).

'@intervals_inter'(>, Is0, Is1) -->
    '@intervals_inter'(<, Is1, Is0).
'@intervals_inter'(=, [F0-T|Is0], [F1-T|Is1]) -->
    { F cis max(F0,F1) },
    [F-T], '@intervals_inter'(Is0, Is1).
'@intervals_inter'(<, [F0-T0|Is0], [F1-T1|Is1]) -->
    { cis_compare(O, T0, F1) },
    '@@intervals_inter'(O, [F0-T0|Is0], [F1-T1|Is1]).

'@intervals_inter'([], []) --> [].
'@intervals_inter'([], [_|_]) --> [].
'@intervals_inter'([_|_], []) --> [].
'@intervals_inter'([F0-T0|Is0], [F1-T1|Is1]) -->
    { cis_compare(O, T0, T1) },
    '@intervals_inter'(O, [F0-T0|Is0], [F1-T1|Is1]).

%
intervals_inter(Is0, Is1, Is) :-
    phrase('@intervals_inter'(Is0, Is1), Is).


'@@intervals_ldiff'(>, F0, [F1-T1|Is], [F0-T1|Is]) -->
    { T cis F0-n(1) },
    [F1-T].
'@@intervals_ldiff'(=, N, [F1-N|Is], Is) -->
    { T cis N-n(1) },
    [F1-T].
'@@intervals_ldiff'(<, F0, [I0|Is0], Is) -->
    [I0], '@intervals_ldiff'(F0, Is0, Is).

'@intervals_ldiff'(>, _, Is, Is) --> [].
'@intervals_ldiff'(=, _, Is, Is) --> [].
'@intervals_ldiff'(<, F0, [F1-T1|Is0], Is) -->
    { cis_compare(O, T1, F0) },
    '@@intervals_ldiff'(O, F0, [F1-T1|Is0], Is).

'@intervals_ldiff'(_, [], []) --> [].
'@intervals_ldiff'(F0, [F1-T1|Is0], Is) -->
    { cis_compare(O, F1, F0) },
    '@intervals_ldiff'(O, F0, [F1-T1|Is0], Is).

'@@intervals_rdiff'(>, _, Is, Is) --> [].
'@@intervals_rdiff'(=, N, [N-T1|Is], [F-T1|Is]) -->
    { F cis N+n(1) }.
'@@intervals_rdiff'(<, T0, [_-T1|Is], [F-T1|Is]) -->
    { F cis T0+n(1) }.

'@intervals_rdiff'(>, T0, [F1-T1|Is0], Is) -->
    { cis_compare(O, F1, T0) },
    '@@intervals_rdiff'(O, T0, [F1-T1|Is0], Is).
'@intervals_rdiff'(=, N, [_-N|Is], Is) --> [].
'@intervals_rdiff'(<, T0, [_|Is0], Is) -->
    '@intervals_rdiff'(T0, Is0, Is).

'@intervals_rdiff'(_, [], []) --> [].
'@intervals_rdiff'(T0, [F1-T1|Is0], Is) -->
    { cis_compare(O, T1, T0) },
    '@intervals_rdiff'(O, T0, [F1-T1|Is0], Is).

'@intervals_diff'([], Is) --> map(identity, Is).
'@intervals_diff'([F0-T0|Is0], Is1) -->
    '@intervals_ldiff'(F0, Is1, Is2),
    '@intervals_rdiff'(T0, Is2, Is3),
    '@intervals_diff'(Is0, Is3).

% Is = Is1\Is0
% intervals_diff(_Is0, [], []).
% intervals_diff(Is0, [I1|Is1], Is) :-
%     phrase('@intervals_diff'(Is0, [I1|Is1]), Is).
intervals_diff(Is0, Is1, Is) :-
    phrase('@intervals_diff'(Is0, Is1), Is).


'@intervals_negative_expand'(_, []) --> [].
'@intervals_negative_expand'(A, [F0-T0|Is]) -->
    { F cis n(A)*T0, T cis n(A)*F0 },
    '@intervals_negative_expand'(A, Is), [F-T].

'@intervals_zero_expand'([]) --> [].
'@intervals_zero_expand'([_|_]) --> [n(0)-n(0)]. % contract

'@intervals_positive_expand'(=, 1, Is) --> map(identity, Is).
'@intervals_positive_expand'(=, A, Is) -->
    '@intervals_positive_expand'(n(A), Is).

'@intervals_positive_expand'(_, []) --> [].
'@intervals_positive_expand'(A, [F0-T0|Is]) -->
    { F cis A*F0, T cis A*T0 },
    [F-T], '@intervals_positive_expand'(A, Is).

'@intervals_expand'(>, A, Is) --> '@intervals_negative_expand'(A, Is).
'@intervals_expand'(=, 0, Is) --> '@intervals_zero_expand'(Is).
'@intervals_expand'(<, A, Is) -->
    { integer_compare(O, 1, A) },
    '@intervals_positive_expand'(O, A, Is).

'@intervals_expand'(A, Is) -->
    { integer_compare(O, 0, A) },
    '@intervals_expand'(O, A, Is).

%
intervals_expand(A, Is0, Is) :-
    phrase('@intervals_expand'(A, Is0), Is).


'@interval_fdiv'(>, A, F0, F) :-
    F cis -(-F0 div A).
'@interval_fdiv'(=, _, F, F).
'@interval_fdiv'(<, A, F0, F) :-
    F cis F0 div A.

'@interval_cdiv'(>, A, F0, F) :-
    F cis F0 div A.
'@interval_cdiv'(=, _, F, F).
'@interval_cdiv'(<, A, F0, F) :-
    F cis -(-F0 div A).

'@intervals_negative_contract'(_, []) --> [].
'@intervals_negative_contract'(A, [F0-T0|Is]) -->
    {   cis_compare(O0, n(0), F0),
        cis_compare(O1, n(0), T0),
        '@interval_cdiv'(O0, A, F0, T),
        '@interval_cdiv'(O1, A, T0, F)
    },
    '@intervals_negative_contract'(A, Is), [F-T].

'@intervals_positive_contract'(=, 1, Is) --> map(identity, Is).
'@intervals_positive_contract'(<, A, Is) -->
    '@intervals_positive_contract'(n(A), Is).

'@intervals_positive_contract'(_, []) --> [].
'@intervals_positive_contract'(A, [F0-T0|Is]) -->
    {   cis_compare(O0, n(0), F0),
        cis_compare(O1, n(0), T0),
        '@interval_fdiv'(O0, A, F0, F),
        '@interval_fdiv'(O1, A, T0, T)
    },
    [F-T], '@intervals_positive_contract'(A, Is).

'@intervals_contract'(>, A, Is) --> '@intervals_negative_contract'(n(A), Is).
% '@intervals_contract'(=, 0, Is) --> '@intervals_zero_contract'(Is). % expand
'@intervals_contract'(<, A, Is) -->
    { integer_compare(O, 1, A) },
    '@intervals_positive_contract'(O, A, Is).

'@intervals_contract'(A, Is) -->
    { integer_compare(O, 0, A) },
    '@intervals_contract'(O, A, Is).

% toward zero
intervals_contract(A, Is0, Is) :-
    phrase('@intervals_contract'(A, Is0), Is1),
    phrase('@intervals_repair'(Is1), Is).


'@intervals_negative_shrink'(_, []) --> [].
'@intervals_negative_shrink'(A, [F0-T0|Is]) -->
    {   T cis F0 div A,
        F cis -(-T0 div A),
        cis_compare(O, F, T)
    },
    '@intervals_negative_shrink'(A, Is), '@interval?'(O, F-T).

'@intervals_positive_shrink'(=, 1, Is) --> map(identity, Is).
'@intervals_positive_shrink'(<, A, Is) -->
    '@intervals_positive_shrink'(n(A), Is).

'@intervals_positive_shrink'(_, []) --> [].
'@intervals_positive_shrink'(A, [F0-T0|Is]) -->
    {   F cis -(-F0 div A),
        T cis T0 div A,
        cis_compare(O, F, T)
    },
    '@interval?'(O, F-T), '@intervals_positive_shrink'(A, Is).

'@intervals_shrink'(>, A, Is) --> '@intervals_negative_shrink'(n(A), Is).
% '@intervals_shrink'(=, A, Is) --> '@intervals_zero_shrink'(Is). % expand
'@intervals_shrink'(<, A, Is) -->
    { integer_compare(O, 1, A) },
    '@intervals_positive_shrink'(O, A, Is).

'@intervals_shrink'(A, Is) -->
    { integer_compare(O, 0, A) },
    '@intervals_shrink'(O, A, Is).

%
intervals_shrink(A, Is0, Is) :-
    phrase('@intervals_shrink'(A, Is0), Is1),
    phrase('@intervals_repair'(Is1), Is).
