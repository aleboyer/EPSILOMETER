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
chi1=cellfun(@(x) interp1(x.pr,x.chi(:,1),z),MS(~MSempty),'un',0);
chi2=cellfun(@(x) interp1(x.pr,x.chi(:,2),z),MS(~MSempty),'un',0);
t=cellfun(@(x) interp1(x.pr,x.t,z),MS(~MSempty),'un',0);
s=cellfun(@(x) interp1(x.pr,x.s,z),MS(~MSempty),'un',0);
w=cellfun(@(x) interp1(x.pr,x.w,z),MS(~MSempty),'un',0);
flag1=cellfun(@(x) interp1(x.pr,double(x.flag(:,1)),z),MS(~MSempty),'un',0);
flag2=cellfun(@(x) interp1(x.pr,double(x.flag(:,2)),z),MS(~MSempty),'un',0);
dnum=cell2mat(cellfun(@(x) mean(x.time),MS(~MSempty),'un',0));

epsilon1=cell2mat(epsilon1);
epsilon2=cell2mat(epsilon2);
epsilon1_co=cell2mat(epsilon1_co);
epsilon2_co=cell2mat(epsilon2_co);
chi1=cell2mat(chi1);
chi2=cell2mat(chi2);
flag1=cell2mat(flag1);
flag2=cell2mat(flag2);
t=cell2mat(t);
s=cell2mat(s);
w=cell2mat(w);

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
    'chi1','chi2', ...
    'dnum','z', ...
    'sgth','t','s','w','eta2m','flag1','flag2','Meta_Data','lat','lon','H','epsi_chi1','epsi_chi2','n2')

