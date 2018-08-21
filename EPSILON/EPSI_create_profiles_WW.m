function EPSI_create_profiles_WW(Meta_Data,ctdfile)

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



load(fullfile(Epsipath,['epsi_' Meta_Data.deployement]))
%%
ft1=smoothdata(t1,'movmean',60*320); % smooth about a minute
dft1=diff(ft1);
Ldft1=length(dft1);
%dft1 < 0 downcast, dtf1 > upcast

indup= find(dft1>3e-7);
split_indup=find(diff(indup)>1000);
EpsiProfile.up=arrayfun(@(x,y) indup(x+1:y),split_indup(1:end-1),split_indup(2:end),'un',0);
Lcellindup=cellfun(@length,EpsiProfile.up);
indup=find(Lcellindup>= .4*nanmedian(Lcellindup));
EpsiProfile.up = EpsiProfile.up(indup);


inddown= find(dft1<-3e-7);
split_inddown=find(diff(inddown)>1000);
EpsiProfile.down=arrayfun(@(x,y) inddown(x+1:y),split_inddown(1:end-1),split_inddown(2:end),'un',0);
Lcellinddown=cellfun(@length,EpsiProfile.down);
inddown=find(Lcellinddown>= .4*nanmedian(Lcellinddown));
EpsiProfile.down = EpsiProfile.down(inddown);

for i=1:length(EpsiProfile.up)
EpsiProfile.dataup{i}.epsitime=epsitime(EpsiProfile.up{i});
EpsiProfile.dataup{i}.t1=t1(EpsiProfile.up{i});
EpsiProfile.dataup{i}.t2=t2(EpsiProfile.up{i});
EpsiProfile.dataup{i}.s1=s1(EpsiProfile.up{i});
EpsiProfile.dataup{i}.s2=s2(EpsiProfile.up{i});
EpsiProfile.dataup{i}.a1=a1(EpsiProfile.up{i});
EpsiProfile.dataup{i}.a2=a2(EpsiProfile.up{i});
EpsiProfile.dataup{i}.a3=a3(EpsiProfile.up{i});    
end

for i=1:length(EpsiProfile.down)
EpsiProfile.datadown{i}.epsitime=epsitime(EpsiProfile.down{i});
EpsiProfile.datadown{i}.t1=t1(EpsiProfile.down{i});
EpsiProfile.datadown{i}.t2=t2(EpsiProfile.down{i});
EpsiProfile.datadown{i}.s1=s1(EpsiProfile.down{i});
EpsiProfile.datadown{i}.s2=s2(EpsiProfile.down{i});
EpsiProfile.datadown{i}.a1=a1(EpsiProfile.down{i});
EpsiProfile.datadown{i}.a2=a2(EpsiProfile.down{i});
EpsiProfile.datadown{i}.a3=a3(EpsiProfile.down{i});    
end

%%

WWctd=load([CTDpath ctdfile]);

CTD.P=WWctd.(ctdfile(1:end-4)).P;
CTD.T=WWctd.(ctdfile(1:end-4)).T;
CTD.S=WWctd.(ctdfile(1:end-4)).S;
CTD.sig=WWctd.(ctdfile(1:end-4)).sig;
CTD.ctdtime=WWctd.(ctdfile(1:end-4)).time;

[CTDProfile.up,CTDProfile.down,CTDProfile.dataup,CTDProfile.datadown] = ...
                                               EPSI_getcastctd(CTD,20);
                                           

%% 
close all
i1=190
ax(1)=subplot(211);
plot(t1)
hold on
plot(EpsiProfile.up{i1},EpsiProfile.dataup{i1}.t1,'r','linewidth',2)

i2=190
ax(2)=subplot(212);
plot(CTD.ctdtime(1:length(CTD.T)/10),CTD.T(1:length(CTD.T)/10))
hold on
plot(CTDProfile.dataup{i2}.ctdtime,CTDProfile.dataup{i2}.T,'r','linewidth',2)
         
%%


fprintf('Saving data in %sProfiles_%s.mat\n',L1path,Meta_Data.deployement)

save([L1path 'Profiles_' Meta_Data.deployement '.mat'],'CTDProfile','EpsiProfile','-v7.3');



