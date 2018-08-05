function EPSI_create_profiles(Meta_Data)

%  input: Meta_Data
%  created with Meta_Data=create_Meta_Data(file). Meta_Data contain the
%  path to calibration file and EPSI configuration needed to process the
%  epsi data
%
%  Created by Arnaud Le Boyer on 7/28/18.


CTDpath=Meta_Data.CTDpath;
Epsipath=Meta_Data.Epsipath;
L1path=Meta_Data.L1path;

CTD=load([CTDpath 'ctd_' Meta_Data.deployement '.mat'],'ctdtime','T','P','S','sig');
EPSI=load([Epsipath 'epsi_' Meta_Data.deployement '.mat']);


[CTDProfile.up,CTDProfile.down,CTDProfile.dataup,CTDProfile.datadown] = ...
                                               EPSI_getcastctd(CTD,20);
                                           
[EpsiProfile.up,EpsiProfile.down,EpsiProfile.dataup,EpsiProfile.datadown] =...
                                                     EPSI_getcastepsi(EPSI,CTD.ctdtime,CTDProfile.up,CTDProfile.down);

                                                 
fprintf('Saving data in %sProfiles_%s.mat\n',L1path,Meta_Data.deployement)

save([L1path 'Profiles_' Meta_Data.deployement '.mat'],'CTDProfile','EpsiProfile','-v7.3');



