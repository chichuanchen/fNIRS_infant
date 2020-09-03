function NIRx2nirs(NIRx_foldername, out_dir)

% NIRx2nirs.m version 1.0
% #####################################################
% This script takes a folder (NIRx_foldername) containing the NIRx output
% data files (.hdr, .wl1, .wl2) and a pre-defined SD file (SD_filename) 
% (built using the Homer2 SDgui), which matches the source-detector layout 
% used in the NIRx acquisition and creates a .nirs file for use in Homer2

% To use this script, the user must first create an SD file which matches
% their NIRx probe layour using the SDgui function of Homer2.  It is 
% essential that the SD file loaded matches the NIRx acquisition layout as 
% this is assumed to be correct by this script.  This includes maintaining 
% the real-world NIRx source and detector numbers in the SD file, which may
% necessitate padding the SD file if consecutively numbered sources and
% detectors, starting from 1, were not used.

% This code was written and debugged using data from the NIRx NIRSCOUT, it
% may not be applicable to other models.

% Rob J Cooper, University College London, August 2013
% robert.cooper at ucl.ac.uk

%% Edited by Chi-Chuan Chen for NTNU-Haskins joint lab, June 2020
% (chichuan.chen46 at gmail.com)

% Removed the SD_filename input argument
% Added output dir argument to save all .nirs files in one place, naming
% the output file according to the input subj number (e.g., 2020-01-14_001)

% #########################################################################

% Select NIRx folder containing .wl1, .wl2 and .hr files
if ~exist('NIRx_foldername','var');
NIRx_foldername = uigetdir(pwd,'Select NIRx Data Folder...');
end

% Select output folder for .nirs files
if ~exist('out_dir','var');
out_dir = uigetdir(pwd,'Select output folder for .nirs files...');
end

% % Load SD_file
% if ~exist('SD_filename','var');
%     SD_filename = uigetfile('.SD','Select associated SD file...');
% end
% load(SD_filename,'-mat');

% Load wavelength d
% #######################################################################
wl1_dir = dir([NIRx_foldername filesep '*.wl1']);
if length(wl1_dir) == 0; error('ERROR: Cannot find NIRx .wl1 file in selected directory...'); end;
wl1     = load([NIRx_foldername filesep wl1_dir(1).name]);
wl2_dir = dir([NIRx_foldername filesep '*.wl2']);
if length(wl2_dir) == 0; error('ERROR: Cannot find NIRx .wl2 file in selected directory...'); end;
wl2     = load([NIRx_foldername filesep wl2_dir(1).name]);

d = [wl1 wl2]; % d matrix from .wl1 and .wl2 files

% Read and interpret .hdr d ############################################
% #########################################################################
hdr_dir = dir([NIRx_foldername filesep '*.hdr']);
if length(hdr_dir) == 0; error('ERROR: Cannot find NIRx header file in selected directory...'); end;
fid     = fopen([NIRx_foldername filesep hdr_dir(1).name]);
tmp     = textscan(fid,'%s','delimiter','\n');%This just reads every line
hdr_str = tmp{1};
fclose(fid);

%Find filename
keyword = 'FileName="NIRS-';
tmp     = strfind(hdr_str,keyword);
ind     = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
tmp     = hdr_str{ind};
NIRx_filename = tmp(length(keyword)+1:end-1);

%Find number of sources
keyword = 'Sources=';
tmp     = strfind(hdr_str,keyword);
ind     = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
tmp     = hdr_str{ind};
NIRx_Sources = str2num(tmp(length(keyword)+1:end));

%Find number of detectors
keyword = 'Detectors=';
tmp     = strfind(hdr_str,keyword);
ind     = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
tmp     = hdr_str{ind};
NIRx_Detectors = str2num(tmp(length(keyword)+1:end));
 
%% Find Source/Detector points - Per Jonathan Perry - Univ. of Houston/NIRx
probe_dir = dir([NIRx_foldername filesep '*_probeInfo.mat']);
load([NIRx_foldername filesep probe_dir(1).name]);

s_pts   = probeInfo.probes.coords_s2; %use for 2d coords
% s_pts = probeInfo.probes.coords_s3; %use for 3d coords

