%% Hi kerstin
% save this routine somewhere Kerstin_path
% run :
% addpath Kerstin_path (this will add the path toward these routine in your matlab environment)
% 
% go in the L1 folder you want to work on
% add
% cd /Volumes/GoogleDrive/Shared drives/MOD-data-Epsilometer/epsi/NISKINE/Cruises/PILOT2018/data/epsi/epsifish1/d1/L1/
% then run the following lines

load('Meta_data.mat')
Meta_Data.L1path='';

%% correct coherence
listfile=dir('Turbulence_Profiles*.mat');
listfilename=natsort({listfile.name});
count=0;
for f=1:length(listfile)
    clear MS
    load(fullfile(listfile(f).folder,listfilename{f}),'MS')
    fprintf(fullfile(listfile(1).folder,listfilename{f}))
    for i=1:length(MS)
        count=count+1;
        fprintf('Profile %u over %u\n',i,length(MS))
        MS1{count}=MS{i};
    end
end

%% create Turbulence grid
EPSI_grid_turbulence(Meta_Data,MS)