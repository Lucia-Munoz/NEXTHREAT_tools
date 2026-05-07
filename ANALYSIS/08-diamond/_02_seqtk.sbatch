#!/bin/bash
#SBATCH --job-name=seqtk
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=40G
#SBATCH --output=logs/SEQTK.%A_%a.log

set -euo pipefail

mkdir -p logs

scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../samples.txt)

mkdir -p ${sample}

srun singularity exec -B ${scratch_dir}/../../../ /data/ucct/bi/pipelines/singularity-images/depot.galaxyproject.org-singularity-seqtk-1.3--h5bf99c6_3.img seqtk seq -L 100 ${scratch_dir}/../05-kraken/${sample}/${sample}_reads.fastq | pigz -p 8 > ${sample}/${sample}_filtered_reads.fastq
