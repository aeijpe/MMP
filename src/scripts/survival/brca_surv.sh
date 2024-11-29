#!/bin/bash

gpuid=$1
config=$2
data_rna=$3
omics_file=$4

### Dataset Information
dataroots='data_wsi/tcga_brca'


task='BRCA_survival'
target_col='dss_survival_days'
split_names='train,test'

split_dir='survival/TCGA_BRCA_overall_survival_k=0'
bash "scripts/survival/${config}.sh" $gpuid $task $target_col $split_dir $split_names $data_rna $dataroots $omics_file
split_dir='survival/TCGA_BRCA_overall_survival_k=1'
bash "scripts/survival/${config}.sh" $gpuid $task $target_col $split_dir $split_names $data_rna $dataroots $omics_file
split_dir='survival/TCGA_BRCA_overall_survival_k=2'
bash "scripts/survival/${config}.sh" $gpuid $task $target_col $split_dir $split_names $data_rna $dataroots $omics_file
split_dir='survival/TCGA_BRCA_overall_survival_k=3'
bash "scripts/survival/${config}.sh" $gpuid $task $target_col $split_dir $split_names $data_rna $dataroots $omics_file
split_dir='survival/TCGA_BRCA_overall_survival_k=4'
bash "scripts/survival/${config}.sh" $gpuid $task $target_col $split_dir $split_names $data_rna $dataroots $omics_file