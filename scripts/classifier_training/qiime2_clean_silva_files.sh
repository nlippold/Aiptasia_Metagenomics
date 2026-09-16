#!/usr/bin/env bash
sed 's/U/T/g' /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/SILVA_138.2_SSURef_NR99_tax_silva.fasta > /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/SILVA_138.2_SSURef_NR99_tax_silva_DNA.fasta
echo "Done Converting Fasta File"
awk -F'\t' '
BEGIN {
    OFS = "\t";
    print "Feature ID", "Taxon"
}
NR > 1 {
    gsub(";", "; ", $4);   # optional: spacing readability
    print $1, $4
}
' /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxmap_slv_ssu_ref_138.2.txt \
> /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.tsv
echo "DONE converting silva taxonomy file"
TAX=/gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.tsv
FA=/gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/SILVA_138.2_SSURef_NR99_tax_silva_DNA.fasta
OUT=/gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.expanded.tsv

awk -F'\t' '
  NR==FNR {
    # taxonomy map: base_id -> taxon (keep first occurrence)
    if (!seen[$1]++) tax[$1]=$2
    next
  }
  /^>/ {
    id=$0
    sub(/^>/, "", id)
    sub(/[ \t].*$/, "", id)    # strip after whitespace
    base=id
    sub(/\..*$/, "", base)     # base = before first dot
    if (base in tax) print id "\t" tax[base]
    next
  }
' "$TAX" "$FA" > "$OUT"
echo "DONE expanding taxonomy"
awk -F'\t' 'NR==1{print; next} !seen[$1]++' \
  /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.expanded.tsv \
  > /gpfs/project/lubec100/CuTrOmics/QIIME2/classifier_new/taxonomy.expanded.dedup.tsv
echo "Done Converting Taxonomy Table"
