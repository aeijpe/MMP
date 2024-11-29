#!/bin/bash

gpuid=$1

# Loop through different folds
for k in 0 1 2 3 4; do
	split_dir="survival/TCGA_BRCA_overall_survival_k=${k}"
	split_names="train"
	bash "scripts/prototype/clustering.sh" $gpuid $split_dir $split_names "data_wsi/tcga_brca"
done