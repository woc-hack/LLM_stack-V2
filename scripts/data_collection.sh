#!/bin/bash

# region 1 - b2p

## full
zcat data/the-stack-v2-train.gz |  
sed "s|', 'snapshot_id.*||;s|.*content_id': '||;s|'.*license_type': '|;|;s|'.*repo_name': '|;|;s|/|_|" |
~/lookup/splitSec.perl data/full/b2lp. 128


## smol
zcat data/the-stack-v2-train-smol-ids.train.gz |
sed "s|.*repo_name': '||;s|'.*'files': |;|;s|/|_|" |
perl -ane '
    ($p,@rest)=split(/;/);
    $r=join ";",@rest;
    print "$p";
    while ($r =~ m/.content_id.: .([0-9a-f]{40}).*?license_type.: .([^'\'']+)./g) { 
        print ";".$1.";".$2;
    }
    print "\n";
' |
awk -F\; '{
    OFS = ";" 
    for (i=2; i<=NF; i+=2) {
        print $i, $(i+1), $1
    }
}' |
~/lookup/splitSec.perl data/smol/b2lp. 128

## sort
for i in {0..127}; do
    for b in {full,smol}; do
        zcat "data/$b/b2lp.$i.gz" |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/b2lp.$i"
    done
done
for b in {full,smol}; do
    rm data/$b/b2lp.{0..127}.gz
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
        LC_ALL=C LANG=C join -t\; -a1 -1 3 -o 1.1 1.2 1.3 2.2 \
            <(zcat "data/$b/b2lp.$i" |
                ~/utils/sort.sh -t\; -k3,3) \
            <(zcat data/p2PV.s |
                ~/utils/sort.sh -t\; -k1,1) |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/b2lpP.$i"

        zcat "data/$b/b2lpP.$i" |
        awk -F\; '{
            OFS = ";"
            if ($4 == "") {
                print $1,$2,$3
            } else {
                print $1,$2,$4
            }
        }' |
        ~/utils/sort.sh -t\; -u |
        gzip >"data/$b/b2lP.$i"
    done
done
for b in {full,smol}; do
    rm data/$b/b2lp.{0..127}
done

# endregion 3
