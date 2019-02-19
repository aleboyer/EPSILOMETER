function EPSI_grid_turbulence(Meta_Data,MS)

if nargin==1
%     if exist(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'),'file')
%         load(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'))
%     else
        load(fullfile(Meta_Data.L1path,'Turbulence_Profiles.mat'),'MS')
%     end
end

MSempty=cellfun(@isempty,MS);
Map_pr=cellfun(@(x) (x.pr),MS(~MSempty),'un',0);
zaxis=min([Map_pr{:}]):.5:max([Map_pr{:}]);
Map_epsilon2=cellfun(@(x) interp1(x.pr,x.epsilon(:,2),zaxis),MS(~MSempty),'un',0);
Map_epsilon1=cellfun(@(x) interp1(x.pr,x.epsilon(:,1),zaxis),MS(~MSempty),'un',0);
Map_chi1=cellfun(@(x) interp1(x.pr,x.chi(:,1),zaxis),MS(~MSempty),'un',0);
Map_chi2=cellfun(@(x) interp1(x.pr,x.chi(:,2),zaxis),MS(~MSempty),'un',0);
Map_t=cellfun(@(x) interp1(x.pr,x.t,zaxis),MS(~MSempty),'un',0);
Map_s=cellfun(@(x) interp1(x.pr,x.s,zaxis),MS(~MSempty),'un',0);
Map_flag=cellfun(@(x) interp1(x.pr,double(x.flag),zaxis),MS(~MSempty),'un',0);


Map_time=cell2mat(cellfun(@(x) mean(x.time),MS(~MSempty),'un',0));

Z=numel(zaxis);

Map_epsilon1=cell2mat(Map_epsilon1.');
Map_epsilon2=cell2mat(Map_epsilon2.');
Map_chi1=cell2mat(Map_chi1.');
Map_chi2=cell2mat(Map_chi2.');
Map_t=cell2mat(Map_t.');
Map_s=cell2mat(Map_s.');
Map_flag(Map_flag<1)=NaN;

Map_sig=sw_dens(Map_s,Map_t,zaxis).';

level_sig=linspace(min(nanmean(Map_sig,2)),max(nanmean(Map_sig,2)),100);
for t=1:numel(Map_time)
    indnan=~isnan(Map_sig(:,t));
    eta(:,t)=interp1(Map_sig(indnan,t),zaxis(indnan),level_sig);
end
meta=floor(nanmean(eta,2)./2);
dmeta=diff(meta);
eta2=eta(dmeta>0,:);


save(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'), ...
    'Map_epsilon1','Map_epsilon2', ...
    'Map_chi1','Map_chi2', ...
    'Map_time','zaxis', ...
    'Map_sig','Map_t','Map_s','eta2','Map_flag')

close all

% epsilon 1 
figure;
colormap('parula')
pcolor(Map_time,zaxis,log10(real(Map_epsilon1.')));shading flat;axis ij
hold on
plot(Map_time,eta2,'k')
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
print(fullfile(Meta_Data.L1path,'EpsiMap1.png'),'-dpng2')

% epsilon 2
figure;
colormap('parula')
pcolor(Map_time,zaxis,log10(real(Map_epsilon2.')));shading flat;axis ij
hold on
plot(Map_time,eta2,'k')
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
print(fullfile(Meta_Data.L1path,'EpsiMap2.png'),'-dpng2')

% chi 1 
figure;
colormap('parula')
pcolor(Map_time,zaxis,log10(real(Map_chi1.*Map_flag).'));shading flat;axis ij
hold on
plot(Map_time,eta2,'k','linewidth',1)
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
print(fullfile(Meta_Data.L1path,'Epsichi1.png'),'-dpng2')

% epsilon 1 
figure;
colormap('parula')
pcolor(Map_time,zaxis,log10(real(Map_chi2.*Map_flag).'));shading flat;axis ij
hold on
plot(Map_time,eta2,'k','linewidth',2)
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
print(fullfile(Meta_Data.L1path,'Epsichi2.png'),'-dpng2')
