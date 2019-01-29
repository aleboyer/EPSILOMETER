function EPSI_create_profiles(Meta_Data,crit_speed,crit_filt)

%  split times series into profiles
%
%  input: Meta_Data
%  created with Meta_Data=create_Meta_Data(file). Meta_Data contain the
%  path to calibration file and EPSI configuration needed to process the
%  epsi data
%
%  Created by Arnaud Le Boyer on 7/28/18.

if nargin==1
    crit_speed=.3;
    crit_filt=200;
end
    
L1path=Meta_Data.L1path;

CTD=load(fullfile(Meta_Data.CTDpath,['ctd_' Meta_Data.deployment '.mat']),'aux1time','T','P','S','sig');
EPSI=load(fullfile(Meta_Data.Epsipath,['epsi_' Meta_Data.deployment '.mat']));

indOK=~isnan(CTD.aux1time);
CTD=structfun(@(x) x(indOK),CTD,'un',0);
CTD.ctdtime=CTD.aux1time;

[CTDProfile.up,CTDProfile.down,CTDProfile.dataup,CTDProfile.datadown] = ...
                                               EPSI_getcastctd(CTD,crit_speed,crit_filt);

indPup=find(cellfun(@(x) x.P(1)-x.P(end),CTDProfile.dataup)>10);
indPdown=find(cellfun(@(x) x.P(end)-x.P(1),CTDProfile.datadown)>10);

CTDProfile.datadown=CTDProfile.datadown(indPdown);
CTDProfile.dataup=CTDProfile.dataup(indPup);
CTDProfile.down=CTDProfile.down(indPdown);
CTDProfile.up=CTDProfile.up(indPup);

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


answer1=input('save? (yes,no)','s');

switch answer1
    case 'yes'
        [EpsiProfile.up,EpsiProfile.down,EpsiProfile.dataup,EpsiProfile.datadown] =...
            EPSI_getcastepsi(EPSI,CTD.ctdtime,CTDProfile.up,CTDProfile.down);
        
        filepath=fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']);
        fprintf('Saving data in %s \n',filepath)
        save(filepath,'CTDProfile','EpsiProfile','-v7.3');
        
end




