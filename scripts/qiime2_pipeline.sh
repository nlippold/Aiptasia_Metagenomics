# ==========================================
# Configuration
# ==========================================
N_THREADS=8
INPUT_DIR=""
OUTPUT_DIR=""
CLASSIFIER_FILE=""
AMPLICON_LENGTH=""
TRIM_LEFT_F=0
TRIM_LEFT_R=0
TRUNC_LEN_F=0
TRUNC_LEN_R=0
FILTER=false
VERBOSE=false
CALC_TRUNCATION=false
CREATE_MISSING_DIR=false
ENCODING=PairedEndFastqManifestPhred33V2
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PYTHON_MANIFEST_SCRIPT="$SCRIPT_DIR/pipeline_assets/create_manifest_metadata.py"
PYTHON_DADA2_QUALITY_CALC="$SCRIPT_DIR/pipeline_assets/calculate_dada2_quality_scores.py"
# ==========================================
# Parse command-line arguments
# ==========================================
LOGFILE="${OUTPUT_DIR:-.}/pipeline.log"

exec > >(tee -a "$LOGFILE")
exec 2> >(tee -a "$LOGFILE" >&2)


while [[ $# -gt 0 ]]
do
    case "$1" in
        --input_dir)
            INPUT_DIR="$2"
            shift 2 # removes both the option and its value
            ;;
        --output_dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --classifier_file)
            CLASSIFIER_FILE="$2"
            shift 2
            ;;
        --amplicon_length)
            AMPLICON_LENGTH="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --calc_truncation)
            CALC_TRUNCATION=True
            shift
            ;;
        --filter)
            FILTER=true
            shift
            ;;
        --create_missing_dir)
            CREATE_MISSING_DIR=true
            shift
            ;;
        *) # if $1 still exists an Unknown argument was given
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# ==========================================
# Validate command-line arguments
# ==========================================
FULL_INPUT_PATH=$(realpath "$INPUT_DIR")
FULL_OUTPUT_PATH=$(realpath "$OUTPUT_DIR")
CLASSIFIER_FILE=$(realpath "$CLASSIFIER_FILE")

# Check required arguments (-z checks if argument is empty)
if [[ -z "$INPUT_DIR" ]]; then
    echo "Error: --input_dir is required"
    exit 1 # echo error and exit script
fi

if [[ -z "$CLASSIFIER_FILE" ]]; then
    echo "Error: --classifier_file is required"
    exit 1
fi

if [[ -z "$OUTPUT_DIR" ]]; then
    echo "Error: --output_dir is required"
    exit 1
fi

if [[ -z "$AMPLICON_LENGTH" ]]; then
    echo "Error: --amplicon_length is required"
    exit 1
fi

if [[ ! -f "$CLASSIFIER_FILE" ]]; then
  echo "ERROR: Classifier file does not exist:"
  echo "  $CLASSIFIER_FILE"
  exit 1
fi

# Check whether input directory exists (-d checks if PATH exists)
if [[ ! -d "$FULL_INPUT_PATH" ]]; then
    echo "Error: Input directory does not exist:"
    echo "  $FULL_INPUT_PATH"
    exit 1
fi

if [[ ! -d "$FULL_OUTPUT_PATH" && "$CREATE_MISSING_DIR" == "false" ]]; then
  echo "INFO: Output directory does not exist, set create_missing_dir or create directory manually"
  echo " $FULL_OUTPUT_PATH"
  exit 1
fi

if [[ ! -d "$FULL_OUTPUT_PATH" && "$CREATE_MISSING_DIR" == "true" && "$VERBOSE" == "true" ]]; then
  echo "INFO: Output directory does not exist, creating new directory in:"
  echo " $FULL_OUTPUT_PATH"
  mkdir -p $FULL_OUTPUT_PATH
fi

