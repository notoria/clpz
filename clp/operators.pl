/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Public operators.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- op(760, yfx, #<==>).
:- op(750, xfy, #==>).
:- op(750, yfx, #<==).
:- op(740, yfx, #\/).
:- op(730, yfx, #\).
:- op(720, yfx, #/\).
:- op(710,  fy, #\).
:- op(700, xfx, #>).
:- op(700, xfx, #<).
:- op(700, xfx, #>=).
:- op(700, xfx, #=<).
:- op(700, xfx, #=).
:- op(700, xfx, #\=).
:- op(700, xfx, in).
:- op(700, xfx, ins).
:- op(450, xfx, ..). % should bind more tightly than \/
:- op(150, fx, #).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Privately needed operators.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- op(700, xfx, cis).
:- op(700, xfx, cis_ge).
:- op(700, xfx, cis_gt).
:- op(700, xfx, cis_le).
:- op(700, xfx, cis_lt).
:- op(1200, xfx, ++>).
:- op(800, xfx, =>).
