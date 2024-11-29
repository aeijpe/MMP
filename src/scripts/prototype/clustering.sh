#!/bin/bash

gpuid=$1
split_dir=$2
split_names=$3
dataroots=$4

feat='extracted_res0_5_patch256_uni'
input_dim=1024
mag='20x'
patch_size=256
n_sampling_patches=100000 # Number of patch features to connsider for each prototype. Total number of patch fatures = n_sampling_patches * n_proto
mode='faiss'  # 'faiss' or 'kmeans'
n_proto=16  # Number of prototypes
n_init=3  # Number of KMeans initializations to perform


# Validity check for feat paths
feat_dir=${dataroots}/${feat}/feats_h5

cmd="CUDA_VISIBLE_DEVICES=$gpuid python -m training.main_prototype \\
--mode ${mode} \\
--data_source ${feat_dir} \\
--split_dir ${split_dir} \\
--split_names ${split_names} \\
--in_dim ${input_dim} \\
--n_proto_patches ${n_sampling_patches} \\
--n_proto ${n_proto} \\
--n_init ${n_init} \\
--seed 1 \\
--num_workers 10 \\
"

eval "$cmd"