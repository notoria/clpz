list_without_(_, [], []).
list_without_(E, [E0|Es0], Es1) :-
    if_(dif(E, E0), [E0|Es] = Es1, Es = Es1),
    list_without_(E, Es0, Es).
