#!/bin/bash

ID_FILE="$1"
FILE_NAME="$2"
ANNOVAR_ROOT_DIR="${3:-genotypes_annotation}"  # Default to 'genotypes_annotation' if not provided

if [[ ! -f "$ID_FILE" ]]; then
  echo "Error: ID file '$ID_FILE' not found!"
  exit 1
fi

while read -r ID VCF_FILE; do
  [[ -z "$ID" ]] && continue  # Skip empty lines

  # Create output, logs, and error directories
  if [ ! -d "${FILE_NAME}/${ID}/logs" ]; then
    mkdir -p "${FILE_NAME}/${ID}/logs"
  fi

  if [ ! -d "${FILE_NAME}/${ID}/errs" ]; then
    mkdir -p "${FILE_NAME}/${ID}/errs"
  fi

  JOB_SCRIPT="${FILE_NAME}/${ID}/job_${ID}.sh"

  # If VCF_FILE is empty, set empty string
  VCF_FILE_ARG="${VCF_FILE:-""}"

  cat <<EOF > "$JOB_SCRIPT"
#!/bin/bash
#SBATCH --job-name=annovar_${ID}
#SBATCH --nodes=1
#SBATCH --partition=work
#SBATCH --account=pawsey0360
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=50G
#SBATCH --time=4:00:00
#SBATCH --output=${FILE_NAME}/${ID}/logs/${ID}_%j.out
#SBATCH --error=${FILE_NAME}/${ID}/errs/${ID}_%j.err

# Run the annotation pipeline (v2)
bash ${ANNOVAR_ROOT_DIR}/annotation_pipeline_v2.sh $FILE_NAME $ID "$VCF_FILE_ARG" $ANNOVAR_ROOT_DIR
EOF

  chmod +x "$JOB_SCRIPT"
  sed -i 's/\r$//' "$JOB_SCRIPT"
  sbatch "$JOB_SCRIPT"
done < "$ID_FILE"
