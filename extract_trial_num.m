function extract_trial_num(nirs_dir, outfname) 

% extract_trial_num.m
% #######################################################################
% This function extracts number of trials for each condition by reading the 
% s variable (before hmrBlockAvg) or procResult.nTrials (after hmrBlockAvg) 
% in each .nirs file in the input directory.
% 
% Two inputs needed:
% 1) Directory where .nirs files are stored
% 2) Desired output csv file name
%
%
% Created by Chi-Chuan Chen (chichuan.chen46 at gmail.com) 
% for the NTNU-Haskins Joint Lab
% 2020/8/25
% #######################################################################


if ~exist('nirs_dir', 'var')
    nirs_dir = uigetdir(pwd,'Select NIRx Data Folder...');
end

if ~exist('outfname', 'var')
    outfnametemp = inputdlg('Please enter desired output csv file name.');
    outfname = outfnametemp{1};
end

filelist = dir(fullfile(nirs_dir,'*.nirs'));
N=[];
for i = 1:length(filelist)
    
    load(fullfile(filelist(i).folder, filelist(i).name), '-mat');
    fprintf('Now reading %s from folder %s\n', filelist(i).name, nirs_dir)
    
    [num_frames, num_conds] = size(s);
    
    if exist('procResult', 'var')
        
        N = [N; procResult.nTrials];
        
    else
        
        while num_conds > 0
            N(i,num_conds) = nnz(s(:,num_conds));
            num_conds = num_conds-1;
        end
        
    end      
end

csvwrite([outfname, '.csv'], N);
fprintf('Number of trials saved in %s\n',[outfname '.csv'])

end