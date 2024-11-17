#!/bin/bash

# -------------------- blob sample --------------------
for batch in {full,smol}; do
    echo "Dataset: $batch"

    n1=$(zcat "b.$batch.gz" | wc -l)
    echo "Total blobs: $n1"

    n2=$(zcat "b2obc.$batch.gz" "b2nbc.$batch.gz" |
        cut -d\; -f1 | ~/utils/sort.sh -u | wc -l)
    n3=$((n1 - n2))
    percent=$(echo "scale=4; ($n3/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Found blobs: $n2"
    echo "Missing blobs:  $n3 - $percent%"

    zcat "b2obc.$batch.gz" | 
    awk -F\; '{if ($2!="") print $1}' | 
    uniq | gzip >"haveOld.$batch.gz"
    join -v2 \
        <(zcat "haveOld.$batch.gz") \
        <(zcat "b2obc.$batch.gz" | cut -d\; -f1 | uniq) |
    gzip >"firstVer.$batch.gz"
    n4=$(zcat "haveOld.$batch.gz" | wc -l)
    percent=$(echo "scale=4; ($n4/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Have an old version: $n4 - $percent%"
    n5=$(zcat "firstVer.$batch.gz" | wc -l )
    percent=$(echo "scale=4; ($n5/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "First version: $n5 - $percent%"
    n6=$(join -t\; <(zcat "firstVer.$batch.gz") <(zcat "b2nbc.$batch.gz") | 
        awk -F\; '{if ($2!="") print $1}' | uniq | wc -l )
    percent=$(echo "scale=4; ($n6/$n5*100)" | bc | awk '{printf "%.2f", $0}')
    echo "First versions with newer version: $n6 - $percent%"

    zcat "b2nbc.$batch.gz" | 
    awk -F\; '{if ($2!="") print}' |
    uniq | gzip >"haveNew.$batch.gz"
    n7=$(zcat "haveNew.$batch.gz" | cut -d\; -f1 | uniq | wc -l)
    percent=$(echo "scale=4; ($n7/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Blobs with new version: $n7 - $percent%"
    n8=$(zcat "haveNew.$batch.gz" | cut -d\; -f2 | ~/utils/sort.sh -u | wc -l)
    echo "Found new versions: $n8"
    echo
done

# -------------------- update commit sample --------------------
for batch in {full,smol}; do
    echo "Dataset: $batch"

    n1=$(zcat "c2bnb.$batch.gz" |
        cut -d\; -f1 | ~/utils/sort.sh -u | wc -l)
    n2=$(zcat "c2bnb.$batch.gz" |
        cut -d\; -f2 | ~/utils/sort.sh -u | wc -l)
    n3=$(zcat "c2bnb.$batch.gz" |
        cut -d\; -f3 | ~/utils/sort.sh -u | wc -l)
    echo "Total commit: $n1 - blob: $n2 - New version: $n3"

    join -t\; \
         <(zcat "c2bnb.$batch.gz") \
         <(zcat c2chFull.V3.0.s | cut -d\; -f1,11) |
    grep -iwE 'fix|fixes|fixing|bug|bugs|issue|issues|patch|patches|error|errors|resolve|resolved|resolving|correct|corrects|corrected|correcting|problem|problems|debug|debugs|debugged|debugging|cve' |
    gzip >"c2bnbm.$batch.fix.gz"

    zcat "c2bnbm.$batch.fix.gz" |
    cut -d\; -f1-3 |
    ~/utils/sort.sh -u |
    gzip >"c2bnb.$batch.fix.gz"

    n4=$(zcat "c2bnb.$batch.fix.gz" |
        cut -d\; -f1 | ~/utils/sort.sh -u | wc -l)
    percent=$(echo "scale=4; ($n4/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Fix commits: $n4 - $percent%"
    n5=$(zcat "c2bnb.$batch.fix.gz" |
        cut -d\; -f2 | ~/utils/sort.sh -u | wc -l)
    percent=$(echo "scale=4; ($n5/$n2*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Fix blobs: $n5 - $percent%"
    n6=$(zcat "c2bnb.$batch.fix.gz" |
        cut -d\; -f3 | ~/utils/sort.sh -u | wc -l)
    percent=$(echo "scale=4; ($n6/$n3*100)" | bc | awk '{printf "%.2f", $0}')
    echo "Fix new versions: $n6 - $percent%"

    zcat "c2bnbm.$batch.fix.gz" |
    grep -iw 'cve'  | 
    perl -ane '
        chop();
        ($c,$b,$nb,$a)=split(/;/,$_);
        $a=lc($a);
        while($a=~m|(cve\-[0-9]+\-[0-9]+)|g){
            print "$c;$b;$nb;$1\n";
        }'|
    uniq | gzip > "c2bnba.$batch.cve.gz"

    n7=$(zcat "c2bnba.$batch.cve.gz" |
        cut -d\; -f1 | ~/utils/sort.sh -u | wc -l)
    percent1=$(echo "scale=4; ($n7/$n1*100)" | bc | awk '{printf "%.2f", $0}')
    percent2=$(echo "scale=4; ($n7/$n4*100)" | bc | awk '{printf "%.2f", $0}')
    echo "CVE commits: $n7 - total: $percent1% - fixes: $percent2%"
    n8=$(zcat "c2bnba.$batch.cve.gz" |
        cut -d\; -f2 | ~/utils/sort.sh -u | wc -l)
    percent1=$(echo "scale=4; ($n8/$n2*100)" | bc | awk '{printf "%.2f", $0}')
    percent2=$(echo "scale=4; ($n8/$n5*100)" | bc | awk '{printf "%.2f", $0}')
    echo "CVE blobs: $n8 - total: $percent1% - fixes: $percent2%"
    n9=$(zcat "c2bnba.$batch.cve.gz" |
        cut -d\; -f3 | ~/utils/sort.sh -u | wc -l)
    percent1=$(echo "scale=4; ($n9/$n3*100)" | bc | awk '{printf "%.2f", $0}')
    percent2=$(echo "scale=4; ($n9/$n6*100)" | bc | awk '{printf "%.2f", $0}')
    echo "CVE new versions: $n9 - total: $percent1% - fixes: $percent2%"
    n10=$(zcat "c2bnba.$batch.cve.gz" |
        cut -d\; -f4 | ~/utils/sort.sh -u | wc -l)
    echo "Distinct CVEs: $n10"
    echo
done

# -------------------- CVEs in smol dataset --------------------
n1=$(zcat b2ca.smol.gz | cut -d\; -f1 | ~/utils/sort.sh -u | wc -l)
n2=$(zcat b2ca.smol.gz | cut -d\; -f2 | ~/utils/sort.sh -u | wc -l)
n3=$(zcat b2ca.smol.gz | cut -d\; -f3 | ~/utils/sort.sh -u | wc -l)
echo "blobs: $n1 - commits: $n2 - CVEs: $n3"
