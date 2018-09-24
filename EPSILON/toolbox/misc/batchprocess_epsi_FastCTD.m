%% 
if exist('/Volumes/aleboyer/ARNAUD/SCRIPPS/PLUMEX18/','dir')
    root_data='/Volumes/aleboyer/ARNAUD/SCRIPPS/PLUMEX18/';
    root_script='/Volumes/aleboyer/ARNAUD/SCRIPPS/EPSILON/';
else
    root_data='/Users/aleboyer/ARNAUD/SCRIPPS/';
    root_script='/Users/aleboyer/ARNAUD/SCRIPPS/EPSILON/';
end


Cruise_name='NISKINE'; % 
WW_name='EPSIfish2W'; % 
deployement='d3';

%% add the needed toobox 
%addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/scripts/mixing_library/mixing_library/private1/seawater
addpath toolbox/
addpath toolbox/CTD
addpath toolbox/FILTER
addpath toolbox/process
addpath toolbox/seawater2/
addpath toolbox/PLOTS/


%% define path
WWpath=sprintf('%s/%s/%s/%s/L1/',root_data,Cruise_name,WW_name,deployement);
epsipath=sprintf('%s/%s/%s/%s/epsi/',root_data,Cruise_name,WW_name,deployement);
name_ctd=[WW_name '_ctd_' deployement];

%% 	get data 
load([ WWpath '/Profiles_' name_ctd],'EpsiProfile','CTDProfile')
CTD_Profiles=CTDProfile.datadown;
EPSI_Profiles=EpsiProfile.datadown;

%% Parameters fixed by data structure 
tscan     =  3;                                                            % length of 1 scan in second
%FS        = round(1./nanmean(diff(Profiles{1}.time)));                     % sample rate channels
FS        = 325;                     % sample rate channels
df        = 1/tscan;                                                       % number of samples per scan (1s) in channels
% shear 103,104 = s2,s1
Sv        = [53.99,8.16]; % TODO get Sv directly from the database
q=3.2;

f=(df:df:FS/2)'; % frequency vector for spectra
Epsilon = struct([]);
chi     = struct([]);
timeaxis=zeros(1,length(EPSI_Profiles));

% add pressure from ctd to the epsi profile. This should be ter mporary until
% the addition of the pressure sensor on Epsi
%for i=[1:22 24:length(EPSI_Profiles)]
for i=[1:22 24:length(EPSI_Profiles)]
    %TODO correct the double(Sensor5) earlier in the process
    [ctdtime,IA,IB]=unique(CTD_Profiles{i}.time);
    P=CTD_Profiles{i}.P(IA);
    S=CTD_Profiles{i}.S(IA);
    T=CTD_Profiles{i}.T(IA);
    EPSI_Profiles{i}.P=interp1(ctdtime,P,EPSI_Profiles{i}.time);
    EPSI_Profiles{i}.T=interp1(ctdtime,T,EPSI_Profiles{i}.time);
    EPSI_Profiles{i}.S=interp1(ctdtime,S,EPSI_Profiles{i}.time);
    MS{i}=calc_turbulence_epsi_FastCTD(EPSI_Profiles{i},tscan,f,Sv);
    %Epsilon{i}.timeaxis=nanmean(Profiles{i}.rbrtime);
end
save([WWpath 'Turbulence_Profiles.mat'],'MS','EPSI_Profiles')

load([WWpath 'Turbulence_Profiles.mat'],'MS','EPSI_Profiles')
Epsilon_class=calc_binned_epsi(MS([1:22 24:end]));
Chi_class=calc_binned_chi(MS([1:22 24:end]));

[F1,F2]=plot_binned_epsilon(Epsilon_class,'NISKINE');
print(F1,[WWpath deployement '_binned_epsilon1_t3s.png'],'-dpng2')
print(F2,[WWpath deployement '_binned_epsilon2_t3s.png'],'-dpng2')

[F1,F2]=plot_binned_chi(Chi_class,'NISKINE',1:40);
print(F1,[WWpath deployement '_binned_chi22_c_t3s.png'],'-dpng2')
print(F2,[WWpath deployement '_binned_chi21_c_t3s.png'],'-dpng2')


i=3;j=10;
for j=100:150
    figure
    [ktest1,Ptest1]=batchelor(Epsilon{i}.epsilon1(j),chi{i}.chi2(j),...
                            Epsilon{i}.kvis{j},chi{i}.ktemp{j},...
        q);
    [ktest2,Ptest2]=batchelor(Epsilon{i}.epsilon2(j),chi{i}.chi2(j),...
                            Epsilon{i}.kvis{j},chi{i}.ktemp{j},...
        q);
    
    loglog(Epsilon{i}.k{j},Epsilon{i}.Pshear1{j},'b')
    hold on
    loglog(Epsilon{i}.k{j},Epsilon{i}.Pshear2{j},'g')
    loglog(chi{i}.k{j},chi{i}.Ptgradk2{j},'r')
    loglog(Epsilon{i}.kpan1{j},Epsilon{i}.Ppan1{j},'m')
    loglog(Epsilon{i}.kpan2{j},Epsilon{i}.Ppan2{j},'c')
    loglog(ktest1,Ptest1,'ko-')
    loglog(ktest2,Ptest2,'kd-')
    hold off
    legend('u1_z','u2_z','\phi_{TG}','Panchev1','Panchev2','Batchelor1','Batchelor2','location','northwest')
    title(['Profile ' int2str(i) ' Scan=' int2str(j) ', pr=' ...
        num2str(Epsilon{i}.pr(j)) 'm']);
    text(3e2,1e-7,['\epsilon' sprintf('=%1.3e',Epsilon{i}.epsilon1(j))]);
    text(3e2,1e-6,[ '\chi' sprintf('=%1.3e',chi{i}.chi1(j))]);
    xlabel('k (cpm)','fontsize',15)
    ylabel('\phi(k)','fontsize',15)
    set(gca,'fontsize',15)
    fig=gcf;
    fig.PaperPosition = [0 0 8 8];
    %print('-dpng',sprintf('../FIGURE/EPSI_SPROUL/P%i_Uz_PHItg_Panch_Batch_%i.png',i,j))
    %close all

