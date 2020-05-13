function mod_epsilometer_batch_process(Meta_Data)

% mod_epsilometer_batch_process loads the CTD and EFE profiles and run
% mod_epsilometer_turbulence.Depending on the vehicle (Fish /WW)
% it selects the down or up cast.
%
% output: no output
% input:  Meta_Data 
% Meta_Data contains all the informations required to process epsilon and
% chi (e.g., Path to data ,path to library, length in second of the scans,
% the number and the names of the EFE channels, CTD and EFE sampling 
% frequency). Beside the path, a default Meta_Data can be generated with 
% mod_epsilometer_create_Meta_Data.m 
% 
%  Created by Arnaud Le Boyer on 7/28/18.
%  Copyright © 2018 Arnaud Le Boyer. All rights reserved.


%%
% download EPSI and CTD profile
try
    load(fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']),'CTDProfiles','EpsiProfiles');
catch
    load(fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']),'CTDProfile','EpsiProfile');
    CTDProfiles=CTDProfile;
    EpsiProfiles=EpsiProfile;
end
switch Meta_Data.vehicle
    case 'FISH'
        CTD_Profiles=CTDProfiles.datadown;
        EPSI_Profiles=EpsiProfiles.datadown;
    case 'WW'
        CTD_Profiles=CTDProfiles.dataup;
        EPSI_Profiles=EpsiProfiles.dataup;
end
%% Parameters fixed by data structure
% length of 1 scan in second
tscan     =  Meta_Data.PROCESS.tscan;
Fs_epsi   =  Meta_Data.PROCESS.Fs_epsi;
dz        =  Meta_Data.PROCESS.dz; 


% add pressure from ctd to the epsi profile. This should be ter mporary until
% the addition of the pressure sensor on Epsi
count=0;
L=tscan*Fs_epsi;
sav_var_name=[];
nb_profile_perfile=0;

[~,fe] = pwelch(0*(1:Meta_Data.PROCESS.nfft),...
                Meta_Data.PROCESS.nfft,[], ...
                Meta_Data.PROCESS.nfft, ...
                Meta_Data.PROCESS.Fs_epsi,'psd');
            
Meta_Data.PROCESS.h_freq=get_filters_MADRE(Meta_Data,fe);

% get FPO7 channel average noise to compute chi
switch Meta_Data.MAP.temperature
    case 'Tdiff'
        Meta_Data.PROCESS.FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_noise.mat'),'n0','n1','n2','n3');
    otherwise
        Meta_Data.PROCESS.FPO7noise=load(fullfile(Meta_Data.CALIpath,'FPO7_notdiffnoise.mat'),'n0','n1','n2','n3');
end

for i=1:length(EPSI_Profiles)
        fprintf('Profile %i over %i\n',i,length(EPSI_Profiles));
        
        % some cleaning on the Pressure channel
        % w=dPdt needs to be smooth.
        CTD_Profiles{i}.P=filloutliers(CTD_Profiles{i}.P,'center','movmedian',1000);

        CTD_Profiles{i}=structfun(@(x) fillmissing(x,'linear'),CTD_Profiles{i},'Un',0);
        EPSI_Profiles{i}=structfun(@(x) fillmissing(double(x),'linear'),EPSI_Profiles{i},'Un',0);
        
        %in case there is a mismatch between ctd and epsi time which still
        %happens as of April 17th 2020.
        EPSI_Profiles{i}.epsitime=EPSI_Profiles{i}.epsitime+ ...
                 (CTD_Profiles{i}.ctdtime(1)-EPSI_Profiles{i}.epsitime(1));
        
        Profile=mod_epsilometer_calc_turbulence(CTD_Profiles{i}, ...
                                                EPSI_Profiles{i}, ...
                                                dz,Meta_Data);
        eval(sprintf('Profile%03i=Profile;',i))
        clear Profile;
        sav_var_name=[sav_var_name sprintf(',''Profile%03i''',i)];
        nb_profile_perfile=nb_profile_perfile+1;% so I know how many profiles per file.
    if (mod(i,10)==0)
        save_file=fullfile(Meta_Data.L1path, ...
            ['Turbulence_Profiles' num2str(count) '.mat']);
        cmd=['save(''' save_file '''' sav_var_name ',''nb_profile_perfile'')'];
        eval(cmd);
        
        count=count+10;
        nb_profile_perfile=0;
        sav_var_name=[];
    end
end
%   save the last profiles if mod(length(EPSI_Profile),10)~=0
if ~isempty(sav_var_name)
        save_file=fullfile(Meta_Data.L1path, ...
            ['Turbulence_Profiles' num2str(count) '.mat']);
        cmd=['save(''' save_file '''' sav_var_name ',''nb_profile_perfile'')'];
        eval(cmd);
end






