:- set_prolog_flag(double_quotes, chars).

% :- dynamic(user:term_expansion/6).
% :- discontiguous(user:term_expansion/6).
:- multifile(user:term_expansion/6).

user:term_expansion(
    term_expansion(T0,T), Layout, Token,
    [(:- discontiguous(user:term_expansion/6)),(:- multifile(user:term_expansion/6)),user:term_expansion(T0,L,Tk,T,L,Tk)], Layout, Token
).
user:term_expansion(
    (term_expansion(T0,T):-G), Layout, Token,
    [(:- discontiguous(user:term_expansion/6)),(:- multifile(user:term_expansion/6)),(user:term_expansion(T0,L,Tk,T,L,Tk):-G)], Layout, Token
).

user:term_expansion(
    term_expansion(T0,Ts0,[]), Layout, Token,
    [(:- discontiguous(user:term_expansion/6)),(:- multifile(user:term_expansion/6)),user:term_expansion(T0,L,Tk,Ts0,L,Tk)], Layout, Token
).
user:term_expansion(
    (term_expansion(T0,Ts0,[]):-G), Layout, Token,
    [(:- discontiguous(user:term_expansion/6)),(:- multifile(user:term_expansion/6)),(user:term_expansion(T0,L,Tk,Ts0,L,Tk):-G)], Layout, Token
).

% term_expansion(
%     term_expansion(T0,Ts0,[]), term_expansion(T0,L,Tk,Ts0,L,Tk)
% ).
% term_expansion(
%     (term_expansion(T0,Ts0,[]):-G), (term_expansion(T0,L,Tk,Ts0,L,Tk):-G)
% ).

% term_expansion(
%     goal_expansion(G0,G), goal_expansion(G0,_,M,G,[])
% ).

term_expansion((:- flag(F,V)), (:- set_prolog_flag(F,V))).
term_expansion((:- include(Cs)), (:- include(A))) :-
    ground(Cs),
    Cs = [_|_],
    atom_chars(A, Cs).

:- flag(debug, on). % -DSP_JIT=disabled
