#!/bin/bash
#SBATCH --job-name=krona
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --output=logs/KRONA.%A_%a.log

set -euo pipefail

mkdir -p logs


scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../samples_id.txt)

mkdir -p ${sample}

srun singularity exec -B ${scratch_dir}/../../../ -B /home/lucia.munoz/taxonomy  /data/ucct/bi/pipelines/singularity-images/depot.galaxyproject.org-singularity-krona-2.8.1--pl5321hdfd78af_1.img ktImportTaxonomy ${sample}/${sample}_krona_input.tsv -q 1 -t 2 -m 4 -s 3  -tax /home/lucia.munoz/taxonomy -o ${sample}/${sample}_krona.html

srun singularity exec -B ${scratch_dir}/../../../ -B /home/lucia.munoz/taxonomy  /data/ucct/bi/pipelines/singularity-images/depot.galaxyproject.org-singularity-krona-2.8.1--pl5321hdfd78af_1.img ktImportTaxonomy ${sample}/${sample}_krona_input_reads.tsv -q 1 -t 2 -s 3  -tax /home/lucia.munoz/taxonomy -o ${sample}/${sample}_krona_reads.html
