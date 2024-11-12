#!/bin/bash

# functions
merge_split() {
    path="$1"

    ~/utils/sort_merge.sh "$path" |
    gzip >"$path.s"
    rm "$path".{0..127}
    
    zcat "$path.s" |
    ~/lookup/splitSec.perl "$path." 128
    rm "$path.s"
}

ob2b() {
    dir="/nfs/home/audris/work/c2fb"
    path="$1"
    n="$2"
    i="$3"

    LC_ALL=C LANG=C join -t\; \
        <(zcat "$path/nb$n.$i") \
        <(zcat "$dir/ob2bFullV$i.s") |
    ~/utils/sort.sh -t\; -u |
    gzip >"$path/ob${n}2b.$i"

    zcat "$path/ob${n}2b.$i" |
    cut -d\; -f2 |
    ~/utils/sort.sh -t\; -u |
    gzip >"$path/nb$((n+1)).$i"
}

remove-dup() {
    path="$1"
    n1="$2"
    n2="$3"
    i="$4"

    LC_ALL=C LANG=C join -t\; \
        <(zcat "$path/nb$n1.$i") \
        <(zcat "$path/nb$n2.$i") |
    gzip >"$path/b$n2-b$n1.$i"

    LC_ALL=C LANG=C join -t\; -v1 \
        <(zcat "$path/nb$n2.$i") \
        <(zcat "$path/b$n2-b$n1.$i") |
    gzip >"$path/nb$n2.$i-2"
    mv "$path/nb$n2.$i-2" "$path/nb$n2.$i"
}

# distance == 1
for i in {0..127}; do
    for b in {full,smol}; do
        zcat "data/$b/b2P.$i" | 
        cut -d\; -f1 |
        gzip >"data/$b/nb0.$i"
    done
done  
for i in {0..127}; do
    for b in {full,smol}; do
        ob2b "data/$b" 0 "$i"
    done
done
for b in {full,smol}; do
    merge_split "data/$b/nb1" 
done
# intersection and duplicate removal
for i in {0..127}; do
    for b in {full,smol}; do
        remove-dup "data/$b" 0 1 "$i"
    done
done
 
# distance == 2
for i in {0..127}; do
    for b in {full,smol}; do
        ob2b "data/$b" 1 $i
    done
done
for b in {full,smol}; do
    merge_split "data/$b/nb2"
done
# intersection and duplicate removal
for i in {0..127}; do
    for b in {full,smol}; do
        remove-dup "data/$b" 0 2 "$i"
        remove-dup "data/$b" 1 2 "$i"
    done
done

# distance == 3
for i in {0..127}; do
    for b in {full,smol}; do
        ob2b "data/$b" 2 $i
    done
done
for b in {full,smol}; do
    merge_split "data/$b/nb3"
done
# intersection and duplicate removal
for i in {0..127}; do
    for b in {full,smol}; do
        remove-dup "data/$b" 0 3 "$i"
        remove-dup "data/$b" 1 3 "$i"
        remove-dup "data/$b" 2 3 "$i"
    done
done
