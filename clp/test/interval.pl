% :- library("dcg").
% :- library("format").
% :- library("is").
% 
% :- op(950, fx, *). *(_). goal_expansion(*_, true).
% 
% var(T) :-
%     variable(T).
% 
% member(E, Es) :-
%     list_element(Es, E).
% 
% compare(O, T, U) :-
%     term_compare(O, T, U).

:- include("../../sicstus/compatibility").
:- include("../../reif").
:- include("../operators").
:- include("../integer").
:- include("../utils").
:- include("../bound").
:- include("../cis").
:- include("../interval").
:- include("../domain").
:- include("../drep").
% sicstus -f -l env/sicstus/iso.pl -l env/sicstus/z.pl -l env/clp/test/interval.pl

interval(F-T, L0-U, L-U) :-
    L0 @=< U,
    integer_between(L0, U, F0),
    integer_between(F0, U, T0),
    integer_add(2, T0, L),
    bound_from_defaulty(F0, F),
    bound_from_defaulty(T0, T).

test_union :-
    list_length(_, N),
    portray_clause(user_error, N),
    integer_neg(N, L),
    U = N,
    list_foldl(interval, Is0, L-U, _),
    % intervals(Is0),
    list_foldl(interval, Is1, L-U, _),
    % intervals(Is1),
    intervals_union(Is0, Is1, Is),
    \+ (
        intervals(Is),
        intervals_to_numbers(Is0, Ns0),
        intervals_to_numbers(Is1, Ns1),
        list_append(Ns0, Ns1, Ns2),
        sort(Ns2, Ns),
        intervals_to_numbers(Is, Ns)
    ),
    portray_clause(user_error, Is0\/Is1=Is),
    halt.

test_inter :-
    list_length(_, M),
    portray_clause(user_error, M),
    integer_neg(M, L),
    U = M,
    Is0 = [_|_],
    list_foldl(interval, Is0, L-U, _),
    % intervals(Is0),
    Is1 = [_|_],
    list_foldl(interval, Is1, L-U, _),
    % intervals(Is1),
    intervals_inter(Is0, Is1, Is),
    \+ (
        intervals(Is),
        findall(
            N,
            (   integer_between(L, U, N),
                once((list_element(Is0, n(F0)-n(T0)), integer_between(F0, T0, N))),
                once((list_element(Is1, n(F1)-n(T1)), integer_between(F1, T1, N))),
                true
            ),
            Ns
        ),
        intervals_to_numbers(Is, Ns)
    ),
    portray_clause(user_error, Is0/\Is1=Is),
    halt.

test_diff :-
    list_length(_, M),
    portray_clause(user_error, M),
    integer_neg(M, L),
    U = M,
    list_foldl(interval, Is0, L-U, _),
    list_foldl(interval, Is1, L-U, _),
    intervals_diff(Is0, Is1, Is),
    \+ (
        intervals(Is),
        findall(
            N,
            (   list_element(Is1, n(F1)-n(T1)),
                integer_between(F1, T1, N),
                \+ (
                    list_element(Is0, n(F0)-n(T0)),
                    integer_between(F0, T0, N)
                )
            ),
            Ns0
        ),
        sort(Ns0, Ns),
        intervals_to_numbers(Is, Ns)
    ),
    portray_clause(user_error, [Is0,Is1,Is]),
    halt.

% test_abscpm :-
%     list_length(_, M),
%     portray_clause(user_error, M),
%     integer_neg(M, L),
%     U = M,
%     % Is0 = [_|_],
%     list_foldl(interval, Is0, L-U, _),
%     intervals_diff(Is0, [inf-sup], Is1), % [inf-sup]\Is0 = Is1
%     intervals_diff(Is1, [inf-sup], Is0),
%     intervals_abscpm(Is1, Is2), % [inf-sup]\Is1 = Is2
%     dif(Is0,Is2),
%     portray_clause(user_error, [Is0,Is1,Is2]),
%     halt.

negative(I) --> { I @=< 0 }, !, [I].
negative(_) --> [].

positive(I) --> { 0 @=< I }, !, [I].
positive(_) --> [].

integers_to_domain(L0, U0, Is, D) :-
    list_foldl(integer_min, Is, U0, L),
    list_foldl(integer_max, Is, L0, U),
    domain_from_bounds(n(L), n(U), D).

test_factor :-
    % integer_between(0, 15, M),
    list_length(_, M),
    portray_clause(user_error, depth(M)),
    U = M,
    % integer_neg(M, L),
    L = 0,
    domain_from_bounds(n(L), n(U), D),
    integer_between(L, U, ZL), integer_between(ZL, U, ZU),
    integer_between(L, U, YL), integer_between(YL, U, YU),
    % portray_clause(user_output, [n(ZL)-n(ZU),n(YL)-n(YU)]),
    (   interval_factor(n(ZL)-n(ZU), n(YL)-n(YU), Xs0)
    ->  true
    ;   portray_clause(user_output, [n(ZL)-n(ZU),n(YL)-n(YU)]),
        halt
    ),
    findall(
        X,
        (   integer_between( L,  U, X),
            integer_between(YL, YU, Y),
            integer_mul(X, Y, Z),
            integer_between(ZL, ZU, Z)
        ),
        Xs
    ),
    phrase(map(negative, Xs), Ns), integers_to_domain(L, U, Ns, XDN),
    phrase(map(positive, Xs), Ps), integers_to_domain(L, U, Ps, XDP),
    domain_union(XDN, XDP, D1),
    domain_from_intervals(Xs0, D0),
    dif(D0, D1),
    drep_from_domain(D0, DR0),
    drep_from_domain(D1, DR1),
        % portray_clause(user_error, [n(ZL)-n(ZU),n(YL)-n(YU),DR0,DR1]),
    domain_length(D0, Size),
    (   Size == sup
    ->  domain_inter(D, D0, D2),
        drep_from_domain(D2, DR2),
        dif(D2, D1),
        portray_clause(user_output, [n(ZL)-n(ZU),n(YL)-n(YU),DR0,DR2,DR1])
    ;   % domain_includes(D0, D1, false),
        portray_clause(user_output, [n(ZL)-n(ZU),n(YL)-n(YU),DR0,DR1])
    ),
    halt.
