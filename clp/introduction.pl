/** Constraint Logic Programming over Integers

## Introduction

This library provides CLP(ℤ): Constraint Logic Programming over
Integers.

CLP(ℤ) is an instance of the general CLP(_X_) scheme, extending logic
programming with reasoning over specialised domains. CLP(ℤ) lets us
reason about *integers* in a way that honors the relational nature
of Prolog.

There are two major use cases of CLP(ℤ) constraints:

    1. [*declarative integer arithmetic*](#clpz-integer-arith)

    2. solving *combinatorial problems* such as planning, scheduling
       and allocation tasks.

The predicates of this library can be classified as:

    * _arithmetic_ constraints like `(#=)/2`, `(#>)/2` and `(#\=)/2`
    * the _membership_ constraints `(in)/2` and `(ins)/2`
    * the _enumeration_ predicates `indomain/1`, `label/1` and `labeling/2`
    * _combinatorial_ constraints like `all_distinct/1` and `global_cardinality/2`
    * _reification_ predicates such as `(#<==>)/2`
    * _reflection_ predicates such as `fd_dom/2`

In most cases, [_arithmetic constraints_](#clpz-arith-constraints)
are the only predicates you will ever need from this library. When
reasoning over integers, simply replace low-level arithmetic
predicates like `(is)/2` and `(>)/2` by the corresponding CLP(ℤ)
constraints like `(#=)/2` and `(#>)/2` to honor and preserve declarative
properties of your programs. For satisfactory performance, arithmetic
constraints are implicitly rewritten at compilation time so that
low-level fallback predicates are automatically used whenever
possible.

Almost all Prolog programs also reason about integers. Therefore, it
is highly advisable that you make CLP(ℤ) constraints available in all
your programs. One way to do this is to put the following directive in
your `~/.scryerrc` initialisation file:

```
:- use_module(library(clpz)).
```

All example programs that appear in the CLP(ℤ) documentation assume
that you have done this.

Important concepts and principles of this library are illustrated by
means of usage examples that are available in a public git repository:
[*https://github.com/triska/clpz*](https://github.com/triska/clpz)

If you are used to the complicated operational considerations that
low-level arithmetic primitives necessitate, then moving to CLP(ℤ)
constraints may, due to their power and convenience, at first feel to
you excessive and almost like cheating. It _isn't_. Constraints are an
integral part of all popular Prolog systems, and they are designed
to help you eliminate and avoid the use of low-level and less general
primitives by providing declarative alternatives that are meant to be
used instead.

When teaching Prolog, CLP(ℤ) constraints should be introduced
_before_ explaining low-level arithmetic predicates and their
procedural idiosyncrasies. This is because constraints are easy to
explain, understand and use due to their purely relational nature. In
contrast, the modedness and directionality of low-level arithmetic
primitives are impure limitations that are better deferred to more
advanced lectures.

More information about CLP(ℤ) constraints and their implementation is
contained in: [*metalevel.at/drt.pdf*](https://www.metalevel.at/drt.pdf)

The best way to discuss applying, improving and extending CLP(ℤ)
constraints is to use the dedicated `clpz` tag on
[stackoverflow.com](http://stackoverflow.com). Several of the world's
foremost CLP(ℤ) experts regularly participate in these discussions
and will help you for free on this platform.

{#clpz-arith-constraints}
## Arithmetic constraints

In modern Prolog systems, *arithmetic constraints* subsume and
supersede low-level predicates over integers. The main advantage of
arithmetic constraints is that they are true _relations_ and can be
used in all directions. For most programs, arithmetic constraints are
the only predicates you will ever need from this library.

The most important arithmetic constraint is `(#=)/2`, which subsumes
both `(is)/2` and `(=:=)/2` over integers. Use `(#=)/2` to make your
programs more general.

In total, the arithmetic constraints are:

| Expr1 `#=`  Expr2  | Expr1 equals Expr2                       |
| Expr1 `#\=` Expr2  | Expr1 is not equal to Expr2              |
| Expr1 `#>=` Expr2  | Expr1 is greater than or equal to Expr2  |
| Expr1 `#=<` Expr2  | Expr1 is less than or equal to Expr2     |
| Expr1 `#>` Expr2   | Expr1 is greater than Expr2              |
| Expr1 `#<` Expr2   | Expr1 is less than Expr2                 |

`Expr1` and `Expr2` denote *arithmetic expressions*, which are:

| _integer_          | Given value                          |
| _variable_         | Unknown integer                      |
| #(_variable_)      | Unknown integer                      |
| -Expr              | Unary minus                          |
| Expr + Expr        | Addition                             |
| Expr * Expr        | Multiplication                       |
| Expr - Expr        | Subtraction                          |
| Expr ^ Expr        | Exponentiation                       |
| min(Expr,Expr)     | Minimum of two expressions           |
| max(Expr,Expr)     | Maximum of two expressions           |
| Expr `mod` Expr    | Modulo induced by floored division   |
| Expr `rem` Expr    | Modulo induced by truncated division |
| abs(Expr)          | Absolute value                       |
| sign(Expr)         | Sign (-1, 0, 1) of Expr              |
| Expr // Expr       | Truncated integer division           |
| Expr div Expr      | Floored integer division             |

where `Expr` again denotes an arithmetic expression.

The bitwise operations `(\)/1`, `(/\)/2`, `(\/)/2`, `(>>)/2`,
`(<<)/2`, `lsb/1`, `msb/1`, `popcount/1` and `(xor)/2` are also
supported.

{#clpz-integer-arith}
## Declarative integer arithmetic

The [_arithmetic constraints_](#clpz-arith-constraints) `(#=)/2`,
`(#>)/2` etc. are meant to be used _instead_ of the primitives
`(is)/2`, `(=:=)/2`, `(>)/2` etc. over integers. Almost all Prolog
programs also reason about integers. Therefore, it is recommended that
you put the following directive in your `~/.scryerrc` initialisation
file to make CLP(ℤ) constraints available in all your programs:

```
:- use_module(library(clpz)).
```

Throughout the following, it is assumed that you have done this.

The most basic use of CLP(ℤ) constraints is _evaluation_ of
arithmetic expressions involving integers. For example:

```
?- X #= 1+2.
   X = 3.
```

This could in principle also be achieved with the lower-level
predicate `(is)/2`. However, an important advantage of arithmetic
constraints is their purely relational nature: Constraints can be used
in _all directions_, also if one or more of their arguments are only
partially instantiated. For example:

```
?- 3 #= Y+2.
   Y = 1.
```

This relational nature makes CLP(ℤ) constraints easy to explain and
use, and well suited for beginners and experienced Prolog programmers
alike. In contrast, when using low-level integer arithmetic, we get:

```
?- 3 is Y+2.
   error(instantiation_error,(is)/2).

?- 3 =:= Y+2.
   error(instantiation_error,(is)/2).
```

Due to the necessary operational considerations, the use of these
low-level arithmetic predicates is considerably harder to understand
and should therefore be deferred to more advanced lectures.

For supported expressions, CLP(ℤ) constraints are drop-in
replacements of these low-level arithmetic predicates, often yielding
more general programs. See [`n_factorial/2`](#clpz-factorial) for an
example.

This library uses `goal_expansion/2` to automatically rewrite
constraints at compilation time so that low-level arithmetic
predicates are _automatically_ used whenever possible. For example,
the predicate:

```
positive_integer(N) :- N #>= 1.
```

is executed as if it were written as:

```
positive_integer(N) :-
        (   integer(N)
        ->  N >= 1
        ;   N #>= 1
        ).
```

This illustrates why the performance of CLP(ℤ) constraints is almost
always completely satisfactory when they are used in modes that can be
handled by low-level arithmetic. To disable the automatic rewriting,
set the Prolog flag `clpz_goal_expansion` to `false`.

If you are used to the complicated operational considerations that
low-level arithmetic primitives necessitate, then moving to CLP(ℤ)
constraints may, due to their power and convenience, at first feel to
you excessive and almost like cheating. It _isn't_. Constraints are an
integral part of all popular Prolog systems, and they are designed
to help you eliminate and avoid the use of low-level and less general
primitives by providing declarative alternatives that are meant to be
used instead.


{#clpz-factorial}
## Example: Factorial relation

We illustrate the benefit of using `(#=)/2` for more generality with a
simple example.

Consider first a rather conventional definition of `n_factorial/2`,
relating each natural number _N_ to its factorial _F_:

```
n_factorial(0, 1).
n_factorial(N, F) :-
        N #> 0,
        N1 #= N - 1,
        n_factorial(N1, F1),
        F #= N * F1.
```

This program uses CLP(ℤ) constraints _instead_ of low-level
arithmetic throughout, and everything that _would have worked_ with
low-level arithmetic _also_ works with CLP(ℤ) constraints, retaining
roughly the same performance. For example:

```
?- n_factorial(47, F).
   F = 258623241511168180642964355153611979969197632389120000000000
;  false.
```

Now the point: Due to the increased flexibility and generality of
CLP(ℤ) constraints, we are free to _reorder_ the goals as follows:

```
n_factorial(0, 1).
n_factorial(N, F) :-
        N #> 0,
        N1 #= N - 1,
        F #= N * F1,
        n_factorial(N1, F1).
```

In this concrete case, _termination_ properties of the predicate are
improved. For example, the following queries now both terminate:

```
?- n_factorial(N, 1).
   N = 0
;  N = 1
;  false.

?- n_factorial(N, 3).
   false.
```

To make the predicate terminate if _any_ argument is instantiated, add
the (implied) constraint `F #\= 0` before the recursive call.
Otherwise, the query `n_factorial(N, 0)` is the only non-terminating
case of this kind.

The value of CLP(ℤ) constraints does _not_ lie in completely freeing
us from _all_ procedural phenomena. For example, the two programs do
not even have the same _termination properties_ in all cases.
Instead, the primary benefit of CLP(ℤ) constraints is that they allow
you to try different execution orders and apply [*declarative
debugging*](https://www.metalevel.at/prolog/debugging)
techniques _at all_!  Reordering goals (and clauses) can significantly
impact the performance of Prolog programs, and you are free to try
different variants if you use declarative approaches. Moreover, since
all CLP(ℤ) constraints _always terminate_, placing them earlier can
at most _improve_, never worsen, the termination properties of your
programs. An additional benefit of CLP(ℤ) constraints is that they
eliminate the complexity of introducing `(is)/2` and `(=:=)/2` to
beginners, since _both_ predicates are subsumed by `(#=)/2` when
reasoning over integers.

{#clpz-combinatorial}
## Combinatorial constraints

In addition to subsuming and replacing low-level arithmetic
predicates, CLP(ℤ) constraints are often used to solve combinatorial
problems such as planning, scheduling and allocation tasks. Among the
most frequently used *combinatorial constraints* are `all_distinct/1`,
`global_cardinality/2` and `cumulative/2`. This library also provides
several other constraints like `disjoint2/1` and `automaton/8`, which are
useful in more specialized applications.

{#clpz-domains}
## Domains

Each CLP(ℤ) variable has an associated set of admissible integers,
which we call the variable's *domain*. Initially, the domain of each
CLP(ℤ) variable is the set of _all_ integers. CLP(ℤ) constraints like
`(#=)/2`, `(#>)/2` and `(#\=)/2` can at most reduce, and never extend,
the domains of their arguments. The constraints `(in)/2` and `(ins)/2`
let us explicitly state domains of CLP(ℤ) variables. The process of
determining and adjusting domains of variables is called constraint
*propagation*, and it is performed automatically by this library. When
the domain of a variable contains only one element, then the variable
is automatically unified to that element.

Domains are taken into account when further constraints are stated,
and by enumeration predicates like labeling/2.

{#clpz-sudoku}
## Example: Sudoku

As another example, consider _Sudoku_: It is a popular puzzle
over integers that can be easily solved with CLP(ℤ) constraints.

```
sudoku(Rows) :-
        list_length(Rows, 9), list_map(list_equisized(Rows), Rows),
        list_append(Rows, Vs), Vs ins 1..9,
        list_map(all_distinct, Rows),
        transpose(Rows, Columns),
        list_map(all_distinct, Columns),
        Rows = [As,Bs,Cs,Ds,Es,Fs,Gs,Hs,Is],
        blocks(As, Bs, Cs),
        blocks(Ds, Es, Fs),
        blocks(Gs, Hs, Is).

blocks([], [], []).
blocks([N1,N2,N3|Ns1], [N4,N5,N6|Ns2], [N7,N8,N9|Ns3]) :-
        all_distinct([N1,N2,N3,N4,N5,N6,N7,N8,N9]),
        blocks(Ns1, Ns2, Ns3).

problem(1, [[_,_,_,_,_,_,_,_,_],
            [_,_,_,_,_,3,_,8,5],
            [_,_,1,_,2,_,_,_,_],
            [_,_,_,5,_,7,_,_,_],
            [_,_,4,_,_,_,1,_,_],
            [_,9,_,_,_,_,_,_,_],
            [5,_,_,_,_,_,_,7,3],
            [_,_,2,_,1,_,_,_,_],
            [_,_,_,_,4,_,_,_,9]]).
```

Sample query:

```
?- problem(1, Rows), sudoku(Rows), list_map(portray_clause, Rows).
[9,8,7,6,5,4,3,2,1].
[2,4,6,1,7,3,9,8,5].
[3,5,1,9,2,8,7,4,6].
[1,2,8,5,3,7,6,9,4].
[6,3,4,8,9,2,1,5,7].
[7,9,5,4,6,1,8,3,2].
[5,1,9,2,8,6,4,7,3].
[4,7,2,3,1,9,5,6,8].
[8,6,3,7,4,5,2,1,9].
   Rows = [[9,8,7,6,5,4,3,2,1]|...].
```

In this concrete case, the constraint solver is strong enough to find
the unique solution without any search.


{#clpz-residual-goals}
## Residual goals

Here is an example session with a few queries and their answers:

```
?- X #> 3.
   clpz:(X in 4..sup).

?- X #\= 20.
   clpz:(X in inf..19\/21..sup).

?- 2*X #= 10.
   X = 5.

?- X*X #= 144.
   clpz:(X in-12\/12)
;  false.

?- 4*X + 2*Y #= 24, X + Y #= 9, [X,Y] ins 0..sup.
   X = 3, Y = 6.

?- X #= Y #<==> B, X in 0..3, Y in 4..5.
   B = 0, clpz:(X in 0..3), clpz:(Y in 4..5).
```

The answers emitted by the toplevel are called _residual programs_,
and the goals that comprise each answer are called *residual goals*.
In each case above, and as for all pure programs, the residual program
is declaratively equivalent to the original query. From the residual
goals, it is clear that the constraint solver has deduced additional
domain restrictions in many cases.

To inspect residual goals, it is best to let the toplevel display them
for us. Wrap the call of your predicate into `call_residue_vars/2` to
make sure that all constrained variables are displayed. To make the
constraints a variable is involved in available as a Prolog term for
further reasoning within your program, use `copy_term/3`. For example:

```
?- X #= Y + Z, X in 0..5, copy_term([X,Y,Z], [X,Y,Z], Gs).
Gs = [clpz: (X in 0..5), clpz: (Y+Z#=X)],
X in 0..5,
Y+Z#=X.
```

This library also provides _reflection_ predicates (like `fd_dom/2`,
`fd_size/2` etc.) with which we can inspect a variable's current
domain. These predicates can be useful if you want to implement your
own labeling strategies.

{#clpz-search}
## Core relations and search

Using CLP(ℤ) constraints to solve combinatorial tasks typically
consists of two phases:

    1. First, all relevant constraints are stated.
    2. Second, if the domain of each involved variable is _finite_,
       then _enumeration predicates_ can be used to search for
       concrete solutions.

It is good practice to keep the modeling part, via a dedicated
predicate called the *core relation*, separate from the actual
search for solutions. This lets us observe termination and
determinism properties of the core relation in isolation from the
search, and more easily try different search strategies.

As an example of a constraint satisfaction problem, consider the
cryptoarithmetic puzzle SEND + MORE = MONEY, where different letters
denote distinct integers between 0 and 9. It can be modeled in CLP(ℤ)
as follows:

```
puzzle([S,E,N,D] + [M,O,R,E] = [M,O,N,E,Y]) :-
        Vars = [S,E,N,D,M,O,R,Y],
        Vars ins 0..9,
        all_different(Vars),
                  S*1000 + E*100 + N*10 + D +
                  M*1000 + O*100 + R*10 + E #=
        M*10000 + O*1000 + N*100 + E*10 + Y,
        M #\= 0, S #\= 0.
```

Notice that we are _not_ using `labeling/2` in this predicate, so that
we can first execute and observe the modeling part in isolation.
Sample query and its result (actual variables replaced for
readability):

```
?- puzzle(As+Bs=Cs).
As = [9, A2, A3, A4],
Bs = [1, 0, B3, A2],
Cs = [1, 0, A3, A2, C5],
A2 in 4..7,
all_different([9, A2, A3, A4, 1, 0, B3, C5]),
91*A2+A4+10*B3#=90*A3+C5,
A3 in 5..8,
A4 in 2..8,
B3 in 2..8,
C5 in 2..8.
```

From this answer, we see that this core relation _terminates_ and is in
fact _deterministic_. Moreover, we see from the residual goals that
the constraint solver has deduced more stringent bounds for all
variables. Such observations are only possible if modeling and search
parts are cleanly separated.

Labeling can then be used to search for solutions in a separate
predicate or goal:

```
?- puzzle(As+Bs=Cs), label(As).
   As = [9,5,6,7], Bs = [1,0,8,5], Cs = [1,0,6,5,2]
;  false.
```

In this case, it suffices to label a subset of variables to find the
puzzle's unique solution, since the constraint solver is strong enough
to reduce the domains of remaining variables to singleton sets. In
general though, it is necessary to label all variables to obtain
ground solutions.

{#clpz-n-queens}
## Example: Eight queens puzzle

We illustrate the concepts of the preceding sections by means of the
so-called _eight queens puzzle_. The task is to place 8 queens on an
8x8 chessboard such that none of the queens is under attack. This
means that no two queens share the same row, column or diagonal.

To express this puzzle via CLP(ℤ) constraints, we must first pick a
suitable representation. Since CLP(ℤ) constraints reason over
_integers_, we must find a way to map the positions of queens to
integers. Several such mappings are conceivable, and it is not
immediately obvious which we should use. On top of that, different
constraints can be used to express the desired relations. For such
reasons, _modeling_ combinatorial problems via CLP(ℤ) constraints
often necessitates some creativity and has been described as more of
an art than a science.

In our concrete case, we observe that there must be exactly one queen
per column. The following representation therefore suggests itself: We
are looking for 8 integers, one for each column, where each integer
denotes the _row_ of the queen that is placed in the respective
column, and which are subject to certain constraints.

In fact, let us now generalize the task to the so-called _N queens
puzzle_, which is obtained by replacing 8 by _N_ everywhere it occurs
in the above description. We implement the above considerations in the
*core relation* `n_queens/2`, where the first argument is the number
of queens (which is identical to the number of rows and columns of the
generalized chessboard), and the second argument is a list of _N_
integers that represents a solution in the form described above.

```
n_queens(N, Qs) :-
        list_length(Qs, N),
        Qs ins 1..N,
        safe_queens(Qs).

safe_queens([]).
safe_queens([Q|Qs]) :- safe_queens(Qs, Q, 1), safe_queens(Qs).

safe_queens([], _, _).
safe_queens([Q|Qs], Q0, D0) :-
        Q0 #\= Q,
        abs(Q0 - Q) #\= D0,
        D1 #= D0 + 1,
        safe_queens(Qs, Q0, D1).
```

Note that all these predicates can be used in _all directions_: We
can use them to _find_ solutions, _test_ solutions and _complete_
partially instantiated solutions.

The original task can be readily solved with the following query:

```
?- n_queens(8, Qs), label(Qs).
   Qs = [1,5,8,6,3,7,2,4]
;  ... .
```

Using suitable labeling strategies, we can easily find solutions with
80 queens and more:

```
?- n_queens(80, Qs), labeling([ff], Qs).
   Qs = [1,3,5,44,42,4,50,7,68,57,76,61,6,39,30,40,8,54,36,41|...]
;  ... .

?- time((n_queens(90, Qs), labeling([ff], Qs))).
   % CPU time: 2.382s
   Qs = [1,3,5,50,42,4,49,7,59,48,46,63,6,55,47,64,8,70,58,67|...]
;  ... .
```

Experimenting with different search strategies is easy because we have
separated the core relation from the actual search.



{#clpz-optimisation}
## Optimisation

We can use `labeling/2` to minimize or maximize the value of a CLP(ℤ)
expression, and generate solutions in increasing or decreasing order
of the value. See the labeling options `min(Expr)` and `max(Expr)`,
respectively.

Again, to easily try different labeling options in connection with
optimisation, we recommend to introduce a dedicated predicate for
posting constraints, and to use `labeling/2` in a separate goal. This
way, we can observe properties of the core relation in isolation,
and try different labeling options without recompiling our code.

If necessary, we can use `once/1` to commit to the first optimal
solution. However, it is often very valuable to see alternative
solutions that are _also_ optimal, so that we can choose among optimal
solutions by other criteria. For the sake of
[*purity*](https://www.metalevel.at/prolog/purity) and
completeness, we recommend to avoid `once/1` and other constructs that
lead to impurities in CLP(ℤ) programs.

Related to optimisation with CLP(ℤ) constraints are `library(simplex)`
and CLP(Q) which reason about _linear_ constraints over rational
numbers.

{#clpz-reification}
## Reification

The constraints `(in)/2`, `(#=)/2`, `(#\=)/2`, `(#<)/2`, `(#>)/2`,
`(#=<)/2`, and `(#>=)/2` can be _reified_, which means reflecting
their truth values into Boolean values represented by the integers 0
and 1. Let P and Q denote reifiable constraints or Boolean variables,
then:

| `#\ Q`      | True iff Q is false                  |
| `P #\/ Q`   | True iff either P or Q               |
| `P #/\ Q`   | True iff both P and Q                |
| `P #\ Q`    | True iff either P or Q, but not both |
| `P #<==> Q` | True iff P and Q are equivalent      |
| `P #==> Q`  | True iff P implies Q                 |
| `P #<== Q`  | True iff Q implies P                 |

The constraints of this table are reifiable as well.

When reasoning over Boolean variables, also consider using CLP(B)
constraints as provided by `library(clpb)`.

{#clpz-monotonicity}
## Enabling monotonic CLP(ℤ)

In the default execution mode, CLP(ℤ) constraints still exhibit some
non-relational properties. For example, _adding_ constraints can yield
new solutions:

```
?-          X #= 2, X = 1+1.
   false.

?- X = 1+1, X #= 2, X = 1+1.
   X = 1+1.
```

This behaviour is highly problematic from a logical point of view, and
it may render declarative debugging techniques inapplicable.

Assert `clpz:monotonic` to make CLP(ℤ) *monotonic*: This means
that _adding_ new constraints _cannot_ yield new solutions. When this
flag is `true`, we must wrap variables that occur in arithmetic
expressions with the functor `(?)/1` or `(#)/1`. For example:

```
?- assertz(clpz:monotonic).
   true.

?- #X #= #Y + #Z.
   clpz:(#Y+ #Z#= #X).

?-          X #= 2, X = 1+1.
   error(instantiation_error,instantiation_error(unknown(_408),1)).
```

The wrapper can be omitted for variables that are already constrained
to integers.

{#clpz-custom-constraints}
## Custom constraints

We can define custom constraints. The mechanism to do this is not yet
finalised, and we welcome suggestions and descriptions of use cases
that are important to you.

As an example of how it can be done currently, let us define a new
custom constraint `oneground(X,Y,Z)`, where Z shall be 1 if at least
one of X and Y is instantiated:

```
:- multifile clpz:propagate/2.

oneground(X, Y, Z) :-
        clpz:propagator_from_constraint(oneground(X, Y, Z), Prop),
        clpz:propagator_variable(Prop, X),
        clpz:propagator_variable(Prop, Y),
        clpz:queue_empty(Q),
        phrase((clpz:propagator_queue(P), clpz:propagator_catalyze), [Q], _).

clpz:propagate(oneground(X, Y, Z), MState) :-
        (   integer(X) -> clpz:kill(MState), Z = 1
        ;   integer(Y) -> clpz:kill(MState), Z = 1
        ;   true
        ).
```

First, `clpz:propagator_from_constraint/2` is used to transform a user-defined
representation of the new constraint to an internal form. With
`clpz:propagator_variable/2`, this internal form is then attached to X and
Y. From now on, the propagator will be invoked whenever the domains of
X or Y are changed. Then, `clpz:trigger_once/1` is used to give the
propagator its first chance for propagation even though the variables'
domains have not yet changed. Finally, `clpz:propagate/2` is
extended to define the actual propagator. As explained, this predicate
is automatically called by the constraint solver. The first argument
is the user-defined representation of the constraint as used in
`clpz:propagator_from_constraint/2`, and the second argument is a mutable state
that can be used to prevent further invocations of the propagator when
the constraint has become entailed, by using `clpz:kill/1`. An example
of using the new constraint:

```
?- oneground(X, Y, Z), Y = 5.
Y = 5,
Z = 1,
X in inf..sup.
```

@author [Markus Triska](https://www.metalevel.at)
*/
