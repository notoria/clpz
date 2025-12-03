/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Compatibility predicates.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- include("../list").
:- include("../pair").
:- include("../error").

:- use_module(library(assoc), [empty_assoc/1,assoc_to_list/2,get_assoc/3,put_assoc/4]).
:- use_module(library(between), [between/3]).
:- use_module(library(lists), [append/2,exclude/3,include/3,maplist/2,maplist/3,maplist/4,nth0/3,nth1/3,partition/5,reverse/2,same_length/2,scanlist/4,scanlist/5,select/3,sumlist/2]).
:- use_module(library(atts)).
:- use_module(library(samsort), [samsort/2]).
:- use_module(library(terms), [cyclic_term/1]).
:- use_module(library(types), [must_be/4]).

seq([]) --> [].
seq([E|Es]) --> [E], seq(Es).

succ(S0, S) :-
    var(S0),
    var(S),
    throw(error(instantiation_error,succ/2)).
succ(S0, S) :-
    (   var(S0)
    ->  integer(S),
        S0 is S-1
    ;   integer(S0),
        S is S0+1
    ),
    S0 @>= 0.

list_si(Es0) :-
    prolog:'$list_info'(Es0,_,Es),
    '@list_si'(Es0, Es).

'@list_si'(_, Es) :-
    var(Es),
    throw(error(instantiation_error,list_si/1)).
'@list_si'(Es0, Es) :-
    Es \= [],
    throw(error(type_error(list,Es0),list_si/1)).
'@list_si'(_, []).

must_be(What, Term) :- must_be(What, unknown(Term)-1, Term).

must_be(Type, Goal-Arg, Term) :-
        \+ member(Type, [ground,acyclic,list,list(_)]),
        must_be(Term, Type, Goal, Arg).
must_be(ground, _, Term) :-
        (   ground(Term) -> true
        ;   instantiation_error(Term)
        ).
must_be(acyclic, Where, Term) :-
        (   acyclic_term(Term) ->
            true
        ;   domain_error(acyclic_term, Term, Where)
        ).
must_be(list, Where, Term) :-
        (   list_si(Term) -> true
        ;   type_error(list, Term, Where)
        ).
must_be(list(What), Where, Term) :-
        must_be(list, Where, Term),
        maplist(must_be(What, Where), Term).


instantiation_error(Term) :- instantiation_error(Term, unknown(Term)-1).

instantiation_error(_, Goal-Arg) :-
        throw(error(instantiation_error, instantiation_error(Goal, Arg))).


domain_error(Expectation, Term) :-
        domain_error(Expectation, Term, unknown(Term)-1).

type_error(Expectation, Term) :-
        type_error(Expectation, Term, unknown(Term)-1).


% /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    foldl/4
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
% 
% foldl(Goal_3, Ls, A0, A) :-
%     scanlist(Goal_3, Ls, A0, A).
% 
% /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    foldl/5
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
% 
% foldl(Goal_4, Xs, Ys, A0, A) :-
%     scanlist(Goal_4, Xs, Ys, A0, A).

:- meta_predicate(partition(1, ?, ?, ?)).

partition(Pred, Ls0, As, Bs) :-
        include(Pred, Ls0, As),
        exclude(Pred, Ls0, Bs).


sum_list(Ls, S) :- sumlist(Ls, S).

%:- discontiguous clpz:goal_expansion/5.

singles(Ts) --> '@singles'([], Ts), !.

'@singles'(_, []) --> [].
'@singles'(Ts0, [T|Ts]) -->
    { member(T0, Ts), T == T0 }, !,
    '@singles'([T|Ts0], Ts).
'@singles'(Ts0, [T|Ts]) -->
    { member(T0, Ts0), T == T0 }, !,
    '@singles'(Ts0, Ts).
'@singles'(Ts0, [T|Ts]) -->
    [T], '@singles'(Ts0, Ts).

singles(Ts0, Ts) :-
    phrase(singles(Ts0), Ts).


uniques(Ts) --> '@uniques'([], Ts), !.

'@uniques'(_, []) --> [].
'@uniques'(Ts0, [T|Ts]) -->
    { member(T0, Ts0), T == T0 }, !,
    '@uniques'(Ts0, Ts).
'@uniques'(Ts0, [T|Ts]) -->
    [T], '@uniques'([T|Ts0], Ts).

uniques(Ts0, Ts) :-
    phrase(uniques(Ts0), Ts).
