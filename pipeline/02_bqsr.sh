#!/bin/bash

set -euo pipefail

REF="$HOME/reference/hg38.fa"
INPUT="sample.split.sorted.bam"
KNOWN_SITES="$HOME/reference/dbsnp.vcf.gz"

############################
# 1. BaseRecalibrator
############################
gatk --java-options "-Xmx10g -XX:ParallelGCThreads=6" \
BaseRecalibrator \
    -I $INPUT \
    -R $REF \
    --known-sites $KNOWN_SITES \
    -O recal_data.table

############################
# 2. Apply BQSR
############################
gatk --java-options "-Xmx8g -XX:ParallelGCThreads=6" \
ApplyBQSR \
    -R $REF \
    -I $INPUT \
    --bqsr-recal-file recal_data.table \
    -O sample.BQSR.bam

samtools index sample.BQSR.bam
