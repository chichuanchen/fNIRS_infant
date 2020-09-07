% Quantitative Analysis: Signal mean (SM) during a set of interval
% Chi-Chuan Chen for NTNU-Haskins Joint Lab

%% Define case dependent variables
samplingrate = 7.8125;
sclConc = 1e6;
SMinterval = [0 3]; % seconds

conditions={'Learning','Standard','Omission'};
ch_location=[25 46 28 32 47 26 48 35 27 39 33 49 40 34 42 41 15 16 8 17 9 1 2 10 3];

%
nirs_dir = uigetdir(pwd,'Select NIRx Data Folder...');
filelist = dir(fullfile(nirs_dir,'*.nirs'));

dcAvg_gp=[]; % timepoint*Hb components*channels*conditions*subjects
measListAct_gp=[];
for subj = 1:length(filelist)
    
    load(fullfile(filelist(subj).folder, filelist(subj).name), '-mat');
    dcAvg_gp(:,:,:,:,subj)=procResult.dcAvg;
    measListAct_gp(subj,:)=procResult.SD.MeasListAct(1:length(procResult.SD.MeasListAct)/2)';
    
    ch_mask_ind=find(measListAct_gp(subj,:)==0);
    dcAvg_gp(:,:,ch_mask_ind,:,subj)=NaN;

    
end

tHRF = procResult.tHRF;
ch_list=SD.MeasList;

clear SD aux d ml procInput procResult s t tIncMan userdata

%% plot channel signals 

% Assign 25 channel locations on the plot
for cond=1:size(dcAvg_gp, 4)
    
    figure('Name', conditions{cond},'NumberTitle','off','WindowState','maximized')

%     ymin=min(reshape(mean(dcAvg_gp(:,1:2,:,cond,:),5, 'omitnan')*sclConc,1,[]));
%     ymax=max(reshape(mean(dcAvg_gp(:,1:2,:,cond,:),5, 'omitnan')*sclConc,1,[]));
    
    for channel=1:size(dcAvg_gp,3)

        subplot(7,7,ch_location(channel), 'replace') % grid size
        
        SigHbO=mean(dcAvg_gp(:,1,channel,cond,:),5,'omitnan')*sclConc;
        SigHbR=mean(dcAvg_gp(:,2,channel,cond,:),5,'omitnan')*sclConc;
        
        plot(tHRF,SigHbO,'color','r','linewidth',2), hold on
        plot(tHRF,SigHbR,'color','b','linewidth',2)
        
        plot([tHRF(1) tHRF(end)],[0 0],'k-','linewidth',2)
%          plot([0 0],[ymin ymax],'k-','linewidth',2)
        title(['S' num2str(ch_list(channel,1)) '-D' num2str(ch_list(channel,2))])
%          axis([tHRF(1) tHRF(end) ymin ymax])
        axis off
%         if channel==1
%             legend('HbO','HbR','Location','westoutside')
%         end
    end
    legend({'HbO','HbR'},'Position', [0.3 0.3 0.05 0.05])
end


%% Calculate signal mean within the period of 0 to 3 s
time_index=[find(tHRF>=SMinterval(1),1,'first') find(tHRF<=SMinterval(end),1,'last')]; % seconds

sm_HbO=[];  % subjects * channels * conditions 
sm_HbR=[];  % subjects * channels * conditions
for condition=1:size(dcAvg_gp,4)
    for channel=1:size(dcAvg_gp,3)
        %%% HbO
        sm_HbO(:,channel,condition)=squeeze(mean(dcAvg_gp(time_index(1):time_index(end),1,channel,condition,:),1,'omitnan')*sclConc);
        
        %%% HbR
        sm_HbR(:,channel,condition)=squeeze(mean(dcAvg_gp(time_index(1):time_index(end),2,channel,condition,:),1,'omitnan')*sclConc);        
    end
end

%% output group result to Excel files
%%%%%% HbO signal mean (0-3 seconds) for each subject / channel for the
%%%%%% learning condition

% HbO
cond_learn_HbO = sm_HbO(:,:,1);
cond_standard_HbO=sm_HbO(:,:,2);
cond_omission_HbO=sm_HbO(:,:,3);

csvwrite('cond_learn_HbO.csv', cond_learn_HbO)
csvwrite('cond_standard_HbO.csv', cond_standard_HbO)
csvwrite('cond_omission_HbO.csv', cond_omission_HbO)

% HbR
cond_learn_HbR = sm_HbR(:,:,1);
cond_standard_HbR=sm_HbR(:,:,2);
cond_omission_HbR=sm_HbR(:,:,3);

csvwrite('cond_learn_HbR.csv', cond_learn_HbR)
csvwrite('cond_standard_HbR.csv', cond_standard_HbR)
csvwrite('cond_omission_HbR.csv', cond_omission_HbR)

%% Find how many subjects are included for each channel
% fname='channel_N.txt';
fname='channel_N_gp1920m.txt';
fid=fopen(fname, 'w');
n_channel =[];
n_total_subj=size(dcAvg_gp,5);
for channel=1:size(dcAvg_gp,3)
    
    n_channel = length(find(~isnan(cond_standard_HbO(:,channel))));
    fprintf(fid, '%d out of %d subjects included in analysis for channel %d\n', ...
        n_channel, n_total_subj, channel);    
    
end
fclose(fid);
    
    
   

%% testing whether HbO signal mean in standard condition significantly > 0
% stats criteria: alpha = 0.05 (default)
% which channels
find(ttest(cond_standard_HbO)==1) % all subjs: 7(B5) 8(C5) 14(E7) 16(E8) 23(H12)
                                  % group 16m: 14(E7) 15(C8) 16(E8) 
                                  % group 1718m: 23(H12)
                                  % group 1920m: 8(C5)
                                  
find(ttest(cond_standard_HbO,0,'Tail','right')==1) % all subjs: 7(B5) 8(C5) 11(D6) 14(E7) 16(E8)
                                                   % group 16m: 7(B5) 13(D7) 14(E7) 15(C8) 16(E8)
                                                   % group 1718m: none
                                                   % group 1920m: 8(C5) 13(D7) 14(E7)
                                                   

%% testing whether HbO signal mean in omission condition significantly > 0
find(ttest(cond_omission_HbO)==1) % all subjs: 13(D7) 23(H12)
                                  % group 16m: 1(A1) 7(B5) 13(D7)
                                  % group 1718m: 23(H12) 24(G13) 25(H13) no occipital regions
                                  % group 1920m: 9(E5) 14(E7)
find(ttest(cond_omission_HbO,0,'Tail','right')==1) % all subjs: 7(B5) 13(D7)
                                                   % group 16m: 7(B5) 13(D7) 15(C8)
                                                   % group 1718m: 13(D7)
                                                   % group 1920m: 9(E5) 14(E7)
                                                   
%% testing whether HbO signal mean in standard and omission differ significantly
find(ttest2(cond_standard_HbO, cond_omission_HbO)==1) % all subjs: none
                                                      % group 16m: 1(A1) 16(E8)
                                                      % group 1718m: 24(G13)
                                                      % group 1920m: 8(C5)