# output infos for user
if [[ "$VERBOSE" == "true" ]]; then
  echo "Input directory is set to: $FULL_INPUT_PATH"
  echo "Output directory is set to: $FULL_OUTPUT_PATH"
  echo "Classifer used: $CLASSIFIER_FILE"
  echo "Specified amplicon length: $AMPLICON_LENGTH"
  echo "Number of threads: $N_THREADS"
fi

# ==========================================
# Check whether python script exists
# ==========================================
if [[ ! -f "$PYTHON_MANIFEST_SCRIPT" ]]; then
    echo "ERROR: Python script does not exist:"
    echo "  $PYTHON_MANIFEST_SCRIPT"
    exit 1
fi

if [[ ! -f "$PYTHON_DADA2_QUALITY_CALC" ]]; then
    echo "ERROR: Python script does not exist:"
    echo "  $PYTHON_DADA2_QUALITY_CALC"
    exit 1
fi

# ==========================================
# Pipeline start
# ==========================================
# loading qiime2
# module load Qiime2/2024.10.1

# writing manifest file for fastq file location feed into Qiime2
python3 "$PYTHON_MANIFEST_SCRIPT" \
    "$FULL_INPUT_PATH" \
    "$FULL_OUTPUT_PATH" \
    "$VERBOSE"

# ==========================================
# Check python exit code
# ==========================================
if [[ $? -ne 0 ]]; then
    echo "ERROR: Python script failed"
    exit 1
fi

MANIFEST_FILE=$FULL_OUTPUT_PATH/manifest_file.csv
METADATA_FILE=$FULL_OUTPUT_PATH/metadata_file.csv

if [[ ! -f $MANIFEST_FILE || ! -f $METADATA_FILE ]];then
  echo "ERROR: Metadata or manifest files do not exist"
  exit 1
fi

DEMUX_PAIRED_END=$FULL_OUTPUT_PATH/demux-paired-end.qza
DEMUX_QUALITY_SUMMARY=$FULL_OUTPUT_PATH/demux-summary.qzv
EXPORTED_DEMUX_DIR=$FULL_OUTPUT_PATH/demux_export/

DADA2_TABLE=$FULL_OUTPUT_PATH/dada2_table.qza
DADA2_SEQS=$FULL_OUTPUT_PATH/dada2_rep_seqs.qza
DADA2_STATS=$FULL_OUTPUT_PATH/dada2_stats.qza

DADA2_STATS_VIZ=$FULL_OUTPUT_PATH/dada2_stats.qzv
DADA2_TABLE_VIZ=$FULL_OUTPUT_PATH/dada2_table.qzv
DADA2_SEQS_VIZ=$FULL_OUTPUT_PATH/dada2_rep_seqs.qzv

MIN_FREQ_TABLE=$FULL_OUTPUT_PATH/dada2_table-minfreq10.qza
MIN_FREQ_SAMPLES_TABLE=$FULL_OUTPUT_PATH/dada2_table-minfreq10-minsamples2.qza
DADA2_CLEAN_SEQS=$FULL_OUTPUT_PATH/dada2-seqs-filtered.qza

TAXONOMIC_CLASSIFICATION_FILE=$FULL_OUTPUT_PATH/dada2-seqs-filtered-taxonomy.qza
TAXONOMIC_CLASSIFICATION_VIZ_FILE=$FULL_OUTPUT_PATH/dada2-seqs-filtered-taxonomy.qzv
TAXONOMIC_CLASSIFICATION_FILE_WITHOUT_ORGANELLES=$FULL_OUTPUT_PATH/dada2-seqs-filtered-without-organelles.qza
TAXONOMIC_CLASSIFICATION_VIZ_FILE_WITHOUT_ORGANELLES=$FULL_OUTPUT_PATH/dada2-seqs-filtered-without-organelles.qzv

NO_ORGANELLES_TABLE=$FULL_OUTPUT_PATH/table_no_organelles.qza
NO_ORGANELLES_REP_SEQS=$FULL_OUTPUT_PATH/rep_seqs_no_organelle.qza

