#!/usr/bin/env bash
echo "[+] Starting taxonomic classification"
qiime feature-classifier classify-sklearn \
  --i-classifier /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/silva-v5-v6-classifier.qza \
  --i-reads /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs.qza \
  --o-classification /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs_taxonomy.qza
echo "[+] DONE with classification"
qiime metadata tabulate \
  --m-input-file /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs_taxonomy.qza \
  --o-visualization /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs_taxonomy.qzv
echo "[+] DONE"
