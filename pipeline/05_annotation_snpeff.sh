#!/bin/bash

set -euo pipefail

INPUT="results/final.filtered.vcf.gz"
OUT="results/final.ann.vcf"

SNPEFF_DIR="$HOME/snpEff"

cd $SNPEFF_DIR

############################
# Annotation
############################
java -Xmx10g -jar snpEff.jar \
    -v GRCh38.113 \
    -canon \
    -lof \
    $INPUT > $OUT

############################
# Summary
############################
echo "Annotation finished"
echo "Output: $OUT"
