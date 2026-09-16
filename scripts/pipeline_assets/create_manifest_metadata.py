import os
import sys

if len(sys.argv) != 4:
    print("ERROR: usage python create_manifest.py INPUT_DIR OUTPUT_DIR VERBOSE")
    sys.exit(1)

input_dir = sys.argv[1]
output_dir = sys.argv[2]
verbose = sys.argv[3]

if not os.path.isdir(input_dir) or not os.path.isdir(output_dir):
    print("ERROR: directory does not exist: {}".format(input_dir))
    sys.exit(1)

fastq_file_list = os.listdir(input_dir)

if verbose:
    print("INFO: Creating Manifest File for {} samples".format(len(fastq_file_list)))

clean_samples = []
for filename in fastq_file_list:
    if filename.endswith("_1.fastq.gz"):
        sample = filename.replace("_1.fastq.gz", "")

        forward_file = os.path.join(input_dir, f"{sample}_1.fastq.gz")
        reverse_file = os.path.join(input_dir, f"{sample}_2.fastq.gz")

        if not os.path.isfile(reverse_file):
            print(f"ERROR: missing reverse read for sample: {sample}")
            sys.exit(1)

        if not os.path.isfile(forward_file):
            print(f"ERROR: missing forward read for sample: {sample}")
            sys.exit(1)
    elif filename.endswith("_2.fastq.gz"):
        sample = filename.replace("_2.fastq.gz", "")

        forward_file = os.path.join(input_dir, f"{sample}_1.fastq.gz")
        reverse_file = os.path.join(input_dir, f"{sample}_2.fastq.gz")

        if not os.path.isfile(reverse_file):
            print(f"ERROR: missing reverse read for sample: {sample}")
            sys.exit(1)

        if not os.path.isfile(forward_file):
            print(f"ERROR: missing forward read for sample: {sample}")
            sys.exit(1)        

    if sample not in clean_samples:
        clean_samples.append(sample)

if verbose:
    print("INFO: Working with {} unique samples".format(len(clean_samples)))

manifest_output_file_path = os.path.join(output_dir, "manifest_file.csv")
with open(manifest_output_file_path, "w") as manifest:
    manifest.write("sample-id\tforward-absolute-filepath\treverse-absolute-filepath\n")
    for sample in clean_samples:
        sample_id = sample
        forward_file = os.path.join(input_dir, f"{sample}_1.fastq.gz")
        reverse_file = os.path.join(input_dir, f"{sample}_2.fastq.gz")
        manifest.write("{}\t{}\t{}\n".format(sample_id,forward_file,reverse_file))

metadata_output_file_path = os.path.join(output_dir, "metadata_file.csv")

with open(metadata_output_file_path, "w") as metadata:
    metadata.write("sample-id\ttreatment\thost\n")
    for sample in clean_samples:
        metadata.write("{}\t{}\t{}\n".format(sample,"unknown","aiptasia"))

if verbose:
    print("INFO: DONE writing manifest and metadata file")

sys.exit()