TAXONOMY_BAR_PLOT=$FULL_OUTPUT_PATH/taxonomy_bar_plot.qzv

if [[ ! -d $EXPORTED_DEMUX_DIR ]]; then
  mkdir -p $EXPORTED_DEMUX_DIR
fi

if [[ "$VERBOSE" == "true" ]]; then

  if [[ ! -f $DEMUX_PAIRED_END || ! -f $DEMUX_QUALITY_SUMMARY ]]; then
    echo "INFO: Starting to import sequences into:"
    echo " $DEMUX_PAIRED_END"
    qiime tools import \
      --type 'SampleData[PairedEndSequencesWithQuality]' \
      --input-path "$MANIFEST_FILE" \
      --output-path "$DEMUX_PAIRED_END" \
      --input-format "$ENCODING"
    echo "INFO: Producing quality summary"
    echo " $DEMUX_QUALITY_SUMMARY"
    qiime demux summarize \
      --i-data "$DEMUX_PAIRED_END" \
      --o-visualization "$DEMUX_QUALITY_SUMMARY"
    qiime tools export \
      --input-path "$DEMUX_QUALITY_SUMMARY" \
      --output-path "$EXPORTED_DEMUX_DIR"
    echo "INFO: DONE importing and demultiplexing sequences"
  fi

  if [[ ! -f $DADA2_TABLE || ! -f $DADA2_SEQS || ! -f $DADA2_STATS ]]; then
    if [[ $CALC_TRUNCATION == "true" ]]; then
      eval "$(
      python "$PYTHON_DADA2_QUALITY_CALC" \
          --export-dir "$EXPORTED_DEMUX_DIR" \
          --amplicon-length "$AMPLICON_LENGTH" \
          --quality-threshold 25 \
          --min-overlap 20 \
          --output-format shell
      )"
      echo "INFO: Starting to clean samples with truncations set at:"
      echo "    forward truncation: $TRUNC_LEN_F reverse truncation: $TRUNC_LEN_R"
      qiime dada2 denoise-paired \
        --i-demultiplexed-seqs "$DEMUX_PAIRED_END" \
        --p-trunc-len-f "$TRUNC_LEN_F" \
        --p-trunc-len-r "$TRUNC_LEN_R" \
        --p-trim-left-f "$TRIM_LEFT_F" \
        --p-trim-left-r "$TRIM_LEFT_R" \
        --p-n-threads "$N_THREADS" \
        --o-table "$DADA2_TABLE" \
        --o-representative-sequences "$DADA2_SEQS" \
        --o-denoising-stats "$DADA2_STATS"
      echo "INFO: DONE denoising with dada2"
    else
      echo "INFO: Enter --p-trunc-len-f:"
      read TRUNC_LEN_F
      echo "INFO: Enter --p-trunc-len-r:"
      read TRUNC_LEN_R
      echo "INFO: Enter --p-trim-left-f:"
      read TRIM_LEFT_F
      echo "INFO: Enter --p-trim-left-r:"
      read TRIM_LEFT_R
      echo "You have entered following settings for DADA2:"
      echo "--p-trunc-len-f: $TRUNC_LEN_F"
      echo "--p-trunc-len-r: $TRUNC_LEN_R"
      echo "--p-trim-left-f: $TRIM_LEFT_F"
      echo "--p-trim-left-r: $TRIM_LEFT_R"
      echo "INFO: starting dada2 denoise-paired procedure"
      qiime dada2 denoise-paired \
        --i-demultiplexed-seqs "$DEMUX_PAIRED_END" \
        --p-trunc-len-f "$TRUNC_LEN_F" \
        --p-trunc-len-r "$TRUNC_LEN_R" \
        --p-trim-left-f "$TRIM_LEFT_F" \
        --p-trim-left-r "$TRIM_LEFT_R" \
        --p-n-threads "$N_THREADS" \
        --o-table "$DADA2_TABLE" \
        --o-representative-sequences "$DADA2_SEQS" \
        --o-denoising-stats "$DADA2_STATS"
      echo "INFO: DONE denoising with dada2"
    fi
  fi

  # producing dada2 visualizations
  if [[ ! -f $DADA2_STATS_VIZ || ! -f $DADA2_TABLE_VIZ || ! -f $DADA2_SEQS_VIZ ]];then
    echo "INFO: starting to produce dada2 output visualizations"
    qiime metadata tabulate \
      --m-input-file "$DADA2_STATS" \
      --o-visualization "$DADA2_STATS_VIZ"
    qiime feature-table summarize \
      --i-table "$DADA2_TABLE" \
      --o-visualization "$DADA2_TABLE_VIZ" \
      --m-sample-metadata-file $METADATA_FILE
    qiime feature-table tabulate-seqs \
      --i-data "$DADA2_SEQS" \
      --o-visualization "$DADA2_SEQS_VIZ"
    echo "INFO: DONE producing dada2 visualizations"
  fi

  # filtering low frequency ASVs
  if [[ $FILTER == "true" && (
      ! -f $MIN_FREQ_TABLE ||
      ! -f $MIN_FREQ_SAMPLES_TABLE ||
      ! -f $DADA2_CLEAN_SEQS
    ) ]]; then
    echo "INFO: filtering dada2 output tables"
    # 1. Remove ASVs with very low total counts
    echo "INFO: removing ASVs with very low total counts"
    qiime feature-table filter-features \
      --i-table "$DADA2_TABLE" \
      --p-min-frequency 10 \
      --o-filtered-table "$MIN_FREQ_TABLE"
    echo "INFO: removing ASVs present in only one sample"
    # 2. Remove ASVs present in only one sample
    qiime feature-table filter-features \
      --i-table "$MIN_FREQ_TABLE" \
      --p-min-samples 2 \
      --o-filtered-table "$MIN_FREQ_SAMPLES_TABLE"
    echo "INFO: filtering representative sequences"
    qiime feature-table filter-seqs \
      --i-data "$DADA2_SEQS" \
      --i-table "$MIN_FREQ_SAMPLES_TABLE" \
      --o-filtered-data "$DADA2_CLEAN_SEQS"
    echo "INFO: DONE filtering"

  # updating DADA2 output files for taxonomic assignment if filter is set to false
  elif [[ $FILTER == "false" ]]; then
    echo "INFO: Filtering is set to false, keeping original dada2 output"
    MIN_FREQ_SAMPLES_TABLE=$DADA2_TABLE
    DADA2_CLEAN_SEQS=$DADA2_SEQS
  fi

  # taxonomic assignment
  if [[ ! -f $TAXONOMIC_CLASSIFICATION_FILE || ! -f $TAXONOMIC_CLASSIFICATION_VIZ_FILE ]]; then
    echo "INFO: starting to assign taxonomy with classifier: "
    echo "     $CLASSIFIER_FILE"
    qiime feature-classifier classify-sklearn \
      --i-classifier "$CLASSIFIER_FILE" \
      --i-reads "$DADA2_CLEAN_SEQS" \
      --o-classification "$TAXONOMIC_CLASSIFICATION_FILE"
    echo "INFO: done assigning taxonomic information to ASVs"
    echo "INFO: starting to produce visualizations"
    qiime metadata tabulate \
      --m-input-file "$TAXONOMIC_CLASSIFICATION_FILE" \
      --o-visualization "$TAXONOMIC_CLASSIFICATION_VIZ_FILE"
  fi

  # after taxonomic assignment mitochondria and chloroplasts can get removed
  if [[ ! -f $NO_ORGANELLES_REP_SEQS || ! -f $NO_ORGANELLES_TABLE ]]; then
    echo "INFO: Excluding Mitochondria, Chloroplasts"
    qiime taxa filter-table \
      --i-table "$MIN_FREQ_SAMPLES_TABLE" \
      --i-taxonomy "$TAXONOMIC_CLASSIFICATION_FILE" \
      --p-exclude mitochondria,chloroplast \
      --o-filtered-table "$NO_ORGANELLES_TABLE"
    qiime taxa filter-seqs \
      --i-sequences "$DADA2_CLEAN_SEQS" \
      --i-taxonomy "$TAXONOMIC_CLASSIFICATION_FILE" \
      --p-exclude mitochondria,chloroplast \
      --o-filtered-sequences "$NO_ORGANELLES_REP_SEQS"
    echo "INFO: DONE removing Mitochondria and Chloroplasts"
  fi

  if [[ ! -f $TAXONOMIC_CLASSIFICATION_FILE_WITHOUT_ORGANELLES ||
        ! -f $TAXONOMIC_CLASSIFICATION_VIZ_FILE_WITHOUT_ORGANELLES ]]; then
    echo "INFO: starting to assign taxonomy with classifier: "
    echo "     $CLASSIFIER_FILE"
    qiime feature-classifier classify-sklearn \
      --i-classifier "$CLASSIFIER_FILE" \
      --i-reads "$NO_ORGANELLES_REP_SEQS" \
      --o-classification "$TAXONOMIC_CLASSIFICATION_FILE_WITHOUT_ORGANELLES"
    echo "INFO: done assigning taxonomic information to ASVs"
    echo "INFO: starting to produce visualizations"
    qiime metadata tabulate \
      --m-input-file "$TAXONOMIC_CLASSIFICATION_FILE_WITHOUT_ORGANELLES" \
      --o-visualization "$TAXONOMIC_CLASSIFICATION_VIZ_FILE_WITHOUT_ORGANELLES"
  fi

  if [[ ! -f $TAXONOMY_BAR_PLOT ]]; then
    echo "INFO: starting to produce taxonomy bar plots"
    qiime taxa barplot \
      --i-table "$NO_ORGANELLES_TABLE" \
      --i-taxonomy "$TAXONOMIC_CLASSIFICATION_FILE_WITHOUT_ORGANELLES" \
      --m-metadata-file "$METADATA_FILE" \
      --o-visualization "$TAXONOMY_BAR_PLOT"
  fi
  echo "INFO: FINISHED PIPELINE!"

