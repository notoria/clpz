?- A in -2..0, B in 0..2, #A #=< #B.
%@    clpz:(A in-2..0), clpz:(B in 0..2).
?- A in -2..0, B in -4..4, #A #=< #B.
%@    clpz:(A in-2..0), clpz:(#A#=< #B), clpz:(B in-2..4).
?- A in -4..4, B in 0..2, #A #=< #B.
%@    clpz:(A in-4..2), clpz:(#A#=< #B), clpz:(B in 0..2).
?- A in 0..2, B in -2..0, #A #=< #B.
%@    A=0, B=0.
?- A in 1..2, B in -2.. -1, #A #=< #B.
%@    false.
