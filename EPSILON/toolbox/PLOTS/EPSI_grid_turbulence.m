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
chi1=cellfun(@(x) interp1(x.pr,x.chi(:,1),z),MS(~MSempty),'un',0);
chi2=cellfun(@(x) interp1(x.pr,x.chi(:,2),z),MS(~MSempty),'un',0);
t=cellfun(@(x) interp1(x.pr,x.t,z),MS(~MSempty),'un',0);
s=cellfun(@(x) interp1(x.pr,x.s,z),MS(~MSempty),'un',0);
flag=cellfun(@(x) interp1(x.pr,double(x.flag),z),MS(~MSempty),'un',0);
dnum=cell2mat(cellfun(@(x) mean(x.time),MS(~MSempty),'un',0));

Z=numel(z);

epsilon1=cell2mat(epsilon1);
epsilon2=cell2mat(epsilon2);
chi1=cell2mat(chi1);
chi2=cell2mat(chi2);
flag=cell2mat(flag);
t=cell2mat(t);
s=cell2mat(s);

flag(flag<1)=NaN;
sgth=sw_dens(s,t,z);

level_sig=linspace(min(nanmean(sgth,2)),max(nanmean(sgth,2)),100);
for dt=1:numel(dnum)
    indnan=~isnan(sgth(:,dt));
    eta(:,dt)=interp1(sgth(indnan,dt),z(indnan),level_sig);
end
dvals=floor(nanmean(eta,2)./2);
dmeta=diff(dvals);
eta2m=eta(dmeta>0,:);

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

N2 = sw_bfrq(s,t,zaxis2D,[]);
%%
Tz=diff(t)./diff(zaxis2D);
%%
zaxis12=z(1:end-1)+diff(z);
chi12=interp1(z,chi1,zaxis12);
chi22=interp1(z,chi2,zaxis12);
flag12=interp1(z,flag,zaxis12);


epsi_chi1 = interp1(zaxis12,chi12.* N2 ./gamma ./ Tz.^2,z);
epsi_chi2 = interp1(zaxis12,chi22.* N2 ./gamma ./ Tz.^2,z);
epsi_chi1(epsi_chi1<0)=nan;
epsi_chi2(epsi_chi2<0)=nan;

N2=interp1(zaxis12,N2.*flag12,z);
N2(N2<=0)=nan;
N2=fillmissing(N2,'linear');
n2=N2.*flag;




save(fullfile(Meta_Data.L1path,'Turbulence_grid.mat'), ...
    'epsilon1','epsilon2', ...
    'chi1','chi2', ...
    'dnum','z', ...
    'sgth','t','s','eta2m','flag','Meta_Data','lat','lon','H','epsi_chi1','epsi_chi2','n2')

close all

% epsilon 1 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsilon1)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k')
colorbar
caxis([-10,-5])
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
print(fullfile(Meta_Data.L1path,'Epsi1_map.png'),'-dpng2')

% epsilon 2
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsilon2)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k')
colorbar
caxis([-10,-5])
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

% chi 1 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(chi1.*flag)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k','linewidth',1)
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
print(fullfile(Meta_Data.L1path,'Chi1_map1.png'),'-dpng2')

%chi2 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(chi2.*flag)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k','linewidth',2)
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
pcolor(dnum,z,log10(real(epsi_chi1.*flag)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k','linewidth',2)
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon_{\chi_1})','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Epsichi1_map.png'),'-dpng2')

%epsilon from chi2 
figure;
colormap('parula')
pcolor(dnum,z,log10(real(epsi_chi2.*flag)));shading flat;axis ij
hold on
plot(dnum,eta2m,'k','linewidth',2)
colorbar
caxis([-11,-5])
set(gca,'XTickLabelRotation',45)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',15)
set(gca,'fontsize',15)
ylabel(cax,'log_{10}(\epsilon_{\chi_1})','fontsize',20)
ylabel('Depth (m)','fontsize',20)

fig=gcf;
fig.PaperPosition = [0 0 15 10];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Epsichi2_map.png'),'-dpng2')


