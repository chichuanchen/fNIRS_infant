% fNIRS processing notes

%% Transform data from NIRx into a .nirs file (for Homer2 to read)
% Use function NIRx2nirs.m for single subject folder 
% or run script NIRx2nirs_batch.m for batch files 
% (required input: root directory containing date folders, which contain subject folders)
% Both scripts let you choose output directory

%% Exclude invalid trials (trials where infants were not looking at the stimuli)
% Run script toggle_off_no_look.m
% !!!!!!! ^case-specific input needed; for more please read notes inside the script !!!!!!!

%% Exclude noisy channels using visual inspection (experience needed)
% Manually exclude unwanted channels in Homer2_UI by left clicking the
% channel

%% Exclude subjects based on number of looking trials
% criteria: learning trials > 11; standard trial > 3; omission trial > 3
% as well as other factors such as parents talking, cap position etc.
% Manually excluded

%% Extract number of trials before motion correction
% use function extract_trial_num.m

%% Run motion corrections

%% Extract number of trials survived after motion correction
% this is to compare different motion correction methods
% use function extract_trial_num.m
% input directory can also be one that conatins pre-motion correction .nirs
% this function outputs csv files with number of trials counted for each
% condition (each column is a condition)

%% Calculate concentration group average for each channel
% + plot data for each channel using QuanAnalysis.m (modified from Lu's
% "QuanAnalysis_excel.m" function)
% Inside this script we also select channels for further analysis by
% examining whether HbO in the standard condition is statistically > 0
% (we do both one- and two- tail t test, but without multiple comparison correction)
% Outputs from this script include:
% 1. Group averaged, block averaged hemodynamic response in plots
% 2. Signal mean during given time interval
% 3. Signal mean during given time interval outputed as csv files
% 4. txt files showing how many channels were included in SM analysis
% 5. Simple t tests testing whether HbO SM in standard condition differ from 0