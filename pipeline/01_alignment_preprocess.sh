#!/bin/bash

set -euo pipefail

############################
# Input / Output
############################
INPUT_BAM="$HOME/input.bam"
WORKDIR="$HOME/work"
REF="$HOME/reference/hg38.fa"

mkdir -p $WORKDIR
cd $WORKDIR

############################
# 1. Sort BAM
############################
samtools sort \
    -@ 4 \
    -m 2G \
    --write-index \
    -o sample.sorted.bam \
    $INPUT_BAM

############################
# 2. Add Read Group
############################
gatk AddOrReplaceReadGroups \
    -I sample.sorted.bam \
    -O sample.rg.bam \
    -RGID sample \
    -RGLB lib1 \
    -RGPL ILLUMINA \
    -RGPU unit1 \
    -RGSM sample

samtools index sample.rg.bam

############################
# 3. MarkDuplicates
############################
gatk MarkDuplicates \
    --java-options "-Xmx8g -XX:ParallelGCThreads=4" \
    -I sample.rg.bam \
    -O sample.dedup.bam \
    -M sample.metrics.txt

samtools index sample.dedup.bam

############################
# 4. SplitNCigarReads (RNA-seq)
############################
gatk SplitNCigarReads \
    --java-options "-Xmx6g -XX:ParallelGCThreads=3" \
    -R $REF \
    -I sample.dedup.bam \
    -O sample.split.bam

samtools sort -@ 4 -m 2G \
    -o sample.split.sorted.bam \
    sample.split.bam

samtools index sample.split.sorted.bam


