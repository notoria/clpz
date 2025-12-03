%% cumulative(+Tasks)
%
%  Equivalent to cumulative(Tasks, [limit(1)]).

cumulative(Tasks) :- cumulative(Tasks, [limit(1)]).

%% cumulative(+Tasks, +Options)
%
%  Schedule with a limited resource. Tasks is a list of tasks, each of
%  the form task(S_i, D_i, E_i, C_i, T_i). S_i denotes the start time,
%  D_i the positive duration, E_i the end time, C_i the non-negative
%  resource consumption, and T_i the task identifier. Each of these
%  arguments must be a finite domain variable with bounded domain, or
%  an integer. The constraint holds iff at each time slot during the
%  start and end of each task, the total resource consumption of all
%  tasks running at that time does not exceed the global resource
%  limit. Options is a list of options. Currently, the only supported
%  option is:
%
%    * limit(L)
%      The integer L is the global resource limit. Default is 1.
%
%  For example, given the following predicate that relates three tasks
%  of durations 2 and 3 to a list containing their starting times:
%
% ```
%  tasks_starts(Tasks, [S1,S2,S3]) :-
%          Tasks = [task(S1,3,_,1,_),
%                   task(S2,2,_,1,_),
%                   task(S3,2,_,1,_)].
% ```
%
%  We can use cumulative/2 as follows, and obtain a schedule:
%
% ```
%  ?- tasks_starts(Tasks, Starts), Starts ins 0..10,
%     cumulative(Tasks, [limit(2)]), label(Starts).
%  Tasks = [task(0, 3, 3, 1, _G36), task(0, 2, 2, 1, _G45), ...],
%  Starts = [0, 0, 2] .
% ```

cumulative(Tasks, Options) :-
        must_be(list(list), [Tasks,Options]),
        (   Options = [] -> L = 1
        ;   Options = [limit(L)] -> must_be(integer, L)
        ;   domain_error(cumulative_options_empty_or_limit, Options)
        ),
        (   Tasks = [] -> true
        ;   fully_elastic_relaxation(Tasks, L),
            list_map(task_bs, Tasks, Bss),
            list_map(arg(1), Tasks, Starts),
            list_map(fd_inf, Starts, MinStarts),
            list_map(arg(3), Tasks, Ends),
            list_map(fd_sup, Ends, MaxEnds),
            MinStarts = [Min|Mins],
            list_foldl(min_, Mins, Min, Start),
            MaxEnds = [Max|Maxs],
            list_foldl(max_, Maxs, Max, End),
            resource_limit(Start, End, Tasks, Bss, L)
        ).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Trivial lower and upper bounds, assuming no gaps and not necessarily
   retaining the rectangular shape of each task.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

fully_elastic_relaxation(Tasks, Limit) :-
        list_map(task_duration_consumption, Tasks, Ds, Cs),
        list_map(area, Ds, Cs, As),
        sum(As, #=, #Area),
        #MinTime #= (#Area + #Limit - #1) // #Limit,
        tasks_minstart_maxend(Tasks, MinStart, MaxEnd),
        #MaxEnd #>= #MinStart + #MinTime.

task_duration_consumption(task(_,D,_,C,_), D, C).

area(X, Y, Area) :- #Area #= #X * #Y.

tasks_minstart_maxend(Tasks, Start, End) :-
        list_map(task_start_end, Tasks, [Start0|Starts], [End0|Ends]),
        list_foldl(min_, Starts, Start0, Start),
        list_foldl(max_, Ends, End0, End).

max_(E, M0, M) :- #M #= max(#E,#M0).

min_(E, M0, M) :- #M #= min(#E,#M0).

task_start_end(task(Start,_,End,_,_), Start, End).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   All time slots must respect the resource limit.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

resource_limit(T0, T, Tasks, Bss, L) :-
    (   T0 = T
    ->  true
    ;   list_map(contribution_at(T0), Tasks, Bss, Cs),
        sum(Cs, #=<, L),
        integer_add(1, T0, T1),
        resource_limit(T1, T, Tasks, Bss, L)
    ).

task_bs(Task, InfStart-Bs) :-
        Task = task(Start,D,End,_,_Id),
        #D #> #0,
        #End #= #Start + #D,
        list_map(finite_domain, [End,Start,D]),
        fd_inf(Start, InfStart),
        fd_sup(End, SupEnd),
        integer_add(L, InfStart, SupEnd), % L #= SupEnd-InfStart,
        list_length(Bs, L),
        task_running(Bs, Start, End, InfStart).

task_running([], _, _, _).
task_running([B|Bs], Start, End, T0) :-
        ((#T0 #>= #Start) #/\ (#T0 #< #End)) #<==> #B,
        integer_add(1, T0, T1),
        task_running(Bs, Start, End, T1).

contribution_at(T, Task, Offset-Bs, Contribution) :-
        Task = task(Start,_,End,C,_),
        #C #>= #0,
        fd_inf(Start, InfStart),
        fd_sup(End, SupEnd),
        (   T < InfStart -> Contribution = 0
        ;   T >= SupEnd -> Contribution = 0
        ;   integer_add(Index, Offset, T), % Index #= T-Offset
            list_nth0(Index, Bs, B),
            #Contribution #= #B * #C
        ).
