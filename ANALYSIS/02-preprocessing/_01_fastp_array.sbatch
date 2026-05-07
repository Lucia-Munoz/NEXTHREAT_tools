#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH --partition=middle_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
#SBATCH --output=logs/FASTP.%A_%a.log

set -euo pipefail

mkdir -p logs


scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../repetir.txt)

mkdir -p ${sample}

srun singularity exec -B ${scratch_dir}/../../../ \
-B /srv/fastq_repo/ \
/data/ucct/bi/pipelines/singularity-images/fastp:0.20.0--hdbcaa40_0 \
fastp --cut_front --cut_tail --trim_poly_x --cut_mean_quality 20 --qualified_quality_phred 20 --unqualified_percent_limit 10 --length_required 50 --in1 ${scratch_dir}/../00-reads/${sample}_R1.fastq.gz --in2 ${scratch_dir}/../00-reads/${sample}_R2.fastq.gz --thread 5 --json ${scratch_dir}/${sample}/${sample}_fastp.json --html ${scratch_dir}/${sample}/${sample}_fastp.html --out1 ${scratch_dir}/${sample}/${sample}_R1_filtered.fastq.gz --out2 ${scratch_dir}/${sample}/${sample}_R2_filtered.fastq.gz
