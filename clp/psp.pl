/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Projection of scalar product.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

scalar_product_left_right(Cs, Vs, Left, Right) :-
        pairs_keys_values(Pairs0, Cs, Vs),
        partition(ground, Pairs0, Grounds, Pairs),
        maplist(pair_product, Grounds, Prods),
        sum_list(Prods, Const),
        NConst is -Const,
        partition(compare_coeff0, Pairs, Negatives, _, Positives),
        maplist(negate_coeff, Negatives, Rights),
        scalar_plusterm(Rights, Right0),
        scalar_plusterm(Positives, Left0),
        (   Const =:= 0 -> Left = Left0, Right = Right0
        ;   Right0 == 0 -> Left = Left0, Right = NConst
        ;   Left0 == 0 ->  Left = Const, Right = Right0
        ;   (   Const < 0 ->
                Left = Left0,       Right = Right0+NConst
            ;   Left = Left0+Const, Right = Right0
            )
        ).

negate_coeff(A0-B, A-B) :- A is -A0.

pair_product(A-B, Prod) :- Prod is A*B.

compare_coeff0(Coeff-_, Compare) :- compare(Compare, Coeff, 0).

scalar_plusterm([], 0).
scalar_plusterm([CV|CVs], T) :-
        coeff_var_term(CV, T0),
        foldl(plusterm_, CVs, T0, T).

plusterm_(CV, T0, T0+T) :- coeff_var_term(CV, T).

coeff_var_term(C-V, T) :- ( C =:= 1 -> T = #V ; T = C * #V ).
