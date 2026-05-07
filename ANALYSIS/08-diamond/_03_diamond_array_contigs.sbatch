#!/bin/bash
#SBATCH --job-name=diamond
#SBATCH --partition=long_idx
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
#SBATCH --output=logs/DIAMOND_CONTIGS.%A_%a.log

mkdir -p logs

scratch_dir=$(echo $PWD | sed "s/\/data\/ucct\/bi\/scratch_tmp/\/scratch/g")

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ../chikungunya.txt)

srun singularity exec -B ${scratch_dir}/../../../ -B  /data/ucct/bi/research/20260209_TFM_LMUNOZ_JL-VL_T/REFERENCES /data/ucct/bi/pipelines/singularity-images/depot.galaxyproject.org-singularity-diamond-2.1.12--hdb4b4cc_1.img diamond blastx -d /data/ucct/bi/research/20260209_TFM_LMUNOZ_JL-VL_T/REFERENCES/viral_assembly_aa.dmnd -q ../06-spades/${sample}/${sample}_filtered_contigs.fasta -o ${sample}/diamond_output102.tsv --outfmt 102 --top 10 --include-lineage -p 8 --sensitive --min-score 50
