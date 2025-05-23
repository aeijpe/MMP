#!/bin/bash

gpuid=$1
task=$2
target_col=$3
split_dir=$4
split_names=$5
data_rna=$6
dataroots=$7
omics_file=$8

feat='extracted_res0_5_patch256_uni'
input_dim=1024
mag='20x'
patch_size=256

bag_size=4096 # No prototyping so we need a bag # otherwise to big. Can only take their setting
batch_size=1 # otherwise to big. Can only take their setting
out_size=16
out_type='allcat' # This one is always allcat
model_tuple='MIL,default' # Take mean offeatures --> not prototyping
max_epoch=20 # 20?? --> They use a max number of epochs of 20 in their code
lr=0.0001
wd=0.00001
lr_scheduler='cosine'
opt='adamW' # RadamW????? THEIR SETTING: RAdam
grad_accum=1
loss_fn='nll' # cox not possible
n_label_bin=4
alpha=0.5 # param for nll survloss
em_step=1
load_proto=0 # was 1, but we do not need it for survpath right?
es_flag=0
tau=1.0
eps=1
n_fc_layer=0
proto_num_samples='1.0e+05'
save_dir_root=results

# Multimodal args
model_mm_type='survpath'    # 'coattn', 'coattn_mot', 'histo', 'gene'
append_embed='random'
histo_agg='mean'
num_coattn_layers=1

IFS=',' read -r model config_suffix <<< "${model_tuple}"
model_config=${model}_${config_suffix}
feat_name=$(echo $feat | sed 's/^extracted-//')
exp_code=${task}::${model_config}::${feat_name}
save_dir=${save_dir_root}/${model_mm_type}/${omics_file}/lr_${lr}_opt_${opt}

th=0.00005
if awk "BEGIN {exit !($lr <= $th)}"; then
  warmup=0
  curr_lr_scheduler='constant'
else
  curr_lr_scheduler=$lr_scheduler
  warmup=1
fi

# Identify feature paths
feat_dir=${dataroots}/${feat}/feats_h5

# Actual command
cmd="CUDA_VISIBLE_DEVICES=$gpuid python -m training.main_survival \\
--data_source ${feat_dir} \\
--results_dir ${save_dir} \\
--split_dir ${split_dir} \\
--split_names ${split_names} \\
--task ${task} \\
--target_col ${target_col} \\
--model_histo_type ${model} \\
--model_histo_config ${model}_default \\
--n_fc_layers ${n_fc_layer} \\
--in_dim ${input_dim} \\
--opt ${opt} \\
--lr ${lr} \\
--lr_scheduler ${curr_lr_scheduler} \\
--accum_steps ${grad_accum} \\
--wd ${wd} \\
--warmup_epochs ${warmup} \\
--max_epochs ${max_epoch} \\
--train_bag_size ${bag_size} \\
--batch_size ${batch_size} \\
--seed 1 \\
--num_workers 8 \\
--em_iter ${em_step} \\
--tau ${tau} \\
--n_proto ${out_size} \\
--out_type ${out_type} \\
--loss_fn ${loss_fn} \\
--nll_alpha ${alpha} \\
--n_label_bins ${n_label_bin} \\
--early_stopping ${es_flag} \\
--ot_eps ${eps} \\
--fix_proto \\
--num_coattn_layers ${num_coattn_layers} \\
--model_mm_type ${model_mm_type} \\
--append_embed ${append_embed} \\
--histo_agg ${histo_agg} \\
--omics_dir ${data_rna} \\
--omics_type ${omics_file} \\
"

# Specifiy prototype path if load_proto is True
if [[ $load_proto -eq 1 ]]; then
  cmd="$cmd --load_proto \\
  --proto_path "splits/${split_dir}/prototypes/prototypes_c${out_size}_extracted-${feat_name}_faiss_num_${proto_num_samples}.pkl" \\
  "
fi

source /hpc/uu_inf_aidsaitfl/miniconda3/bin/activate mmp

# export TMPDIR=/hpc/uu_inf_aidsaitfl/
cd "/hpc/uu_inf_aidsaitfl/a_eijpe/MMP/src"

eval "$cmd"