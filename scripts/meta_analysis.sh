qiime taxa collapse \
  --i-table ../results/reference_set_meta_analysis_1/PRJEB101302/table_no_organelles.qza \
  --i-taxonomy ../results/reference_set_meta_analysis_1/PRJEB101302/dada2-seqs-filtered-without-organelles.qza \
  --p-level 6 \
  --o-collapsed-table ../results/reference_set_meta_analysis_1/PRJEB101302-genus-table.qza
qiime taxa collapse \
  --i-table ../results/reference_set_meta_analysis_1/PRJNA524291/table_no_organelles.qza \
  --i-taxonomy ../results/reference_set_meta_analysis_1/PRJNA524291/dada2-seqs-filtered-without-organelles.qza \
  --p-level 6 \
  --o-collapsed-table ../results/reference_set_meta_analysis_1/PRJNA524291-genus-table.qza
qiime taxa collapse \
  --i-table ../results/reference_set_meta_analysis_1/PRJNA1336731/table_no_organelles.qza \
  --i-taxonomy ../results/reference_set_meta_analysis_1/PRJNA1336731/dada2-seqs-filtered-without-organelles.qza \
  --p-level 6 \
  --o-collapsed-table ../results/reference_set_meta_analysis_1/PRJNA1336731-genus-table.qza
qiime feature-table merge \
  --i-tables ../results/reference_set_meta_analysis_1/PRJEB101302-genus-table.qza ../results/reference_set_meta_analysis_1/PRJNA524291-genus-table.qza ../results/reference_set_meta_analysis_1/PRJNA1336731-genus-table.qza \
  --o-merged-table ../results/reference_set_meta_analysis_1/merged-genus-table.qza
qiime feature-table summarize \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table.qza \
  --m-sample-metadata-file ../data/reference_set_meta_analysis_1/combined_metadata_file.csv \
  --o-visualization ../results/reference_set_meta_analysis_1/merged-genus-table.qzv
qiime taxa barplot \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table.qza \
  --m-metadata-file ../data/reference_set_meta_analysis_1/combined_metadata_file.csv \
  --o-visualization ../results/reference_set_meta_analysis_1/merged-genus-barplot.qzv
qiime feature-table relative-frequency \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table.qza \
  --o-relative-frequency-table ../results/reference_set_meta_analysis_1/merged-genus-relative.qza
qiime feature-table heatmap \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table.qza \
  --m-sample-metadata-file ../data/reference_set_meta_analysis_1/combined_metadata_file.csv \
  --m-sample-metadata-column project \
  --p-title "Genus heatmap by project" \
  --o-visualization ../data/reference_set_meta_analysis_1/heatmap-condition.qzv
qiime feature-table filter-samples \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table.qza \
  --p-min-frequency 1000 \
  --o-filtered-table ../results/reference_set_meta_analysis_1/merged-genus-table-min1000.qza
qiime feature-table filter-features-conditionally \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table-min1000.qza \
  --p-abundance 0.001 \
  --p-prevalence 0.05 \
  --o-filtered-table ../results/reference_set_meta_analysis_1/merged-genus-table-filtered.qza
qiime taxa barplot \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table-filtered.qza \
  --m-metadata-file ../data/reference_set_meta_analysis_1/combined_metadata_file.csv \
  --o-visualization ../results/reference_set_meta_analysis_1/merged-genus-filtered-barplot.qzv
qiime diversity core-metrics \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table-filtered.qza \
  --p-sampling-depth 1000 \
  --m-metadata-file ../data/reference_set_meta_analysis_1/combined_metadata_file.csv \
  --output-dir ../results/reference_set_meta_analysis_1/genus-core-metrics/
qiime diversity alpha-group-significance \
  --i-alpha-diversity ../results/reference_set_meta_analysis_1/genus-core-metrics/shannon_vector.qza \
  --m-metadata-file ../data/reference_set_meta_analysis_1/combined_metadata_file.csv \
  --o-visualization ../results/reference_set_meta_analysis_1/genus-core-metrics/shannon-group-significance.qzv
qiime diversity beta-group-significance \
  --i-distance-matrix ../results/reference_set_meta_analysis_1/genus-core-metrics/bray_curtis_distance_matrix.qza \
  --m-metadata-file ../data/reference_set_meta_analysis_1/combined_metadata_file.csv \
  --m-metadata-column project \
  --p-pairwise \
  --o-visualization ../results/reference_set_meta_analysis_1/genus-core-metrics/bray-condition-significance.qzv
qiime feature-table heatmap \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table-filtered.qza \
  --m-sample-metadata-file ../data/reference_set_meta_analysis_1/combined_metadata_file.csv \
  --m-sample-metadata-column project \
  --p-title "Genus heatmap by project" \
  --o-visualization ../data/reference_set_meta_analysis_1/heatmap-filtered-condition.qzv
qiime feature-table relative-frequency \
  --i-table ../results/reference_set_meta_analysis_1/merged-genus-table-filtered.qza \
  --o-relative-frequency-table ../results/reference_set_meta_analysis_1/merged-genus-table-filtered-relative.qza
