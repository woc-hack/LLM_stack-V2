```
>cat grab_train.py
from datasets import load_dataset

ds = load_dataset("bigcode/the-stack-v2-train-smol-ids", split='train', streaming=True)

for row in ds:
  print(row)


>cat grab_train_full.py
from datasets import load_dataset

ds = load_dataset("bigcode/the-stack-v2", streaming=True, split="train")

for row in ds:
  print(row)
```
python3 grab_train.py | gzip > the-stack-v2-train-smol-ids.train.gz
zcat the-stack-v2-train-smol-ids.train.gz| sed "s|.*repo_name': '||;s|'.*'revision_id': '|;|;s|', |;|"|perl -ane '($p,$c,@rest)=split(/;/);$r=join ";",@rest; print "$p;$c"; while ($r =~ m/.content_id.: .([0-9a-f]{40})./g){ print ";".$1; };print "\n";'|gzip > p2cb
zcat p2cb | awk -F\; '{print $2";"$1}' | ~/lookup/splitSec.perl c2p. 128
for i in {0..127}; do zcat c2p.$i.gz | lsort 50G -t\; -k1,1 | gzip > c2p.$i.s; done 
for i in {0..127}; do zcat c2p.$i.s | join -t\; -v1 - <(zcat /da?_data/basemaps/gz/c2pFullV$i.s); done | gzip > missingC
zcat missingC|cut -d\; -f2 |lsort 10G -u | gzip > missingP
zcat p2cb | cut -d\; -f3- | perl -ane 's|;|\n|g;print' | lsort 100G | ~/lookup/splitSec.perl bSmall. 128
zcat bSmall.*.gz | wc -l
87175702
for i in {0..127..4}; do zcat bSmall.$i.gz | join -t\; - <(zcat /da7_data/basemaps/gz/obb2cfFull.V3.$i.s) | gzip > b2bcf.$i.s; done &
for i in {1..127..4}; do zcat bSmall.$i.gz | join -t\; - <(zcat /da7_data/basemaps/gz/obb2cfFull.V3.$i.s) | gzip > b2bcf.$i.s; done &
for i in {2..127..4}; do zcat bSmall.$i.gz | join -t\; - <(zcat /da7_data/basemaps/gz/obb2cfFull.V3.$i.s) | gzip > b2bcf.$i.s; done &
for i in {3..127..4}; do zcat bSmall.$i.gz | join -t\; - <(zcat /da7_data/basemaps/gz/obb2cfFull.V3.$i.s) | gzip > b2bcf.$i.s; done &
wait
for i in {0..127}; do zcat b2bcf.$i.s| cut -d\; -f1,2,3,4 | awk -F\; '{print $3";"$1";"$2";"$4 }'|uniq; done | ~/lookup/splitSec.perl c2obbfSmall. 128
for i in {0..127..4}; do zcat c2obbfSmall.$i.gz | lsort 100G -t\; -k1,1 | gzip > c2obbfSmall.$i.s; done &
for i in {1..127..4}; do zcat c2obbfSmall.$i.gz | lsort 100G -t\; -k1,1 | gzip > c2obbfSmall.$i.s; done &
for i in {2..127..4}; do zcat c2obbfSmall.$i.gz | lsort 100G -t\; -k1,1 | gzip > c2obbfSmall.$i.s; done &
for i in {3..127..4}; do zcat c2obbfSmall.$i.gz | lsort 100G -t\; -k1,1 | gzip > c2obbfSmall.$i.s; done &
wait
for i in {0..127..4}; do zcat c2obbfSmall.$i.s | join -t\; - <(zcat /da7_data/basemaps/gz/c2chFull.V3.$i.s) | gzip > c2obbfchSmall.$i.s; done

for i in {1..127..4}; do
zcat c2obbfchSmall.$i.s | cut -d\; -f1,2,14 | uniq |  grep -iE 'correct|fix|bug|error|problem|issue|cve' | gzip > c2obbfchSmall.$i.fix
zcat c2obbfchSmall.$i.fix|  grep -iE 'correct|fix|bug|error|problem|issue' | cut -d\; -f2 | uniq | lsort 2G -u | gzip > c2obbfchSmall.$i.fix.b 
zcat c2obbfchSmall.$i.fix |  grep -iw 'cve'  | cut -d\; -f2 | uniq | lsort 10G -u | gzip > c2obbfchSmall.$i.cve.b 
done &

