/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A bound is either:

   n(N):    integer N
   inf:     infimum of Z (= negative infinity)
   sup:     supremum of Z (= positive infinity)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

bound(inf).
bound(n(N)) :-
    integer(N).
bound(sup).

bound_from_defaulty(D, _) :-
    var(D),
    throw(error(instantiation_error,bound_from_defaulty/2)).
bound_from_defaulty(D, P) :-
    integer(D),
    P = n(D).
bound_from_defaulty(inf, inf).
bound_from_defaulty(sup, sup).

bound_to_defaulty(inf, inf).
bound_to_defaulty(n(N), N).
bound_to_defaulty(sup, sup).

bound_finite(inf, false).
bound_finite(n(_), true).
bound_finite(sup, false).