else
  if [[ ! -f $DEMUX_PAIRED_END || ! -f $DEMUX_QUALITY_SUMMARY ]]; then
    qiime tools import \
      --type 'SampleData[PairedEndSequencesWithQuality]' \
      --input-path "$MANIFEST_FILE" \
      --output-path "$DEMUX_PAIRED_END" \
      --input-format "$ENCODING"
    qiime demux summarize \
      --i-data "$DEMUX_PAIRED_END" \
      --o-visualization "$DEMUX_QUALITY_SUMMARY"
    qiime tools export \
      --input-path "$DEMUX_QUALITY_SUMMARY" \
      --output-path "$EXPORTED_DEMUX_DIR"
  fi

  if [[ ! -f $DADA2_TABLE || ! -f $DADA2_SEQS || ! -f $DADA2_STATS ]]; then
    eval "$(
    python "$PYTHON_DADA2_QUALITY_CALC" \
        --export-dir "$EXPORTED_DEMUX_DIR" \
        --amplicon-length "$AMPLICON_LENGTH" \
        --quality-threshold 25 \
        --min-overlap 20 \
        --output-format shell
    )"
    qiime dada2 denoise-paired \
      --i-demultiplexed-seqs "$DEMUX_PAIRED_END" \
      --p-trunc-len-f "$TRUNC_LEN_F" \
      --p-trunc-len-r "$TRUNC_LEN_R" \
      --p-trim-left-f "$TRIM_LEFT_F" \
      --p-trim-left-r "$TRIM_LEFT_R" \
      --p-n-threads "$N_THREADS" \
      --o-table "$DADA2_TABLE" \
      --o-representative-sequences "$DADA2_SEQS" \
      --o-denoising-stats "$DADA2_STATS"
  fi

  if [[ ! -f $DADA2_STATS_VIZ || ! -f $DADA2_TABLE_VIZ || ! -f $DADA2_SEQS_VIZ ]];then
    qiime metadata tabulate \
      --m-input-file "$DADA2_STATS" \
      --o-visualization "$DADA2_STATS_VIZ"
    qiime feature-table summarize \
      --i-table "$DADA2_TABLE" \
      --o-visualization "$DADA2_TABLE_VIZ" \
      --m-sample-metadata-file $METADATA_FILE
    qiime feature-table tabulate-seqs \
      --i-data "$DADA2_SEQS" \
      --o-visualization "$DADA2_SEQS_VIZ"
  fi

  if [[ $FILTER == "true" && (
      ! -f $MIN_FREQ_TABLE ||
      ! -f $MIN_FREQ_SAMPLES_TABLE ||
      ! -f $DADA2_CLEAN_SEQS
    ) ]]; then
    qiime feature-table filter-features \
      --i-table "$DADA2_TABLE" \
      --p-min-frequency 10 \
      --o-filtered-table "$MIN_FREQ_TABLE"
    qiime feature-table filter-features \
      --i-table "$MIN_FREQ_TABLE" \
      --p-min-samples 2 \
      --o-filtered-table "$MIN_FREQ_SAMPLES_TABLE"
    qiime feature-table filter-seqs \
      --i-data "$DADA2_SEQS" \
      --i-table "$MIN_FREQ_SAMPLES_TABLE" \
      --o-filtered-data "$DADA2_CLEAN_SEQS"

  elif [[ $FILTER == "false" ]]; then
    MIN_FREQ_SAMPLES_TABLE=$DADA2_TABLE
    DADA2_CLEAN_SEQS=$DADA2_SEQS
  fi

  if [[ ! -f $TAXONOMIC_CLASSIFICATION_FILE || ! -f $TAXONOMIC_CLASSIFICATION_VIZ_FILE ]]; then
    qiime feature-classifier classify-sklearn \
      --i-classifier "$CLASSIFIER_FILE" \
      --i-reads "$DADA2_CLEAN_SEQS" \
      --o-classification "$TAXONOMIC_CLASSIFICATION_FILE"
    qiime metadata tabulate \
      --m-input-file "$TAXONOMIC_CLASSIFICATION_FILE" \
      --o-visualization "$TAXONOMIC_CLASSIFICATION_VIZ_FILE"
  fi

  if [[ ! -f $NO_ORGANELLES_REP_SEQS || ! -f $NO_ORGANELLES_TABLE ]]; then
    qiime taxa filter-table \
      --i-table "$MIN_FREQ_SAMPLES_TABLE" \
      --i-taxonomy "$TAXONOMIC_CLASSIFICATION_FILE" \
      --p-exclude mitochondria,chloroplast \
      --o-filtered-table "$NO_ORGANELLES_TABLE"
    qiime taxa filter-seqs \
      --i-sequences "$DADA2_CLEAN_SEQS" \
      --i-taxonomy "$TAXONOMIC_CLASSIFICATION_FILE" \
      --p-exclude mitochondria,chloroplast \
      --o-filtered-sequences "$NO_ORGANELLES_REP_SEQS"
  fi

  if [[ ! -f $TAXONOMY_BAR_PLOT ]]; then
    qiime taxa barplot \
      --i-table "$NO_ORGANELLES_TABLE" \
      --i-taxonomy "$NO_ORGANLLES_REP_SEQS" \
      --m-metadata-file "$METADATA_FILE" \
      --o-visualization "$TAXONOMY_BAR_PLOT"
  fi
fi
# ending pipeline cleaning environment
# module unload Qiime2/2024.10.1
