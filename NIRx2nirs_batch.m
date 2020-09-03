% Given root data directory, call NIRx2nirs.m to all subfolders
% Created by Chi-Chuan Chen for NTNU-Haskins Joint Lab in Taiwan, June 2020
% chichuan.chen46 at gmail.com

root_data_dir=uigetdir(pwd,'Select Root Subject Data Folder...');
out_dir = uigetdir(pwd,'Select .nirs files output folder...');

all_files = dir(fullfile(root_data_dir, ['**/' filesep '*_*']));
subj_dir = all_files([all_files.isdir]);



% function NIRx2nirs(NIRx_foldername, out_dir)
for i = 1:length(subj_dir)
    
    NIRx_fildername=[subj_dir(i).folder filesep subj_dir(i).name];
    NIRx2nirs(NIRx_fildername, out_dir);
    
end