#!/bin/bash
#SBATCH --job-name=kraken
#SBATCH --partition=middle_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=40G
#SBATCH --output=logs/KRAKEN.%A_%a.log

set -euo pipefail

mkdir -p logs


scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../repetir.txt)

mkdir -p ${sample}

srun singularity exec -B ${scratch_dir}/../../../ -B /data/ucct/bi/references/kraken/ \
/data/ucct/bi/pipelines/singularity-images/depot.galaxyproject.org-singularity-kraken2-2.0.8_beta--pl526hc9558a2_2.img \
kraken2 --db /data/ucct/bi/references/kraken/nexthreat_insects --paired --threads 12 --report ${scratch_dir}/${sample}/${sample}_kraken.report \
--report-zero-counts --unclassified-out ${scratch_dir}/${sample}/viral_reads_${sample}.fastq ${scratch_dir}/../02-preprocessing/${sample}/${sample}_R1_filtered.fastq.gz ${scratch_dir}/../02-preprocessing/${sample}/${sample}_R2_filtered.fastq.gz
