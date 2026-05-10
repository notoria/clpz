:- include("core").
:- include("list").

%?- bagof(A,   list_element([a-Z,b-Y,a-0,b-0], A-B), Es).
%?- bagof(A, B^list_element([a-Z,b-Y,a-0,b-0], A-B), Es).
%?- bagof(A, Z^list_element([a-Z,b-Y,a-0,b-0], A-B), Es).
%?- bagof(A, Y^list_element([a-Z,b-Y,a-0,b-0], A-B), Es).

bagof(T, VsG, Es) :-
    term_variables(T, Vs0),
    '@bagof_vgoal'(VsG, Vs1, G),
    term_variables(VsG, Vs2),
    list_append(Vs0, Vs1, Vs3), '$uniques'(Vs3, Vs4),
    '@bagof_diff'(Vs4, Vs2, Vs),
    findall(Vs-T, G, Es0),
    list_map(arg(1), Es0, Tss0),
    '@bagof_variables'(Tss0),
    % '@bagof_variants'(Tss0),
    '$uniques'(Tss0, Tss),
    % sort(Tss0, Tss), % Alternative deduplicate.
    list_element(Tss, Vs),
    '@bagof_select'(Vs, Es0, Es1),
    Es = Es1.

'@bagof_select'(_, [], []).
'@bagof_select'(Vs0, [Vs-E|Es0], Es1) :-
    (   Vs0 \== Vs
    ->  Es = Es1
    ;   [E|Es] = Es1
    ),
    '@bagof_select'(Vs0, Es0, Es).

'@bagof_variables'(Tss) :-
    list_map(term_variables, Tss, Vss),
    list_map('@bagof_variable'(_), Vss).

'@bagof_variable'(Ws, Vs) :-
    list_append(Vs, _, Ws).

'@bagof_variant'(T0, T1) :-
    copy_term(T0, T2),
    subsumes_term(T2, T1),
    subsumes_term(T1, T2).

'@bagof_variants'([]).
'@bagof_variants'([T0|Ts]) :-
    (   list_element(Ts, T),
        '@bagof_variant'(T0, T)
    ->  T0 = T
    ;   true
    ),
    '@bagof_variants'(Ts).

'@bagof_vgoal'(VsG, Vs, G) :-
    once('@@bagof_vgoal'(VsG, Vs, G)).

'@@bagof_vgoal'(VsG0, Vs0, G) :-
    (   \+ subsumes_term(_^_, VsG0)
    ->  Vs0 = [],
        G = VsG0
    ;   V^VsG = VsG0,
        [V|Vs] = Vs0,
        '@@bagof_vgoal'(VsG, Vs, G)
    ).

% S = S0\T
'@bagof_diff'(T, S0, S) :-
    % '$uniques'(T, T),
    list_append(T, S0, S1),
    '$uniques'(S1, S2),
    list_append(T, S, S2).


setof(T, VsG, Es) :-
    % bagof(T, VsG, Es0),
    term_variables(T, Vs0),
    '@bagof_vgoal'(VsG, Vs1, G),
    term_variables(VsG, Vs2),
    list_append(Vs0, Vs1, Vs3), '$uniques'(Vs3, Vs4),
    '@bagof_diff'(Vs4, Vs2, Vs),
    findall(Vs-T, G, Es0),
    list_map(arg(1), Es0, Tss0),
    '@bagof_variables'(Tss0),
    % '@bagof_variants'(Tss0),
    '$uniques'(Es0, Es1),
    '$uniques'(Tss0, Tss),
    % '$sort'(@<, Tss0, Tss), % Alternative deduplicate.
    list_element(Tss, Vs),
    '@bagof_select'(Vs, Es1, Es2),
    Es = Es2.
