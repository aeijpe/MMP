#!/bin/bash
#SBATCH --job-name=run_MMP             # Job name
#SBATCH --partition=gpu                # Partition name (queue)
#SBATCH --cpus-per-task=4              # Number of CPU cores per task
#SBATCH --gres=tmpspace:30G            # Temporary disk space required
#SBATCH --gres=gpu:1                   # Number of GPUs per node
#SBATCH --time=10:00:00                # Time limit in HH:MM:SS
#SBATCH --mem=200G                     # Total memory per node
#SBATCH --output=jobs/slurm_%j.log     # Total memory per node
#SBATCH --nodelist=n0130               # Specific node name

# Start interactive bash session
cd /hpc/uu_inf_aidsaitfl/a_eijpe/MMP/src

# BRCA data!!
# Create histology prototypes
# scripts/prototype/brca.sh 0

# run mmp
# Their data
scripts/survival/brca_surv.sh 0 mmp data_csvs/rna/ rna_clean_theirs
# Own pancancer
scripts/survival/brca_surv.sh 0 mmp data_csvs/rna/ rna_clean_pan
# Own normal
scripts/survival/brca_surv.sh 0 mmp data_csvs/rna/ rna_clean

# # run survPath
# scripts/survival/brca_surv2.sh 0 survpath data_csvs/rna/ rna_clean_pan
# scripts/survival/brca_surv2.sh 0 survpath data_csvs/rna/ rna_clean

# scripts/survival/brca_surv.sh 0 survpath_setting2 data_csvs/rna/ rna_clean_pan
# scripts/survival/brca_surv.sh 0 survpath_setting2 data_csvs/rna/ rna_clean
