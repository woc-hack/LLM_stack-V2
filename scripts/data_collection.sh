#!/bin/bash

zcat data/the-stack-v2-train.gz | 
sed 's|,.*||' | 
awk -F\' '{print $4}' | 
~/lookup/splitSec.perl data/split/blobs. 128
