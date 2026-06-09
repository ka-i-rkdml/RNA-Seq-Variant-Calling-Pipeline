#!/bin/bash

set -euo pipefail

REF="$HOME/reference/hg38.fa"
INPUT="sample.genotyped.vcf.gz"
OUTDIR="$HOME/results"

mkdir -p $OUTDIR

############################
# 1. Split SNP / Indel
############################
gatk SelectVariants \
    -R $REF \
    -V $INPUT \
    -select-type SNP \
    -O $OUTDIR/snps.vcf.gz

gatk SelectVariants \
    -R $REF \
    -V $INPUT \
    -select-type INDEL \
    -O $OUTDIR/indels.vcf.gz

############################
# 2. SNP filtering
############################
gatk VariantFiltration \
    -R $REF \
    -V $OUTDIR/snps.vcf.gz \
    -O $OUTDIR/snps.filtered.vcf.gz \
    --filter-name "QD2" --filter-expression "vc.getAttribute('QD') < 2.0" \
    --filter-name "FS30" --filter-expression "vc.getAttribute('FS') > 30.0" \
    --filter-name "MQ40" --filter-expression "vc.getAttribute('MQ') < 40.0"

############################
# 3. Indel filtering
############################
gatk VariantFiltration \
    -R $REF \
    -V $OUTDIR/indels.vcf.gz \
    -O $OUTDIR/indels.filtered.vcf.gz \
    --filter-name "QD2" --filter-expression "vc.getAttribute('QD') < 2.0" \
    --filter-name "FS200" --filter-expression "vc.getAttribute('FS') > 200.0"

############################
# 4. Merge
############################
gatk MergeVcfs \
    -I $OUTDIR/snps.filtered.vcf.gz \
    -I $OUTDIR/indels.filtered.vcf.gz \
    -O $OUTDIR/merged.filtered.vcf.gz

############################
# 5. Keep PASS + MLEAF filter
############################
bcftools view \
    -f PASS \
    -i 'INFO/MLEAF[0]>=0.05' \
    -Oz -o $OUTDIR/final.filtered.vcf.gz \
    $OUTDIR/merged.filtered.vcf.gz

bcftools index $OUTDIR/final.filtered.vcf.gz
