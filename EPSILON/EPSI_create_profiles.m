function EPSI_create_profiles(Meta_Data,min_depth,crit_depth)
%function EPSI_create_profiles(Meta_Data,crit_speed,crit_filt)
% July 2018 ALB
%  split times series into profiles
%
%  input:
% . Meta_Data
%  created with Meta_Data=create_Meta_Data(file). Meta_Data contain the
%  path to calibration file and EPSI configuration needed to process the
%  epsi data
%   
% . crit_speed: speed criterium to to define starts and ends of a cast
% . crit_filt: number in sample for filter the fall rate (dP/dt) time serie
%  this use to filter out the small fluctuation in the fall rate. 
%  It should be changed when the deployment is not regular.  
%  crit speed and crit_filt are used in EPSI_getcastCTD.

%  Created by Arnaud Le Boyer on 7/28/18.

%
if nargin==1
    min_depth=3;
    crit_depth=10;
end

% load CTD and EPSI data
if exist(fullfile(Meta_Data.CTDpath,['ctd_' Meta_Data.deployment '.mat']),'file')
%     CTD=load(fullfile(Meta_Data.CTDpath,['ctd_' Meta_Data.deployment '.mat']),['ctd_' Meta_Data.deployment]'aux1time','T','P','S','sig');
    CTD=load(fullfile(Meta_Data.CTDpath,['ctd_' Meta_Data.deployment '.mat']),['ctd_' Meta_Data.deployment]);
    CTD=CTD.(['ctd_' Meta_Data.deployment]);
    % remove nans from the raw CTD data
    indOK=~isnan(CTD.aux1time);
    CTD=structfun(@(x) x(indOK),CTD,'un',0);
    CTD.ctdtime=CTD.aux1time;
    
    % define casts using CTD data
    [CTDProfiles.up,CTDProfiles.down,CTDProfiles.dataup,CTDProfiles.datadown] = ...
        mod_getcastctd(Meta_Data,min_depth,crit_depth);
else
    CTD=load(fullfile(Meta_Data.CTDpath,Meta_Data.name_ctd),Meta_Data.name_ctd);
    CTD=CTD.(Meta_Data.name_ctd);
    load(fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']),'CTDProfiles')
end
EPSI=load(fullfile(Meta_Data.Epsipath,['epsi_' Meta_Data.deployment '.mat']));



% plot pressure and highlight up /down casts in red/green
close all
plot(CTD.ctdtime,CTD.P)
hold on
for i=1:length(CTDProfiles.up)
       plot(CTDProfiles.dataup{i}.ctdtime,CTDProfiles.dataup{i}.P,'r')
end
for i=1:length(CTDProfiles.down)
       plot(CTDProfiles.datadown{i}.ctdtime,CTDProfiles.datadown{i}.P,'g')
end

%MHA: plot ocean style
axis ij

print('-dpng2',[Meta_Data.CTDpath 'Profiles_Pr.png'])


% do we wnat to save or change the speed and filter criteria
answer1=input('save? (yes,no)','s');

%save
switch answer1
    case 'yes'
        [EpsiProfiles.up,EpsiProfiles.down,EpsiProfiles.dataup,EpsiProfiles.datadown] =...
            EPSI_getcastepsi(EPSI,CTD.ctdtime,CTDProfiles.up,CTDProfiles.down);
        
        filepath=fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']);
        fprintf('Saving data in %s \n',filepath)
        save(filepath,'CTDProfiles','EpsiProfiles','-v7.3');
        
        Meta_Data.nbprofileup=numel(CTDProfiles.up);
        Meta_Data.nbprofiledown=numel(CTDProfiles.down);
        Meta_Data.maxdepth=max(cellfun(@(x) max(x.P),CTDProfiles.dataup));
        save(fullfile(Meta_Data.L1path,'Meta_Data.mat'),'Meta_Data')
end




