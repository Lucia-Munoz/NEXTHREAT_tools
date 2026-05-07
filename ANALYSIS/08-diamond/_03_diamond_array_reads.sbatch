#!/bin/bash
#SBATCH --job-name=diamond
#SBATCH --partition=long_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
#SBATCH --output=logs/DIAMOND_READS.%A_%a.log

set -euo pipefail

mkdir -p logs


scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../samples.txt)

srun singularity exec \
  -B ${scratch_dir}/../../../ \
  -B /data/ucct/bi/research/20260209_TFM_LMUNOZ_JL-VL_T/REFERENCES \
  /data/ucct/bi/pipelines/singularity-images/depot.galaxyproject.org-singularity-diamond-2.1.12--hdb4b4cc_1.img \
  diamond blastx \
  -d /data/ucct/bi/research/20260209_TFM_LMUNOZ_JL-VL_T/REFERENCES/viral_assembly_aa.dmnd \
  -q $sample/${sample}_filtered_reads.fastq \
  -o $sample/diamond_reads.tsv \
  --outfmt 102 \
  --top 2 \
  --include-lineage \
  -p 8 \
  --sensitive \
  --min-score 80 \
  --query-cover 60 \
  --id 70 --tmpdir ${scratch_dir}
