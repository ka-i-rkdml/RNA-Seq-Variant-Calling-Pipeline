#!/bin/bash

set -euo pipefail

REF="$HOME/reference/hg38.fa"
INPUT="sample.BQSR.bam"

############################
# 1. HaplotypeCaller
############################
gatk --java-options "-Xmx10g -XX:ParallelGCThreads=8" \
HaplotypeCaller \
    -R $REF \
    -I $INPUT \
    -O sample.raw.vcf.gz \
    -ERC GVCF \
    --dont-use-soft-clipped-bases true \
    --standard-min-confidence-threshold-for-calling 20 \
    --min-base-quality-score 20 \
    -native-pair-hmm-threads 8

############################
# 2. GenotypeGVCFs
############################
gatk --java-options "-Xmx8g -XX:ParallelGCThreads=6" \
GenotypeGVCFs \
    -R $REF \
    -V sample.raw.vcf.gz \
    -O sample.genotyped.vcf.gz
