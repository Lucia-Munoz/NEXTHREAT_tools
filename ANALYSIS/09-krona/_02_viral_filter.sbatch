#!/bin/bash
#SBATCH --job-name=awk
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --output=logs/FILTER.%A_%a.log

set -euo pipefail

mkdir -p logs


scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../chikungunya.txt)

mkdir -p ${sample}

srun awk -F'\t' 'BEGIN{OFS="\t"} { match($1, /cov_([0-9]+\.[0-9]+)/, arr); if (arr[1] >= 2) print $0, arr[1] }' \
    ${sample}/${sample}_species_filter.tsv > ${sample}/${sample}_filter_hit.tsv

srun awk 'BEGIN{} { count[$2]++; lines[NR]=$0; tax[NR]=$2 } END { for (i=1; i<=NR; i++) { if (count[tax[i]] > 5) print lines[i] } }' \
    ${sample}/${sample}_species_filter_reads.tsv > ${sample}/${sample}_filter_hit_reads.tsv
