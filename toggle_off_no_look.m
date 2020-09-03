% toggle_off_no_look.m 
% by Chi-Chuan Chen for the NTNU-Haskins Joint lab,
% Created in June 2020
% Last edited 2020/8/27
% ################################################
% This script takes .nirs files with event (condition) timepoint
% information saved as variable s and informtaion about whether
% participants were looking at the stimuli at the time of presentation
% (coded manually through reviewing recorded videos of infants' gaze during
% the experiment) and turn the events where the participants were not
% looking into "toggled lines" as seen on Homer2 UI, aka rejected stimulus 
% from "stim reject". The resulting .nirs files with no-look events toggled
% off can be saved in another directory.
%
% Before running this script, please prepare:
%
% 1) .nirs files, specifically variable s (event time series) 
% 2) Manually coded looking-time table, with subject looking at the
% stimulus denoted as 1 and not-looking as 0.
% 3) In cases where subject ID differ from .nirs files and the manually
% coded excel subject ID, a table juxtaposing the two (e.g., .nirs files 
% are named in the formta of date of experiment 2020-04-06_001.nirs and 
% the same subject is named as ID 302 in other records).

load('date2subjID'); % manually created cell date2subjID

lookingtable = importdata('looking_18m.mat'); 
% copied from excel file, filled empty with NaN; saved as a double array

%%
nirs_dir=uigetdir(pwd,'Select the folder that contains all .nirs files');
toggled_dir=uigetdir(pwd,'Select where to output toggled files');

nirs_list = dir(fullfile(nirs_dir, '*.nirs'));

for i = 1:length(nirs_list)
    
    nirs_filename=nirs_list(i).name;
    [filepath, name, ext]=fileparts(nirs_filename);
    subj_dateID=name;
    
    IDflag=find(date2subjID(:,1)==string(subj_dateID));% find corresponded subj ID position (row number)
    subj_ID=date2subjID{IDflag,2}; %!!hard coding here 
    
    IDflag=find(lookingtable(:,1)==subj_ID);% find corresponded subj ID position (row number)
    lookingvec=lookingtable(IDflag,:);
    lookingvec=lookingvec(~isnan(lookingvec));%remove nans
    lookingvec=lookingvec(2:end);%remove ID number
    
    % load .nirs file and get the event time table
    load([nirs_dir filesep subj_dateID '.nirs'], '-mat');
    
    
    % extract timepoints with stimuli (1 or 2 or 3)
    [row,col]=find(s);
    timepoints_row=sort(row,'ascend');
    
    %flag no-look time points
    while length(lookingvec) > length(row)
        lookingvec = lookingvec(1:end-1);   
    end
    
    % indexing no-look position 
    nolookflag=timepoints_row(lookingvec==0);
    
    %turn no-look timepoints into -1
    %s_toggled = s;
    for j = 1:length(nolookflag)
       s(nolookflag(j),:)=s(nolookflag(j),:)*-1;     
    end
    
    %s=s_toggled;
    
    save([toggled_dir filesep subj_dateID '.nirs'], 's','aux','d','SD','t');
    
end