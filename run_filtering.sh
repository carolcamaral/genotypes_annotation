#!/bin/bash

# Input arguments
TXT_FILE_NAME="$1"

# Setup
TXT_DIR=$(dirname "$TXT_FILE_NAME")
BASE_NAME=$(basename "$TXT_FILE_NAME" .txt)

WORKDIR=$(pwd)
GENE_LIST_PD="${WORKDIR}/genotypes_annotation/disease_related_genes/parkinson_gene_list.txt"
GENE_LIST_MND="${WORKDIR}/genotypes_annotation/disease_related_genes/mnd_gene_list.txt"
GENE_LIST_AD="${WORKDIR}/genotypes_annotation/disease_related_genes/alzheimer_gene_list.txt"


# Filter annotated results
echo "Filtering Results"
awk -F'\t' '
NR==1 {
    print; next
}
($189 ~ /^0\/1/ || $189 ~ /^1\/1/) {
    count = 0;
    if ($81 >= 0.6) count++;
    if ($84 >= 0.6) count++;
    if ($50 >= 0.6) count++;
    if ($87 >= 0.6) count++;
    if ($55 >= 0.6) count++;
    if (count >= 3) print
}' "${TXT_FILE_NAME}" > "${TXT_DIR}/${BASE_NAME}_filtered_output.txt"

# Parkinson's
if [[ -n "$GENE_LIST_PD" ]]; then
  awk 'BEGIN {FS=OFS="\t"}
       NR==FNR { genes[$1]; next }
       FNR==1 || $7 in genes' "$GENE_LIST_PD" "${TXT_DIR}/${BASE_NAME}_filtered_output.txt" > "${TXT_DIR}/${BASE_NAME}_filtered_output_parkinsons_disease_genes.txt"
else
  echo "No PD gene list provided."
fi

# MND
if [[ -n "$GENE_LIST_MND" ]]; then
  awk 'BEGIN {FS=OFS="\t"}
       NR==FNR { genes[$1]; next }
       FNR==1 || $7 in genes' "$GENE_LIST_MND" "${TXT_DIR}/${BASE_NAME}_filtered_output.txt" > "${TXT_DIR}/${BASE_NAME}_filtered_output_mnd_genes.txt"
else
  echo "No MND gene list provided."
fi

# Alzheimer's
if [[ -n "$GENE_LIST_AD" ]]; then
  awk 'BEGIN {FS=OFS="\t"}
       NR==FNR { genes[$1]; next }
       FNR==1 || $7 in genes' "$GENE_LIST_AD" "${TXT_DIR}/${BASE_NAME}_filtered_output.txt" > "${TXT_DIR}/${BASE_NAME}_filtered_output_alzheimer_genes.txt"
else
  echo "No AD gene list provided."
fi
