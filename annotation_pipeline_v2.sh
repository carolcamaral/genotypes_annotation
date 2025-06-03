#!/bin/bash

# Input arguments
FILE_NAME="$1"
ID="$2"
INPUT_FILE="${3:-}"
BASH_DIRECTORY="${4:-genotypes_annotation}"

echo "File Name ${FILE_NAME}" 
echo "ID ${ID}" 
echo "Directory ${BASH_DIRECTORY}"
echo "Input VCF file ${INPUT_FILE}"

# Create output directory only if it doesn't exist
if [ ! -d "${FILE_NAME}/${ID}" ]; then
    mkdir -p "${FILE_NAME}/${ID}"
    echo "Created ${FILE_NAME}/${ID} directory"
else
    echo "Directory ${FILE_NAME}/${ID} already exists"
fi

# Store current path
WORKDIR=$(pwd)
echo "Current directory: $(pwd)"


if [ -n "$INPUT_FILE" ]; then
    echo "Running VCF input pipeline - without plink"
    ./${BASH_DIRECTORY}/run_annovar.sh "${FILE_NAME}" "${ID}" "${BASH_DIRECTORY}" "${INPUT_FILE}"
    ./${BASH_DIRECTORY}/run_filtering.sh "${FILE_NAME}/${ID}/${ID}.hg38_multianno.txt" 

else
    echo "Running full pipeline"
    
    ./${BASH_DIRECTORY}/run_plink.sh "${FILE_NAME}" "${ID}" "${BASH_DIRECTORY}"
    ./${BASH_DIRECTORY}/run_annovar.sh "${FILE_NAME}" "${ID}" "${BASH_DIRECTORY}"
    ./${BASH_DIRECTORY}/run_filtering.sh "${FILE_NAME}/${ID}/${ID}.hg38_multianno.txt"


fi
