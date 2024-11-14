#!/bin/bash

# blP2uPtdPt
for i in {0..127}; do
    for b in {full,smol}; do
        LC_ALL=C LANG=C join -t\; -2 3 \
            <(zcat "data/$b/b2lP.$i") \
            <(zcat "../reuse-msr/data/Ptb2PtFullV$i.s") |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/blP2uPtdPt.$i"
    done
done

# origin diff
for i in {0..127}; do
    for b in {full,smol}; do
        zcat "data/$b/blP2uPtdPt.$i" |
        cut -d\; -f1-4 |
        uniq |
        cut -d\; -f2-4 |
        ~/utils/sort.sh -t\; |
        uniq -c |
        awk '{print $2";"$1}' |
        gzip >"data/$b/lPuP2nb.$i"
    done
done
for b in {full,smol}; do
    ~/utils/sequential.sh "data/$b/lPuP2nb" \
        '~/utils/sort.sh -t\; -m' \
        '~/utils/sum_count.sh' |
    ~/utils/sort.sh -t\; |
    ~/utils/sum_count.sh |
    gzip >"data/$b/lPuP2nb.s"
    rm data/$b/lPuP2nb.{0..127}
    echo "$b"
    zcat "data/$b/lPuP2nb.s" | 
    cut -d\; -f2-4 |
    ~/utils/sort.sh -t\; |
    ~/utils/sum_count.sh |
    awk -F\; '
        {
            if ($1==$2) {
                s+=1
                ss+=$3
            } else {
                d+=1
                dd+=$3
            }
        } 
        END {
            print "projects - same: " s " diff: " d " total: " s+d
            print "blobs - same: " ss " diff: " dd " total: " ss+dd
        }'
done

# uniq projects
for i in {0..127}; do
    for b in {full,smol}; do 
        zcat "data/$b/b2P.$i" | 
        cut -d\; -f2 |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/P.$i"
    done
done
for b in {full,smol}; do 
    ~/utils/sort_merge.sh "data/$b/P" |
    gzip >"data/$b/P.s"
    rm "data/$b/P".{0..127}
    n=$(zcat "data/$b/P.s" | wc -l)
    echo "Project count: $n"
done

# different licenses
for b in {full,smol}; do
    zcat "data/$b/lPuP2nb.s" | 
    awk -F\; '{if ($2!=$3) print}' |
    ~/utils/sort.sh -t\; -k3,3 |
    LC_ALL=C LANG=C join -t\; -a1 -1 3 -o 1.2 1.1 1.4 1.3 2.2 \
        - \
        <(zcat ../lcs/data/P2TL-latest.s |
            sed 's|other$||;
                s|public-domain$|0_public|;
                s|permissive$|1_permissive|;
                s|conditional-open$|2_conditional|;
                s|weak-copyleft$|3_weak|
                s|copyleft$|4_copyleft|' |
            ~/utils/sort.sh -t\; |
            ~/utils/sort.sh -t\; -u -k1,1) |
    sed 's|;$|;no_license|' |
    ~/utils/sort.sh -t\; |
    gzip >"data/$b/Plnb2uPl.s"
done

# stat
for b in {full,smol}; do
    echo $b
    zcat "data/$b/Plnb2uPl.s" |
    sed 's|0_public$|permissive|;
        s|1_permissive$|permissive|;
        s|2_conditional$|restrictive|;
        s|3_weak$|restrictive|;
        s|4_copyleft$|restrictive|' |
    awk -F\; '{OFS=";"; print $2,$5,$3}' |
    ~/utils/sort.sh -t\; |
    ~/utils/sum_count.sh
    echo
done
