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

bag_size='-1' # in mmp, we dont need a bag size --> summarize with morphological prototypes
batch_size=64 
out_size=16 # number of prototytpes
out_type='allcat' # in class PrototypeTokenizer. if protytpes are obtained with OT == allcat (prob=(1/n_prototypes) (every prototype has the same prob, mean = samples itself) OT agregation
# if prototypes are obtained with PANTHER
# allcat: Concatenates pi, mu, cov --> this is the one they use in the paper!!
# weight_param_cat: Concatenates mu and cov weighted by pi
# What about hard clustering??
model_tuple='PANTHER,default' # OT, default?? # for histo_model=mil: non-protoype; take the mean to aggregate the embeddings
max_epoch=20 # paper says 20??
lr=0.0001
wd=0.00001
lr_scheduler='cosine'
opt='adamW'
grad_accum=1
loss_fn='cox' # 'cox' # nll
n_label_bin=4
alpha=0.5
em_step=1 
load_proto=1
es_flag=0 # no early stopping
tau=1.0 # for em step
eps=1  # for creating conjugate priors of 
n_fc_layer=0 # not sure
proto_num_samples='1.0e+05'
save_dir_root=results

# Multimodal args
model_mm_type='coattn'    # 'coattn', 'coattn_mot', 'survpath', 'histo', 'gene'
append_embed='random' # the per-prototype embedding added to the embedding. # modality == one-hot per modality (prototypes have the same). proto == onehot per protoype and random == learnable embeddings (used)
histo_agg='mean' # how the post attention embeddings get aggregated after the feedforward nn layers (fcpost) into the patient embedding. They say it is sum, but it is mean!!!
num_coattn_layers=1

IFS=',' read -r model config_suffix <<< "${model_tuple}"
model_config=${model}_${config_suffix}
feat_name=$(echo $feat | sed 's/^extracted-//')
exp_code=${task}::${model_config}::${feat_name}
save_dir=${save_dir_root}/${omics_file}

th=0.00005
if awk "BEGIN {exit !($lr <= $th)}"; then
  warmup=0
  curr_lr_scheduler='constant'
else
  curr_lr_scheduler=$lr_scheduler
  warmup=1
fi

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
--net_indiv \\
"

# Specifiy prototype path if load_proto is True
if [[ $load_proto -eq 1 ]]; then
  cmd="$cmd --load_proto \\
  --proto_path "splits/${split_dir}/prototypes/prototypes_c${out_size}_${feat_name}_faiss_num_${proto_num_samples}.pkl" \\
  "
fi

source /hpc/uu_inf_aidsaitfl/miniconda3/bin/activate mmp

# export TMPDIR=/hpc/uu_inf_aidsaitfl/
cd "/hpc/uu_inf_aidsaitfl/a_eijpe/MMP/src"

eval "$cmd"