for i in {0..127}; do zcat c2obbfchSmall.$i.cve.b; done | lsort 1G -u| join - <(zcat bSmall.s|cut -d\; -f1 | uniq)|wc -l
25334
for i in {0..127}; do zcat c2obbfchSmall.$i.fix| grep -iw 'cve'


#validation
i=1
zcat  c2obbfchSmall.$i.fix|  grep -iE 'correct|fix|bug|error|problem|issue' | cut -d\; -f1,3| uniq | head -20
#3 out of 20 may not be an actual fix
zcat c2obbfchSmall.*.fix |  grep -iw 'cve'  | perl -ane 'chop();($c,$b,$a)=split(/;/,$_);$a=lc($a); while($a=~m|(cve\-[0-9]+\-[0-9]+)|g){print "$b;$c;$1\n";}'|uniq |gzip > b2ccveSmall
for i in {0..127}; do zcat b2bcf.$i.s | cut -d\; -f1,2 | grep  -v ';$' |cut -d\; -f1 | uniq; done | lsort 10G -u | gzip > bSmallNext.s 

#check time
zcat  c2obbfchSmall.0.s | cut -d\; -f2,10| uniq | lsort 1G -t\; -k1 | join -t\; - <(zcat bSmallNext.s) |awk -F\; '{ y=$2/3600/24/365.25+1970; print y}' > tt
lsort 1G tt | head -$((1087458/2)) | tail -1
2020.52

#count distinct CVEs
zcat b2ccveSmall| lsort 1G -t\; -k1 | join -t\; - <(zcat bSmallNext.s) | cut -d\; -f3 | uniq | lsort 1G -u | wc
6947
#count distinct blobs in cve fixes 
zcat b2ccveSmall| lsort 1G -t\; -k1 | join -t\; - <(zcat bSmallNext.s) | cut -d\; -f1 | uniq | lsort 1G -u | wc
19944
#count distinct  cve fixes 
zcat b2ccveSmall| lsort 1G -t\; -k1 | join -t\; - <(zcat bSmallNext.s) | cut -d\; -f2 | uniq | lsort 1G -u | wc
11907

#count blobs in fix commits
for i in {0..127}; do  zcat c2obbfchSmall.$i.fix.b; done | lsort 10G -u |join - <(zcat bSmallNext.s) | wc -l
2,506,516

#count cve-fix affected blobs



#zcat c2obbfchSmall.$i.s | cut -d\; -f1,2,14 | uniq |  grep -iw 'cve' | gzip > c2obbfchSmall.$i.cve
zcat c2obbfchSmall.0.s| cut -d\; -f2 | uniq | lsort 10G -u | gzip > c2obbfchSmall.0.s.b




zcat c2obbfchSmall.0.s.b| join - <(zcat bSmall.s|cut -d\; -f1 | uniq) | wc -l
591896
zcat c2obbfchSmall.0.fix.b| join - <(zcat bSmall.s|cut -d\; -f1 | uniq) | wc -l
84296
zcat c2obbfchSmall.0.cve.b| join - <(zcat bSmall.s|cut -d\; -f1 | uniq) | wc -l
971

(zcat b2bcf.0.s|cut -d\; -f1 | uniq; zcat b2obcf.0.s|cut -d\; -f1 | uniq) | lsort 50G -u | wc
 664384
zcat bSmall.0.gz | uniq | wc -l
 680917
zcat b2bcf.0.s|cut -d\; -f1 | uniq|wc -l
127084
zcat b2obcf.0.s|cut -d\; -f1 | uniq|wc -l
664131

zcat b2obcf.0.s| cut -d\; -f1,2 | grep  ';$' |cut -d\; -f1 | uniq|wc -l
440728
zcat b2bcf.0.s| cut -d\; -f1,2 | grep  -v ';$' |cut -d\; -f1 | uniq|wc -l
69346
zcat b2obcf.0.s| cut -d\; -f1,2 | grep  ';$' |cut -d\; -f1 | uniq| join -v1 - <(zcat b2bcf.0.s| cut -d\; -f1|uniq) | wc -l
399759/664384