d_pts   = probeInfo.probes.coords_d2; %use for 2d coords
% d_pts = probeInfo.probes.coords_d3; %use for 3d coords

%%
% %Compare to SD file for checking...
% if NIRx_Sources ~= SD.nSrcs || NIRx_Detectors ~= SD.nDets;
%    error('The number or sources and detectors in the NIRx files does not match your SD file...');
% end

%Find Sample rate
keyword = 'SamplingRate=';
tmp     = strfind(hdr_str,keyword);
ind     = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
tmp     = hdr_str{ind};
fs      = str2num(tmp(length(keyword)+1:end));

%Find Active Source-Detector pairs (these will just be ordered by source,
%then detector (so, for example d(:,1) = source 1, det 1 and d(:,2) =
%source 1 det 2 etc.
keyword = 'S-D-Mask="#';
tmp     = strfind(hdr_str,keyword);
ind     = find(~cellfun(@isempty,tmp)) + 1; %This gives cell of hdr_str with keyword
tmp     = strfind(hdr_str(ind+1:end),'#');
ind2    = find(~cellfun(@isempty,tmp)) - 1;
ind2    = ind + ind2(1);

sd_ind            = cell2mat(cellfun(@str2num,hdr_str(ind:ind2),'UniformOutput',0));
[src det]         = find(sd_ind); 
MeasList          = [src, det];
MeasList(:,[3:4]) = ones(size(MeasList,1),2);

sd_ind   = sd_ind';
sd_ind   = find([sd_ind(:);sd_ind(:)]);
d        = d(:,sd_ind);

%% Find channels
% keyword  = 'S-D-Key="';
% tmp      = strfind(hdr_str,keyword);
% ind      = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
% chan_str = hdr_str(ind,1);
% chan_str = strrep(chan_str,keyword,'');
% chan_cel = strsplit(chan_str{1},',');
% channels = zeros(size(chan_cel,2),2);
% chan_sz  = size(chan_cel,2)-1;
% for i = 1:chan_sz-1
%     idx = strfind(chan_cel{i},':');
%     chan_cel{i}([idx:end]) = '';
%     chan_SD = strsplit(chan_cel{i},'-');
%     channels(i,1) = str2num(chan_SD{1});
%     channels(i,2) = str2num(chan_SD{2});
% end
% channels = channels(sd_ind,:)
%%
%Find Event Markers and build S vector
keyword = 'Events="#';
tmp = strfind(hdr_str,keyword);
ind = find(~cellfun(@isempty,tmp)) + 1; %This gives cell of hdr_str with keyword
tmp = strfind(hdr_str(ind+1:end),'#');
ind2 = find(~cellfun(@isempty,tmp)) - 1;
ind2 = ind + ind2(1);
events = cell2mat(cellfun(@str2num,hdr_str(ind:ind2),'UniformOutput',0));
events = events(:,2:3);
markertypes = unique(events(:,1));
s = zeros(length(d),length(markertypes));
for i = 1:length(markertypes);
    s(events(find(events(:,1)==markertypes(i)),2),i) = 1;
end

%Create t, aux varibles
aux = zeros(length(d),8);
t = 0:1/fs:length(d)/fs - 1/fs;

%% Create SD struct 
SD.SpatialUnit = 'mm';
SD.Lambda = [760;850];
SD.SrcPos = s_pts;
SD.DetPos = d_pts;
SD.nSrcs = NIRx_Sources;
SD.nDets = NIRx_Detectors;
MeasList2 = MeasList;
MeasList2(:,4) = 2;
SD.MeasList = [MeasList; MeasList2];

%% Compare to SD file for checking...
if NIRx_Sources ~= SD.nSrcs || NIRx_Detectors ~= SD.nDets;
   error('The number or sources and detectors in the NIRx files does not match your SD file...');
end


%outname = uiputfile('*.nirs','Save .nirs file ...');
outname=[out_dir filesep NIRx_filename '.nirs'];


fprintf('Saving as %s ...\n',outname);
save(outname,'d','s','t','aux','SD');
