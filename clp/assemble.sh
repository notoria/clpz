#!/bin/sh

cat header.pl > clpz.pl
echo >> clpz.pl
echo 'monotonic.' >> clpz.pl
echo >> clpz.pl
for file in compatibility operators introduction duodcg; do
    cat $file.pl >> clpz.pl
    echo >> clpz.pl
done

for file in \
attr \
cis \
domain \
'in' \
labeling \
contracting \
fds_sespsize \
optimise \
difference \
scalar_product \
parse_clpz \
leg \
clpz_expansion \
linsum \
integer_tools \
lng \
reifiable \
parse_reified_clpz \
reify0 \
reify_tuples_in \
reify1 \
skeleton \
drep \
fd \
reinforce \
propagator0 \
variants \
kill \
queue \
propagator1 \
lex_chain \
tuples_in \
run_propagator \
unused \
internal_tools \
serialized \
element \
global_cardinality \
circuit \
cumulative \
disjoint2 \
automaton \
zcompare \
chain \
reflection \
entailment \
uhcp \
psp \
reified \
generated; do
    echo >> clpz.pl
    echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' >> clpz.pl
    echo >> clpz.pl
    cat $file.pl >> clpz.pl
done
