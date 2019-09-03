function EPSI_grid_turbulence(Meta_Data,MS)

% *call datenum vector dnum not time
% *include a yday field
% *all matrices are [depth x time] not the other way around
% *z vector is called z and are column vectors not row vectors
% *n2 not N2
% *sgth not Sig
% *s not S
% *t not T
% *lat and lon and H fields the same dimensions as yday (water depth H can be the same value for all)
% *Then yes, include an info structure with metadata and the processing script name and date.



if nargin==1
%     if exist(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'),'file')
%         load(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'))
%     else
        load(fullfile(Meta_Data.L1path,'Turbulence_Profiles.mat'),'MS')
%     end
end

MSempty=cellfun(@isempty,MS);
Map_pr=cellfun(@(x) (x.pr),MS(~MSempty),'un',0);
z=(min([Map_pr{:}]):.5:max([Map_pr{:}])).';
epsilon2=cellfun(@(x) interp1(x.pr,x.epsilon(:,2),z),MS(~MSempty),'un',0);
epsilon1=cellfun(@(x) interp1(x.pr,x.epsilon(:,1),z),MS(~MSempty),'un',0);
epsilon2_co=cellfun(@(x) interp1(x.pr,x.epsilon_co(:,2),z),MS(~MSempty),'un',0);
epsilon1_co=cellfun(@(x) interp1(x.pr,x.epsilon_co(:,1),z),MS(~MSempty),'un',0);
% epsilon2_eof=cellfun(@(x) interp1(x.pr,x.epsilon_eof(:,2),z),MS(~MSempty),'un',0);
% epsilon1_eof=cellfun(@(x) interp1(x.pr,x.epsilon_eof(:,1),z),MS(~MSempty),'un',0);

% epsilon2_fit=cellfun(@(x) interp1(x.pr,x.epsilon_fit(:,2),z),MS(~MSempty),'un',0);
% epsilon1_fit=cellfun(@(x) interp1(x.pr,x.epsilon_fit(:,1),z),MS(~MSempty),'un',0);
epsilon2_fit=cellfun(@(x) interp1(x.pr,x.epsilon_co(:,2),z),MS(~MSempty),'un',0);
epsilon1_fit=cellfun(@(x) interp1(x.pr,x.epsilon_co(:,1),z),MS(~MSempty),'un',0);
chi1=cellfun(@(x) interp1(x.pr,x.chi(:,1),z),MS(~MSempty),'un',0);
chi2=cellfun(@(x) interp1(x.pr,x.chi(:,2),z),MS(~MSempty),'un',0);
t=cellfun(@(x) interp1(x.pr,x.t,z),MS(~MSempty),'un',0);
s=cellfun(@(x) interp1(x.pr,x.s,z),MS(~MSempty),'un',0);
flag1=cellfun(@(x) interp1(x.pr,double(x.flag(:,1)),z),MS(~MSempty),'un',0);
flag2=cellfun(@(x) interp1(x.pr,double(x.flag(:,2)),z),MS(~MSempty),'un',0);
dnum=cell2mat(cellfun(@(x) mean(x.time),MS(~MSempty),'un',0));

Z=numel(z);

epsilon1=cell2mat(epsilon1);
epsilon2=cell2mat(epsilon2);
epsilon1_co=cell2mat(epsilon1_co);
epsilon2_co=cell2mat(epsilon2_co);
% epsilon1_eof=cell2mat(epsilon1_eof);
% epsilon2_eof=cell2mat(epsilon2_eof);
epsilon1_fit=cell2mat(epsilon1_fit);
epsilon2_fit=cell2mat(epsilon2_fit);
chi1=cell2mat(chi1);
chi2=cell2mat(chi2);
flag1=cell2mat(flag1);
flag2=cell2mat(flag2);
t=cell2mat(t);
s=cell2mat(s);

flag1(flag1<1)=NaN;
flag2(flag2<1)=NaN;

if all(isnan(flag1))
    warning('Flag1 is all nan. Check out the data')
    flag1(isnan(flag1))=1;
end
if all(isnan(flag2))
    warning('Flag2 is all nan. Check out the data')
    flag2(isnan(flag2))=1;
end

sgth=filloutliers(sw_dens(s,t,z).','nearest','movmedian',10).';

level_sig=linspace(min(nanmean(sgth,2)),max(nanmean(sgth,2)),100);
for dt=1:numel(dnum)
    indnan=~isnan(sgth(:,dt));
    eta(:,dt)=interp1(sgth(indnan,dt),z(indnan),level_sig);
end
dvals2=floor(nanmean(eta,2)./2);
dmeta2=diff(dvals2);
eta2m=eta(dmeta2>0,:);
plot(eta2m.')

dvals5=floor(nanmean(eta,2)./5);
dmeta5=diff(dvals5);
eta5m=eta(dmeta5>0,:);


if isfield('Meta_Data','lat')
    lat=dnum*0+lat;
else
    lat=dnum*nan;
end

if isfield('Meta_Data','lon')
    lon=dnum*0+lon;
else
    lon=dnum*nan;
end

if isfield('Meta_Data','H')
    H=dnum*0+H;
else
    H=dnum*nan;
end


%eps_chi = chi *N^2 / gamma / T_z^2 where gamma = 0.2

[T,Z]=size(t);
gamma=.2;
zaxis2D=repmat(z,[1,Z]);

% despite tyhe fact that sw_bfrq claims the results is in s^{-2} 
% it is in fact in (rad/s^{-1})^2
%N2 = sw_bfrq(s,t,zaxis2D,[])./(2*pi)^2; 
N2 = sw_bfrq(s,t,zaxis2D,[]); 
%%
Tz=diff(t)./diff(zaxis2D);
%%
zaxis12=z(1:end-1)+diff(z);
chi12=interp1(z,chi1,zaxis12);
chi22=interp1(z,chi2,zaxis12);


epsi_chi1 = interp1(zaxis12,chi12.* N2 ./gamma ./ Tz.^2,z);
epsi_chi2 = interp1(zaxis12,chi22.* N2 ./gamma ./ Tz.^2,z);
epsi_chi1(epsi_chi1<0)=nan;
epsi_chi2(epsi_chi2<0)=nan;

N2=interp1(zaxis12,N2,z);
N2(N2<=0)=nan;
N2=fillmissing(N2,'linear');
n2=N2.*flag1.*flag2;




save(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'), ...
    'epsilon1','epsilon2', ...
    'epsilon1_co','epsilon2_co', ...
    'epsilon1_fit','epsilon2_fit', ...
    'chi1','chi2', ...
    'dnum','z', ...
    'sgth','t','s','eta2m','flag1','flag2','Meta_Data','lat','lon','H','epsi_chi1','epsi_chi2','n2')

close all

% epsilon 1 
fontsize=25;
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

% % epsilon eof 1 
% figure;
% colormap('parula')
% pcolor(dnum,z,log10(real(epsilon1_eof)));shading flat;axis ij
% hold on
% plot(dnum,eta2m,'k')
% colorbar
% caxis([-11,-5])
% set(gca,'XTickLabelRotation',45)
% datetick
% cax=colorbar;
% xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
% set(gca,'fontsize',15)
% ylabel(cax,'log_{10}(\epsilon_{eof})','fontsize',20)
% ylabel('Depth (m)','fontsize',20)
% 
% fig=gcf;
% fig.PaperPosition = [0 0 15 10];
% fig.PaperOrientation='Portrait';
% print(fullfile(Meta_Data.L1path,'EpsiMap1_eof.png'),'-dpng2')
% 
% % epsilon eof 2
% figure;
% colormap('parula')
% pcolor(dnum,z,log10(real(epsilon2_eof)));shading flat;axis ij
% hold on
% plot(dnum,eta2m,'k')
% colorbar
% caxis([-11,-5])
% set(gca,'XTickLabelRotation',45)
% datetick
% cax=colorbar;
% xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
% set(gca,'fontsize',15)
% ylabel(cax,'log_{10}(\epsilon_{eof})','fontsize',20)
% ylabel('Depth (m)','fontsize',20)
% 
% fig=gcf;
% fig.PaperPosition = [0 0 15 10];
% fig.PaperOrientation='Portrait';
% print(fullfile(Meta_Data.L1path,'EpsiMap2_eof.png'),'-dpng2')



% epsilon fit 1 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsilon1_fit)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k')
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon_{fit})','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'EpsiMap1_fit.png'),'-dpng2')

% epsilon 2
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsilon2_fit)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k')
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon_{fit})','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'EpsiMap2_fit.png'),'-dpng2')



% chi 1 
figure;
colormap('parula')
%pcolor(dnum,z,log10(real(chi1.*flag1)));shading flat;axis ij
pcolor(dnum,z,log10(real(chi1)));shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([-11,-5])
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
print(fullfile(Meta_Data.L1path,'Chi1_map1.png'),'-dpng2')

%chi2 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(chi2.*flag2)));shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([-11,-5])
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
pcolor(dnum,z,log10(real(epsi_chi1.*flag1)));shading flat;axis ij
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
pcolor(dnum,z,log10(real(epsi_chi2.*flag2)));shading flat;axis ij
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


