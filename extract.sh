#!/bin/sh

home=$(pwd)
cd /tmp
rm -rf /tmp/scryer /tmp/clpz
git clone https://github.com/mthom/scryer-prolog scryer
cd scryer
git-filter-repo --path-regex '.*/clpz.pl'
# Extract patches
git format-patch --root
# Collapse file's path
for patch in $(ls *.patch); do
    sed -e 's/src\/prolog\/lib\/clpz/clpz/g' \
        -e 's/src\/lib\/clpz/clpz/g' \
        $patch > patch
    mv patch $patch
done
# sed -e 's/src\/{prolog => }\/lib\///' \
#     0015-remove-vestigial-prolog-directory-444.patch > patch
# mv patch 0015-remove-vestigial-prolog-directory-444.patch
rm 0015-remove-vestigial-prolog-directory-444.patch
# Unexpected duplicate
rm \
    0081-Remove-and-move-comments.patch \
    0082-Don-t-add-variable.patch \
    0083-Compute-correctly-the-domain-of-the-remainder.patch \
# popcount
rm \
    0041-ADDED-popcount-Integer.patch \
    0042-address-995-wrong-results-for-popcount-1.patch \
    0062-FIXED-use-lsb-2-and-msb-2-from-library-arithmetic.patch \
    0121-Trigger-propagator-for-popcount-1.patch
sed -e 's/-5482,6 +5484,21/-5482,5 +5484,21/' \
    -e '42s/ /+/' -e 's/Y = popcount(X)/Z = X xor Y/' \
    0046-ADDED-sign-1.patch > patch
mv patch 0046-ADDED-sign-1.patch
sed -e 's/-123,6 +123,8/-123,5 +123,7/' \
    -e '/:- use_module(library(arithmetic))/d' \
    0050-ENHANCED-CLP-Reduce-redundant-propagator-invocations.patch > patch
mv patch 0050-ENHANCED-CLP-Reduce-redundant-propagator-invocations.patch
sed -e 's/-7709,26 +7709,26/-7709,25 +7709,25/' -e '/popcount/d' \
    0055-use-1-already-internally-for-describing-constraint-p.patch > patch
mv patch 0055-use-1-already-internally-for-describing-constraint-p.patch
sed -e 's/-119,7 +119,7/-119,6 +119,6/' \
    -e '/:- use_module(library(arithmetic))/d' \
    0088-use-can_be-2.patch > patch
mv patch 0088-use-can_be-2.patch
sed -e 's/g(#A#>0) ,//' \
    0100-reorder-and-realign-entries-to-form-a-contiguous-gro.patch > patch
mv patch 0100-reorder-and-realign-entries-to-form-a-contiguous-gro.patch
sed -e 's/g(#A#>0) ,//' -e 's/g(#A#>0), //' \
    0120-Trigger-propagator-for-sign-1.patch > patch
mv patch 0120-Trigger-propagator-for-sign-1.patch
# morphed propagrators
rm \
    0107-ENHANCED-Remove-no-longer-needed-morphed-propagators.patch \
    0109-ENHANCED-Omit-projection-of-morphed-2-in-disentailed.patch \
    0110-attach-the-propagator-to-Y.patch \
    0113-ENHANCED-Queue-morphed-propagators-to-give-them-a-ch.patch \
    0117-ENHANCED-Omit-unnecessary-residual-constraints-in-di.patch \
    0118-shift-morphing-to-the-more-general-p-2-case.patch
sed -e 's/,Morph//g' \
    0125-ENHANCED-Suspend-propagation-during-filtering-in-sca.patch > patch
mv patch 0125-ENHANCED-Suspend-propagation-during-filtering-in-sca.patch
sed -e 's/,Morph//g' \
    -e 's/    morph_into_propagator(MState, \[Y,Z\], reified_eq(1,Y,1,0,\[\],Z), Morph)/;   X == 0 -> kill(MState), queue_goal((Z in 0..1, Y #>= 0, Z #<==> Y #= 0))/' \
    0131-Special-case-for-2.patch > patch
mv patch 0131-Special-case-for-2.patch
sed -e 's/,Morph//g' 0133-use-newly-available-false-0.patch > patch
mv patch 0133-use-newly-available-false-0.patch
# done
cd ..
git init clpz
cd clpz
git am $(ls /tmp/scryer/*.patch)
cd $home
