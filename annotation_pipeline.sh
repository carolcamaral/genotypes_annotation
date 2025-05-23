#!/bin/bash

# Input arguments
FILE_NAME="$1"
ID="$2"
BASH_DIRECTORY="${3:-genotypes_annotation}"

# Store current path
WORKDIR=$(pwd)
echo "Current directory: $(pwd)"
ANNOVAR_DIRECTORY="${3}/annovar"

# Load required module
module use /software/projects/pawsey0360/modulefiles
module load plink2/2.0
echo "Loaded plink"

# Create output directory
mkdir -p "${FILE_NAME}/${ID}"
echo "Created ${FILE_NAME}/${ID} directory"

# Extract individual from PLINK file to VCF
echo "Running Plink2"
plink2 --pfile "${FILE_NAME}" --indv "${ID}" --recode vcf id-paste=iid --out "${FILE_NAME}/${ID}/${ID}"

# Move into annovar directory to run annotation
cd "${ANNOVAR_DIRECTORY}"  # <- Replace this with the actual full path to your annovar directory
echo "Current directory: $(pwd)"

# Annotate VCF using ANNOVAR
echo "Running ANNOVAR"
./table_annovar.pl "${WORKDIR}/${FILE_NAME}/${ID}/${ID}.vcf" humandb/ \
  -buildver hg38 \
  -out "${WORKDIR}/${FILE_NAME}/${ID}/${ID}" \
  -remove \
  -protocol refGene,cytoBand,exac03,avsnp150,dbnsfp47a,clinvar_20220320,dbscsnv11 \
  -operation g,r,f,f,f,f,f \
  -nastring . \
  -vcfinput \
  -polish


# Return to original working directory
cd "$WORKDIR"
echo "Current directory: $(pwd)"


# Filter annotated results
echo "Filtering Results"
awk -F'\t' '
NR==1 {
    print; next
}
($189 == "0/1" || $189 == "1/1") {
    count = 0;
    if ($81 >= 0.6) count++;
    if ($84 >= 0.6) count++;
    if ($50 >= 0.6) count++;
    if ($87 >= 0.6) count++;
    if ($55 >= 0.6) count++;
    if (count >= 3) print
}' "${FILE_NAME}/${ID}/${ID}.hg38_multianno.txt" > "${FILE_NAME}/${ID}/${ID}.hg38_multianno_filtered_output.txt"

