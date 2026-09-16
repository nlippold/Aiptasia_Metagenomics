#!/usr/bin/env bash
echo "[+] Excluding Mitochondria, Chloroplasts"
# example: remove mitochondria/chloroplast
qiime taxa filter-table \
  --i-table /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_table.qza \
  --i-taxonomy /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs_taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-table /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/table_no_organelle.qza
qiime taxa filter-seqs \
  --i-sequences /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs.qza \
  --i-taxonomy /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs_taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-sequences /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/rep_seqs_no_organelle.qza
echo "[+] DONE"
