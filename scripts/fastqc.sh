#!/bin/bash

while [[ $# -gt 0 ]]
do
    case "$1" in
        --input_dir)
            INPUT_DIR="$2"
            shift 2
            ;;
        --output_dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Run FastQC on all fasta files
for file in "$INPUT_DIR"/*.fastq.gz "$INPUT_DIR"/*.fastq; do
    [[ -e "$file" ]] || continue
    ~/FastQC/fastqc \
        --outdir "$OUTPUT_DIR" \
        "$file"
done
