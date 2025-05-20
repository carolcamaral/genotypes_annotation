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

### 1. Create a work folder in Scratch
Example:
```bash
cd $MYSCRATCH
mkdir work_genotypes
````

### 2. Clone this repository

```bash
git clone git@github.com:carolcamaral/genotypes_annotation.git
cd genotypes_annotation
````

### 3. Download ANNOVAR databases
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

### 4. Move the raw genotypes data into the folder
You can use pshell to move files between the Data Storage and your local Pawsey scratch directory.

   4.1. Navigate to your project folder:
   ```bash
   cd $MYSCRATCH/work_genotypes/genotypes_annotation
   ````
   4.2. Load Python module (Check available Python versions):
   ```bash
    module load python/3.11.6
   ````
   ![image](https://github.com/user-attachments/assets/c10f996d-4ed5-489a-8028-a72513199025)
   4.3. Run pshell:
   ```bash
       python pshell 
   ````
   4.4. Log in to the data system. Enter your username and password when prompted.
   ```bash
       login 
   ````
   4.5. Navigate to your remote data directory (Replace with your actual remote data path). Example:
   ```bash
       cd projects/PPMIgenomics/GP2data/gp2_tonic-perron/WGS_052025/release10/raw-genotypes/EUR/
   ````
   4.6. Make sure you are in your local working directory:
   ```bash
       lcd $MYSCRATCH/work_genotypes
   ````
   4.7. Transfer files from remote to local using GET. Example (You can replace TONIC* with the filenames or patterns you need):
   ```bash
       get TONIC*
   ````
   4.8. Exit pshell:
   ```bash
       exit
   ````
   ![image](https://github.com/user-attachments/assets/017ff839-5f2b-48b0-b919-4b12f578ad7f)


## How to Run the Pipeline

### 1. Single ID 
Run the pipeline from your working directory by specifying:
1. The base name of your PLINK dataset (e.g., TONIC-PERRON_EUR_release10)
2. The sample ID to extract (e.g., TONIC-PERRON_{ID})
3. (Optional) The root directory where the annovar/ folder is located.
   - Default: genotypes_annotation
   - If your ANNOVAR setup is stored elsewhere, provide the full path to that directory.

```bash
cd $MYSCRATCH/work_genotypes
genotypes_annotation/annotation_pipeline.sh TONIC-PERRON_EUR_release10 TONIC-PERRON_{ID}
````

### 2. Multiple IDs (Batch Submission with SLURM)
To process multiple IDs at once and submit jobs to the SLURM scheduler:
1. Create a text file (e.g., ids.txt) with one ID per line.
2. Use the helper script to generate and submit SLURM jobs for each ID.

```bash
cd $MYSCRATCH/work_genotypes
genotypes_annotation/submit_annotation_jobs.sh TONIC-PERRON_EUR_release10 ids.txt
````
where ids.txt should look like:
```bash
TONIC-PERRON_000123_s1
TONIC-PERRON_000124_s1
TONIC-PERRON_000125_s1
TONIC-PERRON_000126_s1
TONIC-PERRON_000127_s1
```
Each line contains a single individual/sample ID, exactly as they appear in your PLINK dataset.
Avoid adding extra spaces or file extensions.

You can create this file manually or use tools like cut, awk, or grep if you want to extract IDs from an existing metadata or .psam file.

This script will:
- Loop through each ID in ids.txt
- Dynamically create a job script for each ID
- Submit the job using sbatch

You can check all your current jobs using:
```bash
squeue -u $USER
```

## Output
1. A VCF file for the selected sample
2. ANNOVAR-annotated file: {ID}.hg38_multianno.txt
3. Filtered file: {ID}.hg38_multianno_filtered_output.txt

Filtered results contain only:
- Non-reference genotypes (0/1 or 1/1)
- Variants with ≥3 out of 5 selected dbNSFP rank scores > 0.6
