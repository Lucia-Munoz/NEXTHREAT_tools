#!/bin/bash
#SBATCH --job-name=rawfastqc
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --output=logs/FASTQC.%A_%a.log

set -euo pipefail

mkdir -p logs


scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../samples.txt)

mkdir -p ${sample}

srun singularity exec -B ${scratch_dir}/../../../ \
-B /srv/fastq_repo/ \
/data/ucct/bi/pipelines/singularity-images/fastqc:0.11.9--hdfd78af_1 \
fastqc \
-o ${scratch_dir}/${sample} \
-t 8 ${scratch_dir}/../00-reads/${sample}_R1.fastq.gz \
${scratch_dir}/../00-reads/${sample}_R2.fastq.gz
