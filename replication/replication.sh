#!/bin/bash

# blob sample

## full
zcat data/bugs/b2pFull.0.s |
cut -d\; -f1 |
~/utils/sort.sh -u |
gzip >data/bugs/b.full.gz

zcat data/bugs/b2pobcfFull.0.s |
cut -d\; -f1,3,4 |
~/utils/sort.sh -u |
gzip >data/bugs/b2obc.full.gz

zcat data/bugs/b2pbcfFull.0.s | 
cut -d\; -f1,3,4 |
~/utils/sort.sh -u |
gzip >data/bugs/b2nbc.full.gz


## smol
zcat data/bugs/bSmall.0.gz |
~/utils/sort.sh -u |
gzip >data/bugs/b.smol.gz

zcat data/bugs/b2obcf.0.s |
cut -d\; -f1-3 |
~/utils/sort.sh -u |
gzip >data/bugs/b2obc.smol.gz

zcat data/bugs/b2bcf.0.s |
cut -d\; -f1-3 |
~/utils/sort.sh -u |
gzip >data/bugs/b2nbc.smol.gz


# commit sample

## full
zcat data/bugs/c2obbf.0.s |
awk -F\; '{OFS=";"; if ($3!="") print $1,$2,$3}' |
~/utils/sort.sh -u |
gzip >data/bugs/c2bnb.full.gz

## smol
zcat data/bugs/c2obbfSmall.0.s |
awk -F\; '{OFS=";"; if ($3!="") print $1,$2,$3}' |
~/utils/sort.sh -u |
gzip >data/bugs/c2bnb.smol.gz

# smol cve complete
zcat data/bugs/b2ccveSmall |
~/utils/sort.sh -t\; -u |
join -t\; - <(zcat data/bugs/bSmallNext.s) |
gzip >data/bugs/b2ca.smol.gz
