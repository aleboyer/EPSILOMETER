function EPSI_create_profiles(Meta_Data)

%  split times series into profiles
%
%  input: Meta_Data
%  created with Meta_Data=create_Meta_Data(file). Meta_Data contain the
%  path to calibration file and EPSI configuration needed to process the
%  epsi data
%
%  Created by Arnaud Le Boyer on 7/28/18.


CTDpath=Meta_Data.CTDpath;
Epsipath=Meta_Data.Epsipath;
L1path=Meta_Data.L1path;

CTD=load([CTDpath 'ctd_' Meta_Data.deployment '.mat'],'aux1time','T','P','S','sig');
EPSI=load([Epsipath 'epsi_' Meta_Data.deployment '.mat']);
CTD.ctdtime=CTD.aux1time;

[CTDProfile.up,CTDProfile.down,CTDProfile.dataup,CTDProfile.datadown] = ...
                                               EPSI_getcastctd(CTD,.3);
close all
plot(CTD.ctdtime,CTD.P)
hold on
for i=1:length(CTDProfile.up)
       plot(CTDProfile.dataup{i}.ctdtime,CTDProfile.dataup{i}.P,'r')
end
for i=1:length(CTDProfile.down)
       plot(CTDProfile.datadown{i}.ctdtime,CTDProfile.datadown{i}.P,'g')
end
print('-dpng2',[Meta_Data.CTDpath 'Profiles_Pr.png'])
close all



[EpsiProfile.up,EpsiProfile.down,EpsiProfile.dataup,EpsiProfile.datadown] =...
                                                     EPSI_getcastepsi(EPSI,CTD.ctdtime,CTDProfile.up,CTDProfile.down);

                                                 
fprintf('Saving data in %sProfiles_%s.mat\n',L1path,Meta_Data.deployment)

save([L1path 'Profiles_' Meta_Data.deployment '.mat'],'CTDProfile','EpsiProfile','-v7.3');



