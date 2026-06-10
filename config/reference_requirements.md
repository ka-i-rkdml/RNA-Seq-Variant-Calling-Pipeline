## Required files
hg38.fa  
hg38.fa.fai  
hg38.dict  

00-All.chr.vcf.gz  
00-All.chr.vcf.gz.tbi  

## How to generate
```bash
samtools faidx hg38.fa

gatk CreateSequenceDictionary \
    -R hg38.fa \
    -O hg38.dict
```

## Notes
Reference genome, dbSNP and snpEff databases are not distributed with this repository because of file size limitations.
