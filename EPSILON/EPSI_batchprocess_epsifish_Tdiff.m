function EPSI_batchprocess_epsifish(Meta_Data)

%  input: Meta_Data
%  created with Meta_Data=create_Meta_Data(file). Meta_Data contain the
%  path to calibration file and EPSI configuration needed to process the
%  epsi data
%
%  Created by Arnaud Le Boyer on 7/28/18.
%  Copyright © 2018 Arnaud Le Boyer. All rights reserved.




%% add the needed toobox  move that to create Meta file
%addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/scripts/mixing_library/mixing_library/private1/seawater


if ~exist([Meta_Data.L1path 'Turbulence_Profiles.mat'],'file')
    %% 	get data
    load([Meta_Data.L1path 'Profiles_' Meta_Data.deployment '.mat'],'CTDProfile','EpsiProfile');
    CTD_Profiles=CTDProfile.datadown;
    EPSI_Profiles=EpsiProfile.datadown;
    
    %% Parameters fixed by data structure
    % length of 1 scan in second
    tscan     =  3;
    % Hard cut off frequency to compute espilon. It should below any
    % pre-known vibration on the vehicle. For the epsifish the SBE water
    % pump is known to vibrate at 50Hz.
    Fcut_epsilon=45;  %45 Hz
    
    % sample rate channels
    FS        = str2double(Meta_Data.Firmware.sampling_frequency(1:3));        
    % number of samples per scan (1s) in channels
    df        = 1/tscan;
    
    f=(df:df:FS/2)'; % frequency vector for spectra
    MS = struct([]);
    
    %TODO interp on a regular time grid epsitime fluctuates.
    % this can be imporved with a better us clock in the firmware...
    % but it will always varies.  
    % add pressure from ctd to the epsi profile. This should be ter mporary until
    % the addition of the pressure sensor on Epsi
    dsp=1;
    for i=1:length(EPSI_Profiles)
%         epsitime=linspace(EPSI_Profiles{i}.epsitime(1),...
%             EPSI_Profiles{i}.epsitime(end),...
%             numel(EPSI_Profiles{i}.epsitime));
%         ctdtime=linspace(CTD_Profiles{i}.ctdtime(1),...
%             CTD_Profiles{i}.ctdtime(end),...
%             numel(CTD_Profiles{i}.ctdtime));
        EPSI_Profiles{i}.P=interp1(CTD_Profiles{i}.ctdtime,CTD_Profiles{i}.P,EPSI_Profiles{i}.epsitime);
        EPSI_Profiles{i}.P=filloutliers(EPSI_Profiles{i}.P,'center','movmedian',1000);

        EPSI_Profiles{i}.T=interp1(CTD_Profiles{i}.ctdtime,CTD_Profiles{i}.T,EPSI_Profiles{i}.epsitime);
        EPSI_Profiles{i}.S=interp1(CTD_Profiles{i}.ctdtime,CTD_Profiles{i}.S,EPSI_Profiles{i}.epsitime);
%        EPSI_Profiles{i}.epsitime=epsitime;
        MS{i}=calc_turbulence_epsifish(EPSI_Profiles{i},tscan,f,Fcut_epsilon,Meta_Data,dsp,i);
%         Quality_check_profile(EPSI_Profiles{i},MS(i),Meta_Data,Fcut_epsilon,flag_vehicle,i)
    end
    save([Meta_Data.L1path 'Turbulence_Profiles.mat'],'MS','-v7.3')
else
    load([Meta_Data.L1path 'Turbulence_Profiles.mat'],'MS')
end

% compite binned epsilon for all profiles
Epsilon_class=calc_binned_epsi(MS);
Chi_class=calc_binned_chi(MS);

% plot binned epsilon for all profiles
close all
F1=figure(1);F2=figure(2);
[F1,F2]=plot_binned_epsilon(Epsilon_class,[Meta_Data.mission '-' Meta_Data.deployment],F1,F2,Meta_Data);
F1.PaperPosition = [0 0 30 20];F2.PaperPosition = [0 0 30 20];
print(F1,[Meta_Data.L1path Meta_Data.deployment '_binned_epsilon1_t3s.png'],'-dpng2')
print(F2,[Meta_Data.L1path Meta_Data.deployment '_binned_epsilon2_t3s.png'],'-dpng2')

[F1,F2]=plot_binned_chi(Chi_class,Meta_Data,[Meta_Data.mission '-' Meta_Data.deployment]);
print(F1,[Meta_Data.L1path Meta_Data.deployment '_binned_chi22_c_t3s.png'],'-dpng2')
print(F2,[Meta_Data.L1path Meta_Data.deployment '_binned_chi21_c_t3s.png'],'-dpng2')

%% Chi plot
switch Meta_Data.MAP.temperature
    case 'Tdiff'
        FPO7noise=load([Meta_Data.CALIpath 'FPO7_noise.mat'],'n0','n1','n2','n3');
    otherwise
        FPO7noise=load([Meta_Data.CALIpath 'FPO7_notdiffnoise.mat'],'n0','n1','n2','n3');
