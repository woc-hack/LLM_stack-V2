#!/bin/bash

# full
zcat data/bugs/b2pFull.0.s |
cut -d\; -f1 |
~/utils/sort.sh -u |
gzip >data/bugs/b.full.s

zcat data/bugs/b2pobcfFull.0.s |
cut -d\; -f1,3,4 |
~/utils/sort.sh -u |
gzip >data/bugs/b2obc.full.s

zcat data/bugs/b2pbcfFull.0.s | 
cut -d\; -f1,3,4 |
~/utils/sort.sh -u |
gzip >data/bugs/b2nbc.full.s


# smol
zcat data/bugs/bSmall.0.gz |
~/utils/sort.sh -u |
gzip >data/bugs/b.smol.s

zcat data/bugs/b2obcf.0.s |
cut -d\; -f1-3 |
~/utils/sort.sh -u |
gzip >data/bugs/b2obc.smol.s

zcat data/bugs/b2bcf.0.s |
cut -d\; -f1-3 |
~/utils/sort.sh -u |
gzip >data/bugs/b2nbc.smol.s

# table 1
for batch in {full,smol}; do
    echo "Dataset: $batch"

    n1=$(zcat "data/bugs/b.$batch.s" | wc -l)
    echo "Total blobs: $n1"

    n2=$(zcat "data/bugs/b2obc.$batch.s" "data/bugs/b2nbc.$batch.s" |
        cut -d\; -f1 | ~/utils/sort.sh -u | wc -l)
    n3=$((n1 - n2))
    percent=$(echo "scale=4; ($n3/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Found blobs: $n2"
    echo "Missing blobs:  $n3 - $percent%"

    zcat "data/bugs/b2obc.$batch.s" | 
    awk -F\; '{if ($2!="") print $1}' | 
    uniq | gzip >"data/bugs/haveOld.$batch"
    join -v2 \
        <(zcat "data/bugs/haveOld.$batch") \
        <(zcat "data/bugs/b2obc.$batch.s" | cut -d\; -f1 | uniq) |
    gzip >"data/bugs/firstVer.$batch"
    n4=$(zcat "data/bugs/haveOld.$batch" | wc -l)
    percent=$(echo "scale=4; ($n4/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Have an old version: $n4 - $percent%"
    n5=$(zcat "data/bugs/firstVer.$batch" | wc -l )
    percent=$(echo "scale=4; ($n5/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "First version: $n5 - $percent%"
    n6=$(join -t\; <(zcat "data/bugs/firstVer.$batch") <(zcat "data/bugs/b2nbc.$batch.s") | 
        awk -F\; '{if ($2!="") print $1}' | uniq | wc -l )
    percent=$(echo "scale=4; ($n6/$n5*100)" | bc | awk '{printf "%.2f", $0}')
    echo "First versions with newer version: $n6 - $percent%"

    zcat "data/bugs/b2nbc.$batch.s" | 
    awk -F\; '{if ($2!="") print}' |
    uniq | gzip >"data/bugs/haveNew.$batch"
    n7=$(zcat "data/bugs/haveNew.$batch" | cut -d\; -f1 | uniq | wc -l)
    percent=$(echo "scale=4; ($n7/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Blobs with new version: $n7 - $percent%"
    n8=$(zcat "data/bugs/haveNew.$batch" | cut -d\; -f2 | ~/utils/sort.sh -u | wc -l)
    echo "Found new versions: $n8"
    echo
done
