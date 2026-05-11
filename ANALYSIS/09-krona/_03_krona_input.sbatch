#!/bin/bash
#SBATCH --job-name=awk
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --output=logs/INPUT.%A_%a.log

set -euo pipefail

mkdir -p logs


scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../samples.txt)

mkdir -p ${sample}

srun awk -F'\t' 'BEGIN{OFS="\t"} {print $1, $2, $3, $5, $6}' ${sample}/${sample}_filter_hit.tsv > ${sample}/${sample}_krona_input.tsv

srun awk -F'\t' 'BEGIN{OFS="\t"} {print $1, $2, $3, $5, $6}' ${sample}/${sample}_filter_hit_reads.tsv > ${sample}/${sample}_krona_input_reads.tsv
