#!/usr/bin/env bash
echo "[+] Starting to clean samples"
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/demux-paired-end.qza \
  --p-trunc-len-f 210 \
  --p-trunc-len-r 180 \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-n-threads 8 \
  --o-table /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/dada2_table.qza \
  --o-representative-sequences /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/dada2_rep_seqs.qza \
  --o-denoising-stats /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/dada2_stats.qza
echo "[+] DONE denoising with dada2"
echo "[+] Starting taxonomic classification"
qiime feature-classifier classify-sklearn \
  --i-classifier /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/silva-v5-v6-classifier.qza \
  --i-reads /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/dada2_rep_seqs.qza \
  --o-classification /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/dada2_rep_seqs_taxonomy.qza
echo "[+] DONE with classification"
qiime metadata tabulate \
  --m-input-file /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/dada2_rep_seqs_taxonomy.qza \
  --o-visualization /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/dada2_rep_seqs_taxonomy.qzv
echo "[+] DONE"
