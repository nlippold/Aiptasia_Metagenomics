#!/usr/bin/env bash
echo "Starting to extract v3 - v4 regions"
qiime feature-classifier extract-reads \
  --i-sequences /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/SILVA_138.2_SSURef_NR99_tax_silva_DNA.fasta.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GACTACHVGGGTATCTAATCC \
  --p-trunc-len 0 \
  --o-reads /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/silva-v3-v4_klindworth-seqs.qza
echo "DONE extracting V3 - V4 regions"
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/silva-v3-v4_klindworth-seqs.qza \
  --i-reference-taxonomy /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.expanded.dedup.tsv.qza \
  --o-classifier /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/silva-v3-v4_klindworth-classifier.qza
echo "DONE"
