#!/bin/bash

# Input arguments
WORKDIR=$(pwd)
FILE_NAME="$1"
ID="$2"
BASH_DIRECTORY="${3:-genotypes_annotation}"
VCF_FILE_NAME="${4:-${FILE_NAME}/${ID}/${ID}.vcf}"

FULL_PATH_VCF_FILE_NAME="${WORKDIR}/${VCF_FILE_NAME}"

echo "Running annovar with ${FULL_PATH_VCF_FILE_NAME}"
# Store annovar path
echo "Current directory: $(pwd)"
ANNOVAR_DIRECTORY="${3}/annovar"

# Move into annovar directory to run annotation
cd "${ANNOVAR_DIRECTORY}"  # <- Replace this with the actual full path to your annovar directory
echo "Current directory: $(pwd)"

# Annotate VCF using ANNOVAR
echo "Running ANNOVAR"
./table_annovar.pl "${FULL_PATH_VCF_FILE_NAME}" humandb/ \
  -buildver hg38 \
  -out "${WORKDIR}/${FILE_NAME}/${ID}/${ID}" \
  -remove \
  -protocol refGene,cytoBand,exac03,avsnp150,dbnsfp47a,clinvar_20220320,dbscsnv11 \
  -operation g,r,f,f,f,f,f \
  -nastring . \
  -vcfinput \
  -polish

if touch "${WORKDIR}/${FILE_NAME}/${ID}/${ID}.hg38_multianno.txt"; then
    echo "${WORKDIR}/${FILE_NAME}/${ID}/${ID}.hg38_multianno.txt was successfully created"
else
    echo "Failed to create file ${WORKDIR}/${FILE_NAME}/${ID}/${ID}.hg38_multianno.txt"
fi
