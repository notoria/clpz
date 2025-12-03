:- module(countall, [countall/2]).

:- use_module(library(structs),
         [new/2,
          dispose/1,
          get_contents/3,
          put_contents/3]).

:- meta_predicate(countall(0, ?)).
:- meta_predicate('@countall'(0, ?)).

countall(Goal_0, Count) :-
   new(unsigned_64, Counter),
   call_cleanup('@countall'(Goal_0, Counter, Count), dispose(Counter)).

'@countall'(Goal_0, Counter, _Count) :-
   call(Goal_0),
   get_contents(Counter, contents, Count0),
   Count1 is Count0+1,
   put_contents(Counter, contents, Count1),
   fail.
'@countall'(_Goal_0, Counter, Count) :-
   get_contents(Counter, contents, Count).
