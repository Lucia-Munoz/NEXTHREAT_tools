#!/bin/bash
#SBATCH --job-name=awk
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --output=logs/SPECIES_FILTER.%A_%a.log

set -euo pipefail

mkdir -p logs

scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../chikungunya.txt)

mkdir -p ${sample}

srun awk -F '\t' '{ n = split($4,a,";"); if (n >= 8 && a[n] ~ /virus/ && a[n] !~ /phage/) print $0 }' \
    ../08-diamond/${sample}/diamond_output102.tsv > ${sample}/${sample}_species_filter.tsv

srun awk -F '\t' '{ n = split($4,a,";"); if (n >= 8 && a[n] ~ /virus/ && a[n] !~ /phage/) print $0 }' \
    ../08-diamond/${sample}/diamond_reads.tsv > ${sample}/${sample}_species_filter_reads.tsv
