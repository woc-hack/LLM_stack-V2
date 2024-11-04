#!/bin/bash

# b2p - content_id coressponds to git blob_id
zcat data/the-stack-v2-train.gz | 
sed "s|, 'snapshot_id.*||;s|.*content_id': ||;s|, 'detected_licenses.*repo_name': ||" | 
awk -F\' '{OFS=";";print $2,$4}' | 
sed 's|/|_|' |
~/lookup/splitSec.perl data/split/b2p. 128

for i in {0..127}; do
    zcat "data/split/b2p.$i.gz" |
    ~/utils/sort.sh -t\; -u |
    gzip >"data/split/b2p.$i"
done
rm data/split/b2p.{0..127}.gz

# p2P
dir="/nfs/home/audris/work/gz"

zcat "$dir/p2PV.s" |
~/utils/sort.sh -t\; -u |
gzip >data/p2PV.s
# uniq p: 209,043,922 - uniq P: 131,171,380

zcat "$dir/p2PFull.V3.s" |
~/utils/sort.sh -t\; -u |
gzip >data/p2PV3.s
# uniq p: 234,854,931 - uniq P: 155,838,776

# b2P
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -a1 -1 2 -o 1.1 1.2 2.2 \
        <(zcat "data/split/b2p.$i" |
            ~/utils/sort.sh -t\; -k2,2) \
        <(zcat data/p2PV.s |
            ~/utils/sort.sh -t\; -k1,1) |
    ~/utils/sort.sh -t\; -u |
    gzip >"data/split/b2pP.$i"

    zcat "data/split/b2pP.$i" |
    awk -F\; '{
        OFS = ";"
        if ($3 == "") {
            print $1,$2
        } else {
            print $1,$3
        }
    }' |
    ~/utils/sort.sh -t\; -u |
    gzip >"data/split/b2P.$i"
done
rm data/split/b2p.{0..127}
