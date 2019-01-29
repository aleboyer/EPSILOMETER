function EPSI_grid_turbulence(Meta_Data)

load(fullfile(Meta_Data.L1path,'Turbulence_Profiles.mat'),'MS')

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
save(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'),'Map_epsilon1','Map_epsilon2','Map_chi1','Map_chi2','Map_time','zaxis')

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
print(fullfile(Meta_Data.L1path,'EpsiMap1.png'),'-dpng2')

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
print(fullfile(Meta_Data.L1path,'EpsiMap2.png'),'-dpng2')

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
print(fullfile(Meta_Data.L1path,'Epsichi1.png'),'-dpng2')

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
print(fullfile(Meta_Data.L1path,'Epsichi2.png'),'-dpng2')
