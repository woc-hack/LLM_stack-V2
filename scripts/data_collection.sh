#!/bin/bash

# unique blobs
zcat data/the-stack-v2-train.gz | 
sed 's|,.*||' | 
awk -F\' '{print $4}' | 
~/lookup/splitSec.perl data/split/blobs. 128
for i in {0..127}; do
    zcat "data/split/blobs.$i.gz" |
    ~/utils/sort.sh -t\; -u |
    gzip >"data/split/blobs.$i"
done
rm data/split/blobs.{0..127}.gz

# b2p
zcat data/the-stack-v2-train.gz | 
sed 's|snapshot_id.*||;s|directory_id.*repo_name||' | 
awk -F\' '{OFS=";";print $4,$8}' | 
sed 's|/|_|' |
~/lookup/splitSec.perl data/split/b2p. 128
for i in {0..127}; do
    zcat "data/split/b2p.$i.gz" |
    ~/utils/sort.sh -t\; -u |
    gzip >"data/split/b2p.$i"

    zcat "data/split/b2p.$i.gz" |
    cut -d\; -f2 |
    ~/utils/sort.sh -t\; -u |
    gzip >"data/split/p.$i"
done

# p2P
dir="/nfs/home/audris/work/gz"

zcat "$dir/p2PV.s" |
~/utils/sort.sh -t\; -u |
gzip >data/p2PV.s

zcat "$dir/p2PFull.V3.s" |
~/utils/sort.sh -t\; -u |
gzip >data/p2PV3.s
