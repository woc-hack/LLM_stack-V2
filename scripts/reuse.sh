#!/bin/bash

# bP2uPtdPt
for i in {0..127}; do
    for b in {full,smol}; do
        LC_ALL=C LANG=C join -t\; -2 3 \
            <(zcat "data/$b/b2P.$i") \
            <(zcat "../reuse-msr/data/Ptb2PtFullV$i.s") |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/bP2uPtdPt.$i"
    done
done

# origin diff
for i in {0..127}; do
    for b in {full,smol}; do
        zcat "data/$b/bP2uPtdPt.$i" |
        cut -d\; -f1-3 |
        uniq |
        cut -d\; -f2,3 |
        ~/utils/sort.sh -t\; |
        uniq -c |
        awk '{print $2";"$1}' |
        gzip >"data/$b/PuP2nb.$i"
    done
done
for b in {full,smol}; do
    ~/utils/sequential.sh "data/$b/PuP2nb" \
        '~/utils/sort.sh -t\; -m' \
        '~/utils/sum_count.sh' |
    gzip >"data/$b/PuP2nb.s"
    rm rm data/$b/PuP2nb.{0..127}
done
