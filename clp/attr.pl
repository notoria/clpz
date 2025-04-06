% goal_expansion(get_attr(Var, Module, Value), (var(Var),get_atts(Var, +Access))) :-
%         Access =.. [Module,Value].

get_attr(Var, Module, Value) :-
    Access =.. [Module,Value],
    (var(Var),get_atts(Var, +Access)).

% goal_expansion(put_attr(Var, Module, Value), put_atts(Var, +Access)) :-
%         Access =.. [Module,Value].

put_attr(Var, Module, Value) :-
    Access =.. [Module,Value],
    put_atts(Var, +Access).

% goal_expansion(del_attr(Var, Module), (var(Var) -> put_atts(Var, -Access);true)) :-
%         Access =.. [Module,_].

del_attr(Var, Module) :-
    Access =.. [Module,_],
    (var(Var) -> put_atts(Var, -Access);true).
