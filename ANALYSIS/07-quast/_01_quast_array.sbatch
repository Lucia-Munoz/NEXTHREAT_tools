#!/bin/bash
#SBATCH --job-name=quast
#SBATCH --partition=middle_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --output=logs/QUAST.%A_%a.log

set -euo pipefail

mkdir -p logs

# Scratch dir
scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../samples.txt)

srun singularity exec -B ${scratch_dir}/../../../ \
/data/ucct/bi/pipelines/singularity-images/depot.galaxyproject.org-singularity-quast-5.2.0--py39pl5321heaaa4ec_4.img \
quast.py \
--min-contig 0 \
../06-spades/${sample}/contigs.fasta \
../06-spades/${sample}/scaffolds.fasta \
-o ${sample}/ \
--threads 8