end
dTdV(1)=Meta_Data.epsi.t1.dTdV; %1/0.025 V/deg 
dTdV(2)=Meta_Data.epsi.t2.dTdV; %1/0.025 V/deg 

f=1/3:1/3:320/2;
logf=log10(f);
w_th=.6;
h_freq=get_filters_MADRE(Meta_Data,f);
noise=(2*pi*f./w_th).^2.*10.^(FPO7noise.n0+FPO7noise.n1.*logf+ ...
           FPO7noise.n2.*logf.^2+...
           FPO7noise.n3.*logf.^3).*dTdV(1).^2./h_freq.FPO7(w_th).*w_th;

%i=1:10;j=2;
i=1:12;j=4;
close all;
l1=loglog(Chi_class.k,squeeze(Chi_class.Pbatch21(i,j,:)),'Color',.8*[1 1 1],'linewidth',2);
hold on;
l2=loglog(Chi_class.k,squeeze(Chi_class.mPphiT21(i,j,:)),'linewidth',2);
l3=loglog(f./w_th,3.*noise,'Color',[.2 .2 .2],'linewidth',2);
grid on
xlabel('k [cpm]')
ylabel('$(\phi^T_k)^2$  [ $(^{\circ}C . m^{-1})^2$ / cpm]','interpreter','latex')
set(gca,'fontsize',20)
legend([l1(1) l2(1) l3],{'batchelor','data','noise'},'location','best')
print([Meta_Data.L1path Meta_Data.deployment '_binned_chi_increpsi_t3s.png'],'-dpng2')

i=2;j=1:12;
close all;
loglog(Chi_class.k,squeeze(Chi_class.Pbatch21(i,j,:)),'Color',.8*[1 1 1],'linewidth',2)
hold on;
loglog(Chi_class.k,squeeze(Chi_class.mPphiT21(i,j,:)),'linewidth',2);
grid on
xlabel('k [cpm]')
ylabel('$(\phi^T_k)^2$  [ $(^{\circ}C . m^{-1})^2$ / cpm]','interpreter','latex')
set(gca,'fontsize',20)
print([Meta_Data.L1path Meta_Data.deployment '_binned_chi_incrchi_t3s.png'],'-dpng2')


MSempty=cellfun(@isempty,MS);
Map_pr=cellfun(@(x) (x.pr),MS(~MSempty),'un',0);
zaxis=min([Map_pr{:}]):.5:max([Map_pr{:}]);
Map_epsilon2=cellfun(@(x) interp1(x.pr,x.epsilon(:,2),zaxis),MS(~MSempty),'un',0);
Map_epsilon1=cellfun(@(x) interp1(x.pr,x.epsilon(:,1),zaxis),MS(~MSempty),'un',0);
Map_chi1=cellfun(@(x) interp1(x.pr,x.chi(:,1),zaxis),MS(~MSempty),'un',0);
Map_chi2=cellfun(@(x) interp1(x.pr,x.chi(:,2),zaxis),MS(~MSempty),'un',0);


Map_time=cell2mat(cellfun(@(x) mean(x.time),MS(~MSempty),'un',0));

Map_epsilon1=cell2mat(Map_epsilon1.');
Map_epsilon2=cell2mat(Map_epsilon2.');
Map_chi1=cell2mat(Map_chi1.');
Map_chi2=cell2mat(Map_chi2.');
save([Meta_Data.L1path  'Turbulence_grid.mat'],'Map_epsilon1','Map_epsilon2','Map_chi1','Map_chi2','Map_time','zaxis')

close all

% epsilon 1 
figure;
colormap('jet')
pcolor(Map_time,zaxis,log10(real(Map_epsilon1.')));shading flat;axis ij
colorbar
caxis([-10,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(Map_time(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon)','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(sprintf('%sEpsiMap1.png',Meta_Data.L1path),'-dpng2')

% epsilon 2
figure;
colormap('jet')
pcolor(Map_time,zaxis,log10(real(Map_epsilon2.')));shading flat;axis ij
colorbar
caxis([-10,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(Map_time(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon)','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(sprintf('%sEpsiMap2.png',Meta_Data.L1path),'-dpng2')

% chi 1 
figure;
colormap('jet')
pcolor(Map_time,zaxis,log10(real(Map_chi1.')));shading flat;axis ij
colorbar
caxis([-11,-7])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(Map_time(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\chi)','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(sprintf('%sEpsichi1.png',Meta_Data.L1path),'-dpng2')

% epsilon 1 
figure;
colormap('jet')
pcolor(Map_time,zaxis,log10(real(Map_chi2.')));shading flat;axis ij
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(Map_time(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\chi)','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(sprintf('%sEpsichi2.png',Meta_Data.L1path),'-dpng2')





