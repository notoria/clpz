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
        call(NT, As0, As, Bs0, Bs).

%:- multifile user:term_expansion/6.
term_expansion(Term0, Term) :-
        nonvar(Term0),
        Term0 = (Head0 ++> Body0),
        Term = (Head :- Body),
        duodcg_head(Head0, Head, As0, As, Bs0, Bs),
        once(duodcg_body(Body0, Body, As0, As, Bs0, Bs)).

duodcg_body([], (As0=As,Bs0=Bs), As0, As, Bs0, Bs).
duodcg_body(Xs+Ys, (phrase(seq(Xs), As0, As),
                       phrase(seq(Ys), Bs0, Bs)), As0, As, Bs0, Bs).
duodcg_body({Goal}, call(Goal), As, As, Bs, Bs).
duodcg_body((A0,B0), (A,B), As0, As, Bs0, Bs) :-
        duodcg_body(A0, A, As0, As1, Bs0, Bs1),
        duodcg_body(B0, B, As1, As, Bs1, Bs).
duodcg_body((A0->B0;C0), (A->B;C), As0, As, Bs0, Bs) :-
        duodcg_body(A0, A, As0, As1, Bs0, Bs1),
        duodcg_body(B0, B, As1, As, Bs1, Bs),
        duodcg_body(C0, C, As0, As, Bs0, Bs).
duodcg_body((A->B), Body, As0, As, Bs0, Bs) :-
        duodcg_body((A->B;false), Body, As0, As, Bs0, Bs).
duodcg_body((A0;B0), (A;B), As0, As, Bs0, Bs) :-
        duodcg_body(A0, A, As0, As, Bs0, Bs),
        duodcg_body(B0, B, As0, As, Bs0, Bs).
duodcg_body(NT0, NT, As0, As, Bs0, Bs) :-
        duodcg_head(NT0, NT, As0, As, Bs0, Bs).

duodcg_head(Head0, Head, As0, As, Bs0, Bs) :-
        Head0 =.. [F|Args0],
        append(Args0, [As0,As,Bs0,Bs], Args),
        Head =.. [F|Args].
