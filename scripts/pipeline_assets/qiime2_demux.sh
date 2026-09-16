#!/usr/bin/env bash
echo "[+] Starting to import Sequences!"
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/manifest_file.csv \
  --output-path /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/demux-paired-end.qza \
  --input-format PairedEndFastqManifestPhred33V2
echo "[+] Producing quality summary"
qiime demux summarize \
  --i-data /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/demux-paired-end.qza \
  --o-visualization /gpfs/project/lubec100/CuTrOmics/ExaiptasiaMicrobiome/results/576020/demux-summary.qzv
echo "[+] DONE"
