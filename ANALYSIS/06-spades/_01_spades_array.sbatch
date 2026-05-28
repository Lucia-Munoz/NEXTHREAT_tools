#!/bin/bash
#SBATCH --job-name=spades
#SBATCH --partition=middle_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --output=logs/SPADES.%A_%a.log

set -euo pipefail

mkdir -p logs

scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../samples_id.txt)

mkdir -p ${sample}

srun singularity exec -B ${scratch_dir}/../../../ /data/ucct/bi/pipelines/singularity-images/depot.galaxyproject.org-singularity-spades-4.0.0--h5fb382e_1.img metaviralspades.py -1 ${scratch_dir}/../05-kraken/${sample}/viral_reads_${sample}_1.fastq -2 ${scratch_dir}/../05-kraken/${sample}/viral_reads_${sample}_2.fastq -k 21,33,55,77,99 -m 80 -o ${sample
