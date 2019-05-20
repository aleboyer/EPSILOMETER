function mod_create_epsi_profiles(Meta_Data)
%function mod_create_epsi_profiles(Meta_Data)
% July 2018 ALB
%  split times series into profiles
%
%  input:
% . Meta_Data
%  created with Meta_Data=create_Meta_Data(file). Meta_Data contain the
%  path to calibration file and EPSI configuration needed to process the
%  epsi data
%   
%  we filt the pressure with low pass at 1min. then look for the period
%  Created by Arnaud Le Boyer on 03/28/19.

% if crit_speed and crit filt are not inputs

% load CTD and EPSI data

load(fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']),'CTDProfiles');
EPSI=load(fullfile(Meta_Data.Epsipath,['epsi_' Meta_Data.deployment '.mat']));


[EpsiProfiles.up,EpsiProfiles.down,EpsiProfiles.dataup,EpsiProfiles.datadown] =...
          mod_getcastepsi(EPSI,CTDProfiles.dataup,CTDProfiles.datadown);
        
filepath=fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']);
fprintf('Saving data in %s \n',filepath)
save(filepath,'CTDProfiles','EpsiProfiles','-v7.3');
        
end



