/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                               Duo DCGs
                               ========

   A Duo DCG is like a DCG, except that it describes *two* lists at
   the same time.

   A Duo DCG rule has the form Head ++> Body.  The language construct
   As+Bs is used within Duo DCGs to describe that the elements in As
   occur in the first list, and the elements in Bs occur in the second
   list. Duo DCGs are compiled to Prolog code via term expansion. The
   interface predicates are:

     *) duophrase(NT, As, Bs)
     *) duophrase(NT, As0, As, Bs0, Bs) (difference list version).

   Duo DCGs could be used to efficiently describe scheduled
   propagators, taking into account the two possible propagator
   priorities. However, it turns out that passing around a single
   argument is more efficient than passing around multiple arguments,
   and therefore regular DCGs are used for propagator scheduling.

   Still, everything is completely pure: No global data structures are
   needed to schedule the propagators!
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- meta_predicate(duophrase(4, ?, ?)).
:- meta_predicate(duophrase(4, ?, ?, ?, ?)).

duophrase(NT, As, Bs) :-
    duophrase(NT, As, [], Bs, []).

duophrase(NT, As0, As, Bs0, Bs) :-
    % call(NT, As0, As, Bs0, Bs).
    (   var(NT)
    ->  throw(error(instantiation_error,duophrase/5))
    ;   dcg_constr(NT),
        catch(
            duodcg_cbody(NT, G, As0, As, Bs0, Bs),
            error(E,_),
            throw(error(E,duophrase/5))
        )
        % duodcg_cbody(NT, G, As0, As, Bs0, Bs)
    ->  call(G)
    ;   call(NT, As0, As, Bs0, Bs)
    ).

:- discontiguous(user:term_expansion/6).
:- multifile(user:term_expansion/6).
user:term_expansion(Term0, _Layout1, Ids, Term, [], [duodcg|Ids]) :-
    \+ member(duodcg, Ids),
    nonvar(Term0),
    functor(Term0, ++>, 2),
    once(duodcg_rule(Term0, Term)).

duodcg_rule((NT0 ++> Body0), (NT :- Body)) :-
    duodcg_non_terminal(NT0, NT, As0, As, Bs0, Bs),
    duodcg_body(Body0, Body, As0, As, Bs0, Bs).

duodcg_callable(Term0) :-
   Term = Term0,
   catch(
        (false, Term ; true),
        error(type_error(callable,_),_),
        throw(error(type_error(callable,Term),_))
    ).

duodcg_non_terminal(NT0, NT, As0, As, Bs0, Bs) :-
    duodcg_callable(NT0),
    NT0 =.. [F|Args0],
    duodcg_append(Args0, [As0,As,Bs0,Bs], Args),
    NT =.. [F|Args].

duodcg_body(NT0, _, _, _, _, _) :-
    var(NT0),
    throw(error(instantiation_error,duodcg_body/6)).
duodcg_body(NT0, NT, As0, As, Bs0, Bs) :-
    duodcg_constr(NT0),
    duodcg_cbody(NT0, NT, As0, As, Bs0, Bs).
duodcg_body(NT0, NT, As0, As, Bs0, Bs) :-
    \+ duodcg_constr(NT0),
    duodcg_non_terminal(NT0, NT, As0, As, Bs0, Bs).

duodcg_constr([]).
% duodcg_constr([_|_]).
duodcg_constr(_+_).
duodcg_constr((_,_)).
duodcg_constr((_;_)).
duodcg_constr({_}).
% duodcg_constr((_'|'_)).
duodcg_constr((_->_)).
% duodcg_constr(!).

duodcg_cbody([], (As0=As,Bs0=Bs), As0, As, Bs0, Bs).
duodcg_cbody(Xs+Ys, G, As0, As, Bs0, Bs) :-
    G = (
        phrase(duodcg_sequence(Xs), As0, As),
        phrase(duodcg_sequence(Ys), Bs0, Bs)
    ).
duodcg_cbody({Goal}, call(Goal), As, As, Bs, Bs).
duodcg_cbody((A0,B0), (A,B), As0, As, Bs0, Bs) :-
    duodcg_body(A0, A, As0, As1, Bs0, Bs1),
    duodcg_body(B0, B, As1, As, Bs1, Bs).
duodcg_cbody((A0;B0), (A;B), As0, As, Bs0, Bs) :-
    \+ subsumes_term((_->_), A0),
    duodcg_body(A0, A, As0, As, Bs0, Bs),
    duodcg_body(B0, B, As0, As, Bs0, Bs).
duodcg_cbody((A0->B0;C0), (A->B;C), As0, As, Bs0, Bs) :-
    duodcg_body(A0, A, As0, As1, Bs0, Bs1),
    duodcg_body(B0, B, As1, As, Bs1, Bs),
    duodcg_body(C0, C, As0, As, Bs0, Bs).
duodcg_cbody((A->B), Body, As0, As, Bs0, Bs) :-
    duodcg_body((A->B;{false}), Body, As0, As, Bs0, Bs).

duodcg_append([], Es, Es).
duodcg_append([E|Es0], Es1, [E|Es]) :-
    duodcg_append(Es0, Es1, Es).

duodcg_sequence([]) --> [].
duodcg_sequence([E|Es]) --> [E], duodcg_sequence(Es).