end
            
return
MSempty=cellfun(@isempty,MS);
Map_pr=cellfun(@(x) (x.pr),MS(~MSempty),'un',0);
zaxis=min([Map_pr{:}]):.5:max([Map_pr{:}]);
Map_epsilon=cellfun(@(x) interp1(x.pr,x.epsilon(:,1),zaxis),MS(~MSempty),'un',0);
Map_time=cell2mat(cellfun(@(x) mean(x.time),MS(~MSempty),'un',0));

Map_epsilon=cell2mat(Map_epsilon.');
%CTDgrid.Epsilon=interp1(zaxis,Map_epsilon.',CTDgrid.z);
save([WWpath WW_name '_grid.mat'],'CTDgrid')


level=min(RBRgrid.rho(:)):.01:max(RBRgrid.rho(:));
L=length(level);

close all
figure;
colormap('jet')
pcolor(Map_time,zaxis,log10(real(Map_epsilon.')));shading flat;axis ij
colorbar
caxis([-9.5 -7.5])
hold on
contour(RBRgrid.time,RBRgrid.z,RBRgrid.rho,[level(1:5:L-200) level(L-200:L)],'k')
hold off
caxis([-9,-6])
set(gca,'XTickLabelRotation',45)
set(gca,'XTick',RBRgrid.time(1:5:end))
datetick
%xlim([RBRgrid.time(1) RBRgrid.time(110)])
cax=colorbar;
xlabel(['Start date :' datestr(RBRgrid.time(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon)','fontsize',20)
ylabel('Depth (m)','fontsize',20)
%xlim([RBRgrid.time(1) RBRgrid.time(end)])
ylim([2 48])

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(sprintf('../FIGURE/EPSILON/%s_EpsiMap1.png',name_rbr),'-dpng2')


close all
figure;
colormap('jet')
pcolor(RBRgrid.time,RBRgrid.z,log10(RBRgrid.Epsilon));shading interp;axis ij
hold on
contour(RBRgrid.time,RBRgrid.z,RBRgrid.rho,[level(1:5:L-200) level(L-200:L)],'k')
hold off
caxis([-9,-6])
set(gca,'XTickLabelRotation',45)
set(gca,'XTick',RBRgrid.time(1:5:end))
datetick
xlim([RBRgrid.time(280) RBRgrid.time(370)])
cax=colorbar;
xlabel(['Start date :' datestr(RBRgrid.time(280),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon)','fontsize',20)
ylabel('Depth (m)','fontsize',20)
%xlim([RBRgrid.time(1) RBRgrid.time(end)])
ylim([2 48])

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(sprintf('../FIGURE/EPSILON/%s_EpsiMap2.png',name_rbr),'-dpng2')



%% plot chi
Map_pr=cellfun(@(x) (x.pr),chi,'un',0);
zaxis=min([Map_pr{:}]):.5:max([Map_pr{:}]);
Map_chi=cellfun(@(x) interp1(x.pr,x.chi,zaxis),chi,'un',0);
Map_chi=cell2mat(Map_chi.');
RBRgrid.chi=interp1(zaxis,Map_chi.',RBRgrid.z);
%save([WWpath WW_name '_grid.mat'],'RBRgrid')


level=min(RBRgrid.rho(:)):.01:max(RBRgrid.rho(:));
L=length(level);

close all
figure;
colormap('jet')
pcolor(RBRgrid.time,RBRgrid.z,log10(-RBRgrid.chi));shading interp;axis ij
hold on
contour(RBRgrid.time,RBRgrid.z,RBRgrid.rho,[level(1:5:L-200) level(L-200:L)],'k')
hold off
caxis([-18,-8])
set(gca,'XTickLabelRotation',45)
set(gca,'XTick',RBRgrid.time(1:5:end))
datetick
%xlim([RBRgrid.time(1) RBRgrid.time(110)])
cax=colorbar;
xlabel(['Start date :' datestr(RBRgrid.time(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(-\chi)','fontsize',20)
ylabel('Depth (m)','fontsize',20)
%xlim([RBRgrid.time(1) RBRgrid.time(end)])
ylim([2 48])

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(sprintf('../FIGURE/CHI/%s_chiMap1.png',name_rbr),'-dpng2')


close all
figure;
colormap('jet')
pcolor(RBRgrid.time,RBRgrid.z,log10(-RBRgrid.chi));shading interp;axis ij
hold on
contour(RBRgrid.time,RBRgrid.z,RBRgrid.rho,[level(1:5:L-200) level(L-200:L)],'k')
hold off
caxis([-18,-6])
set(gca,'XTickLabelRotation',45)
set(gca,'XTick',RBRgrid.time(1:5:end))
datetick
xlim([RBRgrid.time(280) RBRgrid.time(370)])
cax=colorbar;
xlabel(['Start date :' datestr(RBRgrid.time(280),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\chi)','fontsize',20)
ylabel('Depth (m)','fontsize',20)
%xlim([RBRgrid.time(1) RBRgrid.time(end)])
ylim([2 48])

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(sprintf('../FIGURE/CHI/%s_EpsiMap2.png',name_rbr),'-dpng2')








