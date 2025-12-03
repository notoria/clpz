:- attribute
        clpz/1,
        clpz_aux/1,
        clpz_relation/1,
        edges/1,
        flow/1,
        parent/1,
        free/1,
        g0_edges/1,
        used/1,
        lowlink/1,
        value/1,
        visited/1,
        index/1,
        in_stack/1,
        clpz_gcc_vs/1,
        clpz_gcc_num/1,
        clpz_gcc_occurred/1,
        queue/2,
        disabled/0.

:- dynamic(monotonic/0).
:- dynamic(clpz_equal_/2).
:- dynamic(clpz_geq_/2).
:- dynamic(clpz_neq/2).

monotonic.
