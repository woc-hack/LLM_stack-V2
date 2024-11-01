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

# b2P
zcat data/the-stack-v2-train.gz | 
sed 's|snapshot_id.*||;s|directory_id.*repo_name||' | 
awk -F\' '{OFS=";";print $4,$8}' | 
sed 's|/|_|' |
~/lookup/splitSec.perl data/split/b2p. 128