python3 grab_train_full.py | gzip > the-stack-v2-train.gz
zcat the-stack-v2-train.gz | sed "s|.*repo_name': '||;s|'.*'revision_id': '|;|;s|', |;|"|perl -ane '($p,$c,@rest)=split(/;/);$r=join ";",@rest; print "$p;$c"; while ($r =~ m/.content_id.: .([0-9a-f]{40})./g){ print ";".$1; };print "\n";'|gzip > p2cbFull
zcat p2cbFull | awk -F\; '{print $2";"$1}' | ~/lookup/splitSec.perl c2pFull. 128
for i in {0..127}; do zcat c2pFull.$i.gz | lsort 50G -t\; -k1,1 | gzip > c2pFull.$i.s; done
for i in {0..127}; do zcat c2pFull.$i.s | join -t\; -v1 - <(zcat /da?_data/basemaps/gz/c2pFullV$i.s); done | gzip > missingCFull
zcat missingCFull|cut -d\; -f2 |lsort 10G -u | gzip > missingPFull


zcat the-stack-v2-train.gz | sed "s|.*content_id': '||;s|', .*'repo_name': '|;|;s|', .*||"| ~/lookup/splitSec.perl b2pFull. 128
for i in {0..127..4}; do zcat b2pFull.$i.gz | lsort 100G -t\; -k1,1 | gzip > b2pFull.$i.s; done &
for i in {1..127..4}; do zcat b2pFull.$i.gz | lsort 100G -t\; -k1,1 | gzip > b2pFull.$i.s; done &
for i in {2..127..4}; do zcat b2pFull.$i.gz | lsort 100G -t\; -k1,1 | gzip > b2pFull.$i.s; done &
for i in {3..127..4}; do zcat b2pFull.$i.gz | lsort 100G -t\; -k1,1 | gzip > b2pFull.$i.s; done &
wait
zcat b2pFull.*.s | cut -d\; -f1 | uniq | wc -l


for i in {0..127..4}; do zcat b2pFull.$i.s | join -t\; - <(zcat /da7_data/basemaps/gz/obb2cfFull.V3.$i.s) | gzip > b2pbcfFull.$i.s; done &
for i in {1..127..4}; do zcat b2pFull.$i.s | join -t\; - <(zcat /da7_data/basemaps/gz/obb2cfFull.V3.$i.s) | gzip > b2pbcfFull.$i.s; done &
for i in {2..127..4}; do zcat b2pFull.$i.s | join -t\; - <(zcat /da7_data/basemaps/gz/obb2cfFull.V3.$i.s) | gzip > b2pbcfFull.$i.s; done &
for i in {3..127..4}; do zcat b2pFull.$i.s | join -t\; - <(zcat /da7_data/basemaps/gz/obb2cfFull.V3.$i.s) | gzip > b2pbcfFull.$i.s; done &
wait
for i in {0..127}; do zcat b2pbcfFull.$i.s| cut -d\; -f1,3,4,5 | awk -F\; '{print $3";"$1";"$2";"$4 }'|uniq; done | ~/lookup/splitSec.perl c2obbf. 128 
for i in {0..127}; do zcat c2obbf.$i.gz | lsort 100G -t\; -k1,1 | gzip > c2obbf.$i.s; done &
for i in {0..127}; do zcat c2obbf.$i.s | join -t\; - <(zcat /da7_data/basemaps/gz/c2chFull.V3.$i.s) | gzip > c2obbfch.$i.s; done

####
str="lsort 100G --merge -u"
for i in {0..127}; do str="$str <(zcat b2pFull.$i.s|cut -d\; -f1|uniq)";done
eval $str | gzip > bFull.s &

for i in {1..127..4}; do
zcat c2obbfch.$i.s | cut -d\; -f1,2,14 | uniq |  grep -iE 'correct|fix|bug|error|problem|issue|cve' | gzip > c2obbfch.$i.fix
zcat c2obbfch.$i.fix | grep -iw 'cve' | cut -d\; -f2 | uniq | lsort 10G -u | gzip > c2obbfch.$i.cve.b
zcat c2obbfch.$i.fix| cut -d\; -f2 | uniq | lsort 5G -u | gzip > c2obbfch.$i.fix.b 
done &

zcat c2obbfch.$i.s| cut -d\; -f2 | uniq | lsort 10G -u | gzip > c2obbfch.$i.s.b

