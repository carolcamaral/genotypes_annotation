# Genotype Annotation Pipeline

This repository contains a script that performs variant-level annotation and filtering for individual genotypes using **PLINK2** and **ANNOVAR**. It is designed to:

1. Extract individual-level genotype data using PLINK2.
2. Annotate variants using ANNOVAR with multiple functional and population frequency databases.
3. Filter annotated variants based on genotype and pathogenicity prediction scores from dbNSFP.

---

## What the Script Does

### 1. **Running PLINK**
The pipeline uses `plink2` to extract genotype information for a single individual from a multi-sample PLINK dataset. It generates a VCF file for that individual.

### 2. **Running ANNOVAR**
The script runs ANNOVAR's `table_annovar.pl` to annotate the individual's variants with the following databases:

- `refGene`: Gene-based annotations
- `cytoBand`: Cytogenetic bands
- `exac03`: Population allele frequencies from ExAC v0.3
- `avsnp150`: dbSNP IDs
- `dbnsfp47a`: Functional prediction scores
- `clinvar_20220320`: Clinical significance from ClinVar
- `dbscsnv11`: Splice site variant prediction

### 3. **Genotype Filtering**
Only variants with genotypes `0/1` or `1/1` are kept (heterozygous or homozygous alternative), as these are potentially impactful mutations compared to reference homozygotes (`0/0`).

### 4. **Functional Score Filtering**
From the `dbnsfp47a` database, the pipeline selects the **top five performing prediction scores** as evaluated by [Liu et al. (2020)](https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-020-00803-9). These are:

- BayesDel_addAF_rankscore
- ClinPred_rankscore
- VEST4_rankscore
- BayesDel_noAF_rankscore
- MetaLR_rankscore

Each of these scores is normalized to a **rank score** between 0 and 1, representing how damaging a variant is relative to others. For example, a score of 0.9 indicates the variant is in the top 10% most damaging.

A variant is retained only if **at least 3 out of these 5 scores have a rank score > 0.6**, indicating a higher likelihood of pathogenicity.

---

## Installation

### 1. Clone this repository

```bash
git clone git@github.com:carolcamaral/genotypes_annotation.git
cd genotypes_annotation
````

### 2. Download ANNOVAR databases
Move into the annovar directory and download the required annotation databases (this step may take a while):
```bash
cd annovar
./annotate_variation.pl -buildver hg38 -downdb cytoBand humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar refGene humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar exac03 humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar avsnp150 humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbnsfp47a humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar clinvar_20220320 humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbscsnv11 humandb/
````

## How to Run the Pipeline
Run the pipeline from your working directory by specifying:
1. The base name of your PLINK dataset (e.g., TONIC-PERRON_EUR_release10)
2. The sample ID to extract (e.g., TONIC-PERRON_{ID}_s1)
3. The full directory where the annotation_pipeline is (eg: $MYSCRATCH/genotypes_annotation)

```bash
genotypes_annotation/annotation_pipeline.sh $MYSCRATCH/work_genotypes/TONIC-PERRON_EUR_release10 TONIC-PERRON_{ID}_s1 $MYSCRATCH/genotypes_annotation
````

## Output
1. A VCF file for the selected sample
2. ANNOVAR-annotated file: {ID}.hg38_multianno.txt
3. Filtered file: {ID}.hg38_multianno_filtered_output.txt

Filtered results contain only:
- Non-reference genotypes (0/1 or 1/1)
- Variants with ≥3 out of 5 selected dbNSFP rank scores > 0.6
