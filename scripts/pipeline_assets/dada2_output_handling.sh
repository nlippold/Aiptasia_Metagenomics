#!/usr/bin/env bash
echo "[+] Creating Summary Of Dada2 Output"
# feature table summary
qiime feature-table summarize \
  --i-table /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_table.qza \
  --o-visualization /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_table.qzv \
  --m-sample-metadata-file /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/sample-metadata.tsv
echo "[+] DONE"
echo "[+] Creating Dada2 Visualization"
# rep-seqs summary
qiime feature-table tabulate-seqs \
  --i-data /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs.qza \
  --o-visualization /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs.qzv
echo "[+] DONE"
echo "[+] STARTING to produce taxonomy bar plots"
qiime taxa barplot \
  --i-table /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_table.qza \
  --i-taxonomy /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/dada2_rep_seqs_taxonomy.qza \
  --m-metadata-file /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/sample-metadata.tsv \
  --o-visualization /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/524291/taxa_barplot.qzv
echo "[+] DONE"