zcat c2obbfch.0.s.b| join - <(zcat bFull.s|cut -d\; -f1 | uniq) | wc -l
8540567
zcat c2obbfch.0.fix.b| join - <(zcat bFull.s|cut -d\; -f1 | uniq) | wc -l
2193397
zcat c2obbfch.0.cve.b| join - <(zcat bFull.s|cut -d\; -f1 | uniq) | wc -l
30165


zcat c2obbfch.0.s | grep -iv merge | cut -d\; -f1,2,14 | uniq |  grep -iE 'correct|fix|bug|error|problem|issue' |wc -l
#1170792 no correct|problem
zcat c2obbfch.0.s | grep -iv merge | cut -d\; -f1,2,14 | uniq |wc
14069214 180884350 4903096616
zcat c2obbfch.0.s | perl -ane 'chop();($c,$ob,$b,$f,$p,@x)=split(/;/);$cmt=$x[$#x];$cmt =~ s/__NEWLINE__/\n/g;print "$c;$ob\n" if lc($cmt) =~ m/correct|fix|error|bug|problem|issue/;' | uniq | wc -l
#2032551 - no error|issue
zcat c2obbfch.0.s | perl -ane 'chop();($c,$ob,$b,$f,$p,@x)=split(/;/);$cmt=$x[$#x];$cmt =~ s/__NEWLINE__/\n/g;print "$c;$ob\n";' | uniq | wc -l
#22293691

zcat b2pFull.0.s | cut -d\; -f1 | uniq | wc -l
4553119
zcat b2pbcfFull.0.s | cut -d\; -f1 | uniq | wc -l
1220671

(i=0;zcat b2pFull.$i.s | join -t\; - <(zcat /da7_data/basemaps/gz/bb2cfFull.V3.$i.s) | gzip > b2pobcfFull.$i.s)
zcat b2pobcfFull.0.s|cut -d\; -f1 | uniq | wc -l
#4435812 looks like most have been created and unchanged
zcat b2pobcfFull.0.s|cut -d\; -f1,3| grep -v ';$' | cut -d\; -f1 | uniq | wc -l
#1622641 - indeed, no attempt to get the latest version it seems :-)
zcat b2pobcfFull.0.s|cut -d\; -f1,3| grep ';$' | cut -d\; -f1 | uniq | wc -l
3295654

(i=0; zcat b2pFull.$i.s | join -t\; - <(zcat /da7_data/basemaps/gz/b2PFull.V3.$i.s) | gzip > b2PFull.$i.s )
zcat b2PFull.0.s| cut -d\; -f1 | uniq | wc -l
4435568 # almost all

da5:/data/play/stack2>ls -l the-stack-v2-train-smol-ids.train.gz
-rw-rw-r--. 1 audris audris 11002497736 Feb 29  2024 the-stack-v2-train-smol-ids.train.gz
da5:/data/play/stack2>ls -l the-stack-v2-train-smol-ids.train.gz p2cb
-rw-rw-r--. 1 audris audris  2483730370 Mar  1  2024 p2cb
-rw-rw-r--. 1 audris audris 11002497736 Feb 29  2024 the-stack-v2-train-smol-ids.train.gz
da5:/data/play/stack2>ls -ltr the-stack-v2-train-smol-ids.train.gz p2cb
-rw-rw-r--. 1 audris audris 11002497736 Feb 29  2024 the-stack-v2-train-smol-ids.train.gz
-rw-rw-r--. 1 audris audris  2483730370 Mar  1  2024 p2cb


zcat b2pFull.0.s|cut -d\; -f1 | uniq | wc
4553119
zcat b2pbcfFull.0.s|cut -d\; -f1 | uniq | wc                                                                                                                                                                                                                                    
1220671 1220671 50047511
zcat b2pobcfFull.0.s|cut -d\; -f1 | uniq | wc
4435812
(zcat b2pobcfFull.0.s|cut -d\; -f1 | uniq; zcat b2pbcfFull.0.s|cut -d\; -f1 | uniq) | lsort 100G -u | wc
4437880
zcat b2pobcfFull.0.s|cut -d\; -f1,3| grep ';$' | cut -d\; -f1 | uniq | join -v1 - <(zcat b2pbcfFull.0.s|cut -d\; -f1,2 | uniq) | wc -l
2445721/4437880
