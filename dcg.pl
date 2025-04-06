% :- include("lists").

phrase(NT, S0) :-
    phrase(NT, S0, []).

phrase(NT, S0, S) :-
    (   var(NT)
    ->  throw(error(instantiation_error,phrase/3))
    ;   dcg_constr(NT),
        catch(dcg_body(NT, S0, S, G), error(E,_), throw(error(E,phrase/3)))
        % dcg_body(NT, S0, S, G)
    ->  call(G)
    ;   call(NT, S0, S)
    ).

dcg_append([], Es, Es).
dcg_append([E|Es0], Es1, [E|Es]) :-
    dcg_append(Es0, Es1, Es).

:- op(1200,xfx,-->).

% This program uses append/3 as defined in the Prolog prologue.
% Expands a DCG rule into a Prolog rule, when no error condition applies.
% dcg_rule/2 expands a DCG rule into a Prolog rule, when no error
% condition is satisfied.

:- op(1105,xfy,'|').

dcg_rule(( NonTerminal, Terminals --> GRBody ), ( Head :- Body )) :-
   dcg_non_terminal(NonTerminal, S0,S, Head),
   dcg_body(GRBody, S0,S1, Goal1),
   dcg_terminals(Terminals, S, S1, Goal2),
   Body = ( Goal1, Goal2 ).
dcg_rule(( NonTerminal --> GRBody ), ( Head :- Body )) :-
   NonTerminal \= ( _, _ ),
   dcg_non_terminal(NonTerminal, S0,S, Head),
   dcg_body(GRBody, S0,S, Body).

dcg_non_terminal(NonTerminal, S0,S, Goal) :-
   NonTerminal =.. NonTerminalUniv,
   dcg_append(NonTerminalUniv, [S0,S], GoalUniv),
   Goal =.. GoalUniv.

dcg_terminals(Terminals, S0,S, S0 = List) :-
   dcg_append(Terminals, S, List).

dcg_body(Var, _,_, _) :-
   var(Var),
   throw(error(instantiation_error,dcg_body/4)).
dcg_body(GRBody, S0,S, Body) :-
   nonvar(GRBody),
   dcg_constr(GRBody),
   dcg_cbody(GRBody, S0,S, Body).
dcg_body(NonTerminal, S0,S, Goal) :-
   nonvar(NonTerminal),
   \+ dcg_constr(NonTerminal),
   NonTerminal \= ( _ -> _ ),
   NonTerminal \= ( \+ _ ),
   dcg_non_terminal(NonTerminal, S0,S, Goal).

dcg_constr([]).        % 7.14.1
dcg_constr([_|_]).     % 7.14.2 - terminal sequence
dcg_constr(( _, _ )).  % 7.14.3 - concatenation
dcg_constr(( _ ; _ )). % 7.14.4 - alternative
                       % 7.14.5 - if-then-else
dcg_constr(( _'|'_ )). % 7.14.6 - alternative
dcg_constr({_}).       % 7.14.7
dcg_constr(call(_)).   % 7.14.8
dcg_constr(phrase(_)). % 7.14.9
dcg_constr(!).         % 7.14.10
dcg_constr(\+ _).    % 7.14.11 - not (existence impl. defined)
dcg_constr((_->_)).  % 7.14.12 - if-then (existence impl. defined)

dcg_cbody([], S0,S, S0 = S ).
dcg_cbody([T|Ts], S0,S, Goal) :-
   dcg_terminals([T|Ts], S0,S, Goal).
dcg_cbody(( GRFirst, GRSecond ), S0,S, ( First, Second )) :-
   dcg_body(GRFirst, S0,S1, First),
   dcg_body(GRSecond, S1,S, Second).
dcg_cbody(( GREither ; GROr ), S0,S, ( Either ; Or )) :-
   \+ subsumes_term(( _ -> _ ),GREither),
   dcg_body(GREither, S0,S, Either),
   dcg_body(GROr, S0,S, Or).
dcg_cbody(( GRCond ; GRElse ), S0,S, ( Cond ; Else )) :-
   subsumes_term(( _ -> _ ), GRCond),
   ( GRIf -> GRThen ) = GRCond,
   dcg_body(GRIf, S0,S1, If),
   dcg_body(GRThen, S1,S, Then),
   Cond = ( If -> Then ),
   dcg_body(GRElse, S0,S, Else).
dcg_cbody(( GREither '|' GROr ), S0,S, ( Either ; Or )) :-
   dcg_body(GREither, S0,S, Either),
   dcg_body(GROr, S0,S, Or).
dcg_cbody({Goal}, S0,S, ( Goal, S0 = S )).
dcg_cbody(call(Cont), S0,S, call(Cont, S0,S)).
dcg_cbody(phrase(Body), S0,S, phrase(Body, S0,S)).
dcg_cbody(!, S0,S, ( !, S0 = S )).
% dcg_cbody(\+ GRBody, S0,S, ( \+ phrase(GRBody,S0,_), S0 = S )).
dcg_cbody(\+ _, _,_, _) :-
   throw(error(representation_error(dcg),_)).
% dcg_cbody(( GRIf -> GRThen ), S0,S, ( If -> Then )) :-
%    dcg_body(GRIf, S0,S1, If),
%    dcg_body(GRThen, S1,S, Then).
dcg_cbody(( _ -> _ ), _,_, _) :-
   throw(error(representation_error(dcg),_)).


term_expansion(T0, T) :-
    nonvar(T0),
    once(dcg_rule(T0, T)).
