function EPSI_plot_grid_turbulence(Meta_Data)

load(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'), ...
    'epsilon1','epsilon2', ...
    'epsilon1_co','epsilon2_co', ...
    'chi1','chi2', ...
    'dnum','z', ...
    't','s','w','eta2m','Meta_Data','epsi_chi1','epsi_chi2')

close all

% epsilon 1 
fontsize=20;
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsilon1)));shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',25)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',fontsize)
set(gca,'fontsize',fontsize)
ylabel(cax,'log_{10}(\epsilon)','fontsize',fontsize)
ylabel('Depth (m)','fontsize',fontsize)

fig=gcf;
fig.PaperPosition = [0 0 12 8];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Epsi1_map.png'),'-dpng2')

% epsilon 2
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsilon2)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k')
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon)','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Epsi2_Map.png'),'-dpng2')

% epsilon coherence 1 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsilon1_co)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k')
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon_{co})','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'EpsiMap1_co.png'),'-dpng2')

% epsilon co 2
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsilon2_co)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k')
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon_{co})','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'EpsiMap2_co.png'),'-dpng2')

% chi 1 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(chi1)));shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([-8,-2])
set(gca,'XTickLabelRotation',25)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',fontsize)
ylabel(cax,'log_{10}(\chi)','fontsize',fontsize)
ylabel('Depth (m)','fontsize',fontsize)

fig=gcf;
fig.PaperPosition = [0 0 12 8];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Chi1_map.png'),'-dpng2')

%chi2 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(chi2)));shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([-8,-2])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\chi)','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Chi2_map.png'),'-dpng2')

%epsilon from chi1 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsi_chi1)));shading flat;axis ij
%pcolor(dnum,z,log10(real(epsi_chi1)));shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',25)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',fontsize)
set(gca,'fontsize',fontsize)
ylabel(cax,'log_{10}(\epsilon_{\chi_1})','fontsize',fontsize)
ylabel('Depth (m)','fontsize',fontsize)

fig=gcf;
fig.PaperPosition = [0 0 14 9];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Epsichi1_map.png'),'-dpng2')

%epsilon from chi2 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsi_chi2)));shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon_{\chi_2})','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Epsichi2_map.png'),'-dpng2')


% t 
fontsize=20;
figure;
colormap('parula')
pcolor(dnum,z,t);shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([15,32])
set(gca,'XTickLabelRotation',25)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',fontsize)
set(gca,'fontsize',fontsize)
ylabel(cax,'Celsius','fontsize',fontsize)
ylabel('Depth (m)','fontsize',fontsize)
print(fullfile(Meta_Data.L1path,'t_map.png'),'-dpng2')


% s
fontsize=20;
figure;
colormap('parula')
pcolor(dnum,z,s);shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
% caxis()
set(gca,'XTickLabelRotation',25)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',fontsize)
set(gca,'fontsize',fontsize)
ylabel(cax,'psu','fontsize',fontsize)
ylabel('Depth (m)','fontsize',fontsize)
print(fullfile(Meta_Data.L1path,'s_map.png'),'-dpng2')


% w
fontsize=20;
figure;
colormap('parula')
pcolor(dnum,z,w);shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([0.4,.9])
set(gca,'XTickLabelRotation',25)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',fontsize)
set(gca,'fontsize',fontsize)
ylabel(cax,'m s^{-1}','fontsize',fontsize)
ylabel('Depth (m)','fontsize',fontsize)
print(fullfile(Meta_Data.L1path,'w_map.png'),'-dpng2')



