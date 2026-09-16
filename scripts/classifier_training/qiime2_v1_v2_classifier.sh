#!/usr/bin/env bash
qiime tools import \
  --type "FeatureData[Sequence]" \
  --input-path /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/SILVA_138.2_SSURef_NR99_tax_silva_DNA.fasta \
  --output-path /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/SILVA_138.2_SSURef_NR99_tax_silva_DNA.fasta.qza
echo "DONE Importing Sequences"
qiime tools import \
  --type "FeatureData[Taxonomy]" \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.expanded.dedup.tsv \
  --output-path /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.expanded.dedup.tsv.qza
echo "DONE Importing Taxonomy"
qiime feature-classifier extract-reads \
  --i-sequences /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/SILVA_138.2_SSURef_NR99_tax_silva_DNA.fasta.qza \
  --p-f-primer TAGAGTTTGATCCTGGCTCAG \
  --p-r-primer TGCTGCCTCCCGTAGGAGT \
  --p-trunc-len 0 \
  --o-reads /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/silva-v1-v2-seqs.qza
echo "DONE extracting V1 - V2 regions"
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/silva-v1-v2-seqs.qza \
  --i-reference-taxonomy /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.expanded.dedup.tsv.qza \
  --o-classifier /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/silva-v1-v2-classifier.qza
echo "DONE"