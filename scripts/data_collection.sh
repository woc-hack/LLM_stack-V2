#!/bin/bash

# region 1 - b2p

## full
zcat data/the-stack-v2-train.gz | 
sed "s|.*content_id': '||;s|', .*'repo_name': '|;|;s|', .*||" | 
sed 's|/|_|' |
~/lookup/splitSec.perl data/full/b2p. 128

## smol
zcat data/the-stack-v2-train-smol-ids.train.gz |
sed "s|.*repo_name': '||;s|'.*'files': |;|" |
perl -ane '
    ($p,@rest)=split(/;/);
    $r=join ";",@rest;
    print "$p";
    while ($r =~ m/.content_id.: .([0-9a-f]{40})./g) { 
        print ";".$1;
    }
    print "\n";
' |
awk -F\; '{
    OFS = ";" 
    for (i=2; i<=NF; i++) {
        print $i,$1
    }
}' |
sed 's|/|_|' |
~/lookup/splitSec.perl data/smol/b2p. 128

## sort
for i in {0..127}; do
    for b in {full,smol}; do
        zcat "data/$b/b2p.$i.gz" |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/b2p.$i"
    done
done
for b in {full,smol}; do
    rm data/$b/b2p.{0..127}.gz
done

# endregion 1

# region 2 - p2P

dir="/nfs/home/audris/work/gz"

## version V
zcat "$dir/p2PV.s" |
~/utils/sort.sh -t\; -u |
gzip >data/p2PV.s
# uniq p: 209,043,922 - uniq P: 131,171,380

## version V3
zcat "$dir/p2PFull.V3.s" |
~/utils/sort.sh -t\; -u |
gzip >data/p2PV3.s
# uniq p: 234,854,931 - uniq P: 155,838,776

# endregion 2

# region 3 - b2P
for i in {0..127}; do
    for b in {full,smol}; do
        LC_ALL=C LANG=C join -t\; -a1 -1 2 -o 1.1 1.2 2.2 \
            <(zcat "data/$b/b2p.$i" |
                ~/utils/sort.sh -t\; -k2,2) \
            <(zcat data/p2PV.s |
                ~/utils/sort.sh -t\; -k1,1) |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/b2pP.$i"

        zcat "data/$b/b2pP.$i" |
        awk -F\; '{
            OFS = ";"
            if ($3 == "") {
                print $1,$2
            } else {
                print $1,$3
            }
        }' |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/b2P.$i"
    done
done
for b in {full,smol}; do
    rm data/$b/b2p.{0..127}
done
