#!/usr/bin/env bash
# extracted feature IDs
grep '^>' /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/extracted_export/dna-sequences.fasta \
| sed 's/^>//' | cut -d' ' -f1 | sort -u \
> /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/extracted.ids

# taxonomy feature IDs
cut -f1 /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/tax_export/taxonomy.tsv \
| sort -u \
> /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.ids

# overlap count
comm -12 \
  /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/extracted.ids \
  /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.ids \
| head

comm -12 \
  /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/extracted.ids \
  /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.ids \
| wc -l
