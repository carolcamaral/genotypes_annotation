#!/bin/bash

# Input arguments
FILE_NAME="$1"
ID="$2"
BASH_DIRECTORY="${3:-genotypes_annotation}"

# Load required module
module use /software/projects/pawsey0360/modulefiles
module load plink2/2.0
echo "Loaded plink"

# Create output directory only if it doesn't exist
if [ ! -d "${FILE_NAME}/${ID}" ]; then
    mkdir -p "${FILE_NAME}/${ID}"
    echo "Created ${FILE_NAME}/${ID} directory"
else
    echo "Directory ${FILE_NAME}/${ID} already exists"
fi

# Extract individual from PLINK file to VCF
echo "Running Plink2"
plink2 --pfile "${FILE_NAME}" --indv "${ID}" --recode vcf id-paste=iid --out "${FILE_NAME}/${ID}/${ID}"


if touch "${FILE_NAME}/${ID}/${ID}.vcf"; then
    echo "File ${FILE_NAME}/${ID}/${ID}.vcf was successfully created"
else
    echo "Failed to create file ${FILE_NAME}/${ID}/${ID}.vcf"
fi